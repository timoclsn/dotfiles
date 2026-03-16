import { $ } from "bun";
import { getSessionName } from "./utils";

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

const getGitBranch = async () => {
  try {
    const result = await $`git branch --show-current`.quiet();
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

const main = async () => {
  const input: StatusLineInput = await Bun.stdin.json();

  const model = input.model.display_name.replace(/\s*\(.*?\)/, "");
  const session = getSessionName({
    projectDir: input.workspace.project_dir,
    sessionId: input.session_id,
    transcriptPath: input.transcript_path,
  });
  const dir = truncateMiddle(
    input.workspace.current_dir.split("/").at(-1) ?? "",
    15,
  );
  const gitBranch = await getGitBranch();
  const contextUsage = getContextUsage(input);
  const linesChanged = `+${input.cost.total_lines_added}/-${input.cost.total_lines_removed}`;

  const maxProjectLen = 46;
  const project = `${dir}${gitBranch}`;
  let truncatedProject = project;
  if (project.length > maxProjectLen && gitBranch) {
    const maxBranchLen = maxProjectLen - dir.length;
    truncatedProject = `${dir}${truncateMiddle(gitBranch, maxBranchLen)}`;
  } else if (project.length > maxProjectLen) {
    truncatedProject = truncateMiddle(project, maxProjectLen);
  }

  const parts = [model, contextUsage, linesChanged, truncatedProject];
  if (session) parts.push(session);

  console.log(parts.join(" | "));
};

main();
