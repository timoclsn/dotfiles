interface CodexNotification {
  type?: string;
  "thread-id"?: string;
  "turn-id"?: string;
  cwd?: string;
  "input-messages"?: string[];
  "last-assistant-message"?: string;
}

const readNotification = (): CodexNotification | null => {
  try {
    return JSON.parse(Bun.argv[2]);
  } catch {
    return null;
  }
};

const truncate = (text: string, max: number) => {
  const normalized = text.replace(/\n/g, " ");
  return normalized.length > max ? `${normalized.slice(0, max)}…` : normalized;
};

const getTitle = (notification: CodexNotification) => {
  const inputMessages = notification["input-messages"];

  if (inputMessages?.length) {
    const firstUserMessage = inputMessages.find((msg) => !msg.startsWith("<"));
    if (firstUserMessage) {
      return truncate(firstUserMessage, 50);
    }
  }

  const lastAssistantMessage = notification["last-assistant-message"];
  if (lastAssistantMessage) {
    return truncate(lastAssistantMessage, 50);
  }

  return null;
};

const main = () => {
  const notification = readNotification();
  if (!notification) return;

  if (notification.type !== "agent-turn-complete") return;

  const title = getTitle(notification);

  const pathParts = (notification.cwd ?? process.cwd())
    .split("/")
    .filter(Boolean);
  const projectName = pathParts.at(-1) ?? "";
  const projectCategory = pathParts.at(-2) ?? "";

  const subtitle = `\\[${projectCategory}/${projectName}]`;
  const message = title ?? "Agent turn complete";
  const group = notification["thread-id"]
    ? `codex-${projectName}-${notification["thread-id"]}`
    : `codex-${projectName}`;

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
    "Codex",
    "-subtitle",
    subtitle,
    "-message",
    message,
    "-group",
    group,
    "-execute",
    onClick,
  ]);
};

main();
