import { spawn } from "node:child_process";
import { realpathSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const pushToken = process.env.PUSHOVER_PI || process.env.PUSHOVER_TOKEN;
const pushUser = process.env.PUSHOVER_USER_KEY || process.env.PUSHOVER_USER;

interface SessionEntry {
  type: string;
  name?: string;
  message?: {
    role?: string;
    content?: unknown;
    errorMessage?: string;
  };
}

interface NotificationOptions {
  subtitle: string;
  message: string;
  projectName: string;
  sessionId: string;
  lastAssistantText?: string | null;
}

const truncate = (text: string, max: number) => {
  const normalized = text.replace(/\n/g, " ").trim();
  return normalized.length > max ? `${normalized.slice(0, max)}…` : normalized;
};

const getTitle = (entries: SessionEntry[], sessionName?: string) => {
  if (sessionName && sessionName !== "ai-commit") {
    return truncate(sessionName, 50);
  }

  for (const entry of entries) {
    if (entry.type === "message" && entry.message?.role === "user") {
      const content = entry.message.content;
      let text = "";
      if (typeof content === "string") {
        text = content;
      } else if (Array.isArray(content)) {
        for (const block of content) {
          if (
            block &&
            typeof block === "object" &&
            "type" in block &&
            block.type === "text" &&
            "text" in block &&
            typeof block.text === "string"
          ) {
            text += block.text;
          }
        }
      }

      text = text.trim();
      if (!text) continue;

      if (text.startsWith("<")) {
        const stripped = text.replace(/<[^>]+>[^<]*<\/[^>]+>/g, "").trim();
        if (stripped && !stripped.startsWith("<")) {
          return truncate(stripped, 50);
        }
        continue;
      }

      return truncate(text, 50);
    }
  }

  return null;
};

const getLastAssistantMessage = (entries: SessionEntry[]) => {
  for (let i = entries.length - 1; i >= 0; i--) {
    const entry = entries[i];
    if (entry.type === "message" && entry.message?.role === "assistant") {
      const msg = entry.message;
      let text = "";
      if (typeof msg.content === "string") {
        text = msg.content;
      } else if (Array.isArray(msg.content)) {
        for (const block of msg.content) {
          if (
            block &&
            typeof block === "object" &&
            "type" in block &&
            block.type === "text" &&
            "text" in block &&
            typeof block.text === "string"
          ) {
            text += (text ? "\n" : "") + block.text;
          }
        }
      }
      if (!text && msg.errorMessage) {
        text = msg.errorMessage;
      }
      if (text.trim()) {
        return text.trim();
      }
    }
  }
  return null;
};

export default async (pi: ExtensionAPI) => {
  const realDir = dirname(realpathSync(fileURLToPath(import.meta.url)));
  const { getIdleTime, IDLE_THRESHOLD } = await import(
    join(realDir, "../../scripts/idle-time.ts")
  );
  const { sendPushover } = await import(
    join(realDir, "../../scripts/pushover.ts")
  );

  const sendNotification = async ({
    subtitle,
    message,
    projectName,
    sessionId,
    lastAssistantText,
  }: NotificationOptions) => {
    const onClick = `osascript \
      -e 'tell application "Ghostty" to activate' \
      -e 'tell application "System Events" to key code 49 using control down' \
      -e 'tell application "System Events" to keystroke ":"' \
      -e 'delay 0.1' \
      -e 'tell application "System Events" to keystroke "switch-client -t ${projectName}:3"' \
      -e 'tell application "System Events" to key code 36'`;

    const proc = spawn(
      "/opt/homebrew/bin/terminal-notifier",
      [
        "-title",
        "Pi",
        "-subtitle",
        subtitle,
        "-message",
        message,
        "-group",
        `pi-${projectName}-${sessionId}`,
        "-execute",
        onClick,
      ],
      { stdio: "ignore", detached: true },
    );
    proc.unref();

    if (!pushToken || !pushUser) return;

    const idleSeconds = await getIdleTime();
    if (idleSeconds < IDLE_THRESHOLD) return;

    const pushMessage = lastAssistantText
      ? `[${subtitle}] ${message}\n\n${lastAssistantText.slice(0, 500)}`
      : `[${subtitle}] ${message}`;

    sendPushover({
      token: pushToken,
      title: "Pi",
      message: pushMessage,
    });
  };
  pi.on("agent_settled", async (_event, ctx) => {
    const projectDir = ctx.cwd ?? process.cwd();
    const pathParts = projectDir.split("/").filter(Boolean);
    const projectName = pathParts[pathParts.length - 1] ?? "";
    const projectCategory = pathParts[pathParts.length - 2] ?? "";
    const subtitle = `${projectCategory}/${projectName}`;

    const sessionName = ctx.sessionManager.getSessionName();
    if (sessionName === "ai-commit") return;

    const entries = ctx.sessionManager.getEntries() as SessionEntry[];
    const title = getTitle(entries, sessionName);
    if (title === "ai-commit") return;

    const message = title ?? "Agent run complete";
    const sessionId = ctx.sessionManager.getSessionId();
    const lastAssistantText = getLastAssistantMessage(entries);

    await sendNotification({
      subtitle,
      message,
      projectName,
      sessionId,
      lastAssistantText,
    });
  });

  pi.on("ui_prompt_start", async (event, ctx) => {
    const projectDir = ctx.cwd ?? process.cwd();
    const pathParts = projectDir.split("/").filter(Boolean);
    const projectName = pathParts[pathParts.length - 1] ?? "";
    const projectCategory = pathParts[pathParts.length - 2] ?? "";
    const subtitle = `${projectCategory}/${projectName}`;

    const sessionId = ctx.sessionManager.getSessionId();
    const message = event.title ?? "Waiting for input";

    await sendNotification({
      subtitle,
      message,
      projectName,
      sessionId,
    });
  });
};
