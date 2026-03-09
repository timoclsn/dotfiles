import { getIdleTime, IDLE_THRESHOLD } from "../../scripts/idle-time";
import { sendPushover } from "../../scripts/pushover";
import { getLastAssistantMessage, getSessionName } from "./utils";

const pushToken = process.env.PUSHOVER_CLAUDE_CODE;
const pushUser = process.env.PUSHOVER_USER_KEY;

interface HookInput {
  session_id: string;
  transcript_path: string;
  hook_event_name?: string;
  notification_type?: string;
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
    if (
      input.notification_type === "auth_success" ||
      input.notification_type === "idle_prompt"
    )
      return;

    const message = input.message ?? "Waiting for input";

    await sendNotification({
      subtitle,
      message,
      transcriptPath,
      projectName,
      sessionId,
    });
    return;
  }

  const sessionTitle = getSessionName({
    projectDir,
    sessionId,
    transcriptPath,
  });

  if (sessionTitle === "ai-commit") return;

  const message = sessionTitle ?? "Agent run complete";

  await sendNotification({
    subtitle,
    message,
    transcriptPath,
    projectName,
    sessionId,
  });
};

interface NotificationOptions {
  subtitle: string;
  message: string;
  transcriptPath: string;
  projectName: string;
  sessionId: string;
}

const sendNotification = async ({
  subtitle,
  message,
  transcriptPath,
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

  if (!pushToken || !pushUser) return;

  const idleSeconds = await getIdleTime();
  if (idleSeconds < IDLE_THRESHOLD) return;

  await Bun.sleep(1000);
  const lastMessage = getLastAssistantMessage(transcriptPath);
  const pushMessage = lastMessage
    ? `[${subtitle}] ${message}\n\n${lastMessage.slice(0, 500)}`
    : `[${subtitle}] ${message}`;
  sendPushover({
    token: pushToken,
    title: "Claude Code",
    message: pushMessage,
  });
};

main();
