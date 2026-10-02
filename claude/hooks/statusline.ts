import { $ } from "bun";
import {
  assistantEntriesNewestFirst,
  getSessionName,
  readTranscript,
} from "./utils";

interface StatusLineInput {
  hook_event_name: string;
  session_id: string;
  transcript_path: string;
  cwd: string;
  model: {
    id: string;
    display_name: string;
  };
  workspace: {
    current_dir: string;
    project_dir: string;
  };
  version: string;
  output_style: {
    name: string;
  };
  effort?: {
    level: "low" | "medium" | "high" | "xhigh" | "max";
  };
  cost: {
    total_cost_usd: number;
    total_duration_ms: number;
    total_api_duration_ms: number;
    total_lines_added: number;
    total_lines_removed: number;
  };
  context_window: {
    total_input_tokens: number;
    total_output_tokens: number;
    context_window_size: number;
    current_usage: {
      input_tokens: number;
      output_tokens: number;
      cache_creation_input_tokens: number;
      cache_read_input_tokens: number;
    } | null;
  };
}

const getGitBranch = async (dir: string) => {
  try {
    const result = await $`git -C ${dir} branch --show-current`.quiet();
    const branch = result.text().trim();
    return branch ? `:${branch}` : "";
  } catch {
    return "";
  }
};

const formatTokens = (tokens: number) => {
  if (tokens >= 1_000_000) return `${Math.round(tokens / 1_000_000)}M`;
  if (tokens >= 1_000) return `${Math.round(tokens / 1_000)}k`;
  return `${tokens}`;
};

const truncateMiddle = (str: string, maxLen: number) => {
  if (str.length <= maxLen) return str;
  const head = Math.ceil((maxLen - 1) / 2);
  const tail = Math.floor((maxLen - 1) / 2);
  return `${str.slice(0, head)}…${str.slice(-tail)}`;
};

const getContextUsage = (input: StatusLineInput) => {
  const { context_window } = input;
  if (!context_window.current_usage) return "0/0 (0%)";

  const currentTokens =
    context_window.current_usage.input_tokens +
    context_window.current_usage.cache_creation_input_tokens +
    context_window.current_usage.cache_read_input_tokens;

  const percentUsed = Math.round(
    (currentTokens * 100) / context_window.context_window_size,
  );

  const current = formatTokens(currentTokens);
  const total = formatTokens(context_window.context_window_size);

  return `${current}/${total} (${percentUsed}%)`;
};

const FIVE_MINUTES_MS = 5 * 60_000;
const ONE_HOUR_MS = 60 * 60_000;

// The prompt cache lives for its TTL after the last request that read or wrote
// it. The TTL tier (5m or 1h) is only visible on requests that wrote to it.
const getCacheExpiresAt = (transcriptContent: string) => {
  let lastRequestAt: number | null = null;
  for (const entry of assistantEntriesNewestFirst(transcriptContent)) {
    const usage = entry.message?.usage;
    if (entry.isSidechain || !usage || entry.message.model === "<synthetic>")
      continue;
    const requestAt = Date.parse(entry.timestamp);
    if (isNaN(requestAt)) continue;
    lastRequestAt ??= requestAt;
    if (usage.cache_creation?.ephemeral_1h_input_tokens)
      return lastRequestAt + ONE_HOUR_MS;
    if (usage.cache_creation?.ephemeral_5m_input_tokens)
      return lastRequestAt + FIVE_MINUTES_MS;
  }
  return lastRequestAt === null ? null : lastRequestAt + FIVE_MINUTES_MS;
};

const formatCacheTimer = (expiresAt: number | null) => {
  if (expiresAt === null) return "";
  const remainingMs = expiresAt - Date.now();
  return remainingMs > 0 ? `${Math.ceil(remainingMs / 60_000)}m` : "EXPIRED";
};

const main = async () => {
  const input: StatusLineInput = await Bun.stdin.json();

  const modelName = input.model.display_name.replace(/\s*\(.*?\)/, "");
  const model = input.effort
    ? `${modelName} (${input.effort.level})`
    : modelName;
  const projectDir = input.workspace.project_dir;
  const gitBranchPromise = getGitBranch(projectDir);
  const transcriptContent = readTranscript(input.transcript_path);
  const session = getSessionName(transcriptContent);
  const cacheTimer = formatCacheTimer(getCacheExpiresAt(transcriptContent));
  const dir = truncateMiddle(projectDir.split("/").at(-1) ?? "", 15);
  const contextUsage = getContextUsage(input);
  // Claude Code's own list-price estimate; the official total is in the tmux bar
  const sessionCost = `$${input.cost.total_cost_usd.toFixed(2)}`;

  const gitBranch = await gitBranchPromise;
  const maxProjectLen = 46;
  const project = `${dir}${gitBranch}`;
  let truncatedProject = project;
  if (project.length > maxProjectLen && gitBranch) {
    const maxBranchLen = maxProjectLen - dir.length;
    truncatedProject = `${dir}${truncateMiddle(gitBranch, maxBranchLen)}`;
  } else if (project.length > maxProjectLen) {
    truncatedProject = truncateMiddle(project, maxProjectLen);
  }

  const parts = [
    model,
    contextUsage,
    cacheTimer,
    sessionCost,
    truncatedProject,
    session,
  ].filter(Boolean);

  console.log(parts.join(" | "));
};

main();
