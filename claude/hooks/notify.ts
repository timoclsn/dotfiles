import { getSessionName } from "./utils";

interface HookInput {
  session_id: string;
  transcript_path: string;
  hook_event_name?: string;
  cwd?: string;
  message?: string;
  workspace?: {
    project_dir: string;
  };
}

const main = async () => {
  const input: HookInput = await Bun.stdin.json();
  const { session_id: sessionId, transcript_path: transcriptPath } = input;
  const projectDir = input.workspace?.project_dir ?? input.cwd ?? process.cwd();

  const pathParts = projectDir.split("/").filter(Boolean);
  const projectName = pathParts[pathParts.length - 1] ?? "";
  const projectCategory = pathParts[pathParts.length - 2] ?? "";
  const subtitle = `${projectCategory}/${projectName}`;

  if (input.hook_event_name === "Notification") {
    const message = input.message ?? "Waiting for input";

    sendNotification({ subtitle, message, projectName, sessionId });
    return;
  }

  const sessionTitle = getSessionName({
    projectDir,
    sessionId,
    transcriptPath,
  });

  if (sessionTitle === "ai-commit") return;

  const message = sessionTitle ?? "Agent run complete";

  sendNotification({ subtitle, message, projectName, sessionId });
};

interface NotificationOptions {
  subtitle: string;
  message: string;
  projectName: string;
  sessionId: string;
}

const sendNotification = ({
  subtitle,
  message,
  projectName,
  sessionId,
}: NotificationOptions) => {
  const onClick = `osascript \
    -e 'tell application "Ghostty" to activate' \
    -e 'tell application "System Events" to key code 49 using control down' \
    -e 'tell application "System Events" to keystroke ":"' \
    -e 'delay 0.1' \
    -e 'tell application "System Events" to keystroke "switch-client -t ${projectName}:3"' \
    -e 'tell application "System Events" to key code 36'`;

  Bun.spawn([
    "/opt/homebrew/bin/terminal-notifier",
    "-title",
    "Claude Code",
    "-subtitle",
    subtitle,
    "-message",
    message,
    "-group",
    `claude-${projectName}-${sessionId}`,
    "-execute",
    onClick,
  ]);
};

main();
