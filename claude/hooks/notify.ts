import { getSessionName } from "./utils";

interface HookInput {
  session_id: string;
  transcript_path: string;
  workspace?: {
    project_dir: string;
  };
}

const main = async () => {
  const input: HookInput = await Bun.stdin.json();
  const { session_id: sessionId, transcript_path: transcriptPath } = input;
  const projectDir = input.workspace?.project_dir ?? process.cwd();

  const pathParts = projectDir.split("/").filter(Boolean);
  const projectName = pathParts[pathParts.length - 1] ?? "";
  const projectCategory = pathParts[pathParts.length - 2] ?? "";
  const subtitle = `\\[${projectCategory}/${projectName}]`;

  const sessionTitle = getSessionName({ projectDir, sessionId, transcriptPath });

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

  Bun.spawn([
    '/opt/homebrew/bin/terminal-notifier',
    '-title', 'Claude Code',
    '-subtitle', subtitle,
    '-message', message,
    '-group', `claude-${projectName}-${sessionId}`,
    '-execute', onClick
  ]);
};

main();
