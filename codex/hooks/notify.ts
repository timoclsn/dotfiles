import { readFileSync } from "node:fs";
import { $ } from "bun";

interface NotificationInput {
  type?: string;
  session_id?: string;
  transcript_path?: string;
  "input-messages"?: string[];
  "last-assistant-message"?: string;
  cwd?: string;
}

interface TranscriptEntry {
  type: string;
  isMeta?: boolean;
  content?: string;
  message?: {
    content: string;
  };
}

const getSessionTitle = (transcriptPath?: string) => {
  if (!transcriptPath) return null;

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

const readNotification = async () => {
  const arg = Bun.argv[2];

  if (arg) {
    try {
      return JSON.parse(arg) as NotificationInput;
    } catch {
      return null;
    }
  }

  try {
    return (await Bun.stdin.json()) as NotificationInput;
  } catch {
    return null;
  }
};

const getCodexTitle = (notification: NotificationInput) => {
  const inputMessages = notification["input-messages"];
  const lastAssistantMessage = notification["last-assistant-message"];

  if (inputMessages?.length) {
    return inputMessages[0]?.slice(0, 50) ?? null;
  }

  if (lastAssistantMessage) {
    return lastAssistantMessage.slice(0, 50);
  }

  return null;
};

const main = async () => {
  const notification = await readNotification();

  if (!notification) return;

  const { type, session_id: sessionId, transcript_path: transcriptPath } =
    notification;

  if (type !== "agent-turn-complete") {
    if (type) console.log(`not sending a push notification for: ${type}`);
    return;
  }

  const sessionTitle =
    getSessionTitle(transcriptPath) ?? getCodexTitle(notification);

  if (sessionTitle === "ai-commit") return;

  const pathParts = (notification.cwd ?? process.cwd()).split("/").filter(Boolean);
  const projectName = pathParts[pathParts.length - 1] ?? "";
  const projectCategory = pathParts[pathParts.length - 2] ?? "";
  const subtitle = `\\[${projectCategory}/${projectName}]`;

  const isDefaultTitle = sessionTitle?.startsWith("New session - ");
  const message =
    sessionTitle && !isDefaultTitle ? sessionTitle : "Agent turn complete";

  const groupSuffix = sessionId ? `${projectName}-${sessionId}` : projectName;

  const onClick = `osascript \
    -e 'tell application "Ghostty" to activate' \
    -e 'tell application "System Events" to key code 49 using control down' \
    -e 'tell application "System Events" to keystroke ":"' \
    -e 'delay 0.1' \
    -e 'tell application "System Events" to keystroke "switch-client -t ${projectName}:3"' \
    -e 'tell application "System Events" to key code 36'`;

  await $`terminal-notifier \
    -title "Codex" \
    -subtitle "${subtitle}" \
    -message "${message}" \
    -group "codex-${groupSuffix}" \
    -execute "${onClick}"`.quiet();
};

main();
