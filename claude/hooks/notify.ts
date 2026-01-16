import { readFileSync } from "node:fs";
import { $ } from "bun";

interface HookInput {
  session_id: string;
  transcript_path: string;
}

interface TranscriptEntry {
  type: string;
  isMeta?: boolean;
  content?: string;
  message?: {
    content: string;
  };
}

const getSessionTitle = (transcriptPath: string) => {
  try {
    const content = readFileSync(transcriptPath, "utf-8");
    const lines = content.split("\n").filter(Boolean);

    for (const line of lines) {
      const entry: TranscriptEntry = JSON.parse(line);

      if (entry.type !== "user") continue;
      if (entry.isMeta) continue;

      const text =
        (typeof entry.content === "string" ? entry.content : null) ??
        entry.message?.content;

      if (!text) continue;
      if (text.startsWith("<")) continue;

      return text.slice(0, 50);
    }

    return null;
  } catch {
    return null;
  }
};

const main = async () => {
  const input: HookInput = await Bun.stdin.json();
  const { session_id: sessionId, transcript_path: transcriptPath } = input;

  const directory = process.cwd();
  const pathParts = directory.split("/").filter(Boolean);
  const projectName = pathParts[pathParts.length - 1] ?? "";
  const projectCategory = pathParts[pathParts.length - 2] ?? "";
  const subtitle = `\\[${projectCategory}/${projectName}]`;

  const sessionTitle = getSessionTitle(transcriptPath);

  if (sessionTitle === "ai-commit") return;

  const isDefaultTitle = sessionTitle?.startsWith("New session - ");
  const message =
    sessionTitle && !isDefaultTitle ? sessionTitle : "Agent run complete";

  const onClick = `osascript \
    -e 'tell application "Ghostty" to activate' \
    -e 'tell application "System Events" to key code 49 using control down' \
    -e 'tell application "System Events" to keystroke ":"' \
    -e 'delay 0.1' \
    -e 'tell application "System Events" to keystroke "switch-client -t ${projectName}:3"' \
    -e 'tell application "System Events" to key code 36'`;

  await $`/opt/homebrew/bin/terminal-notifier \
    -title "Claude Code" \
    -subtitle "${subtitle}" \
    -message "${message}" \
    -group "claude-${projectName}-${sessionId}" \
    -execute "${onClick}"`.quiet();
};

main();
