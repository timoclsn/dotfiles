import { mkdirSync, writeFileSync, readFileSync } from "node:fs";
import { $ } from "bun";

const STATUS_DIR = `${process.env.HOME}/.local/share/agent-control-center`;

interface CodexNotification {
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
  message?: { content: string };
}

const truncate = (str: string, len: number) =>
  str.length > len ? str.slice(0, len) + "…" : str;

const getTmuxInfo = async () => {
  try {
    const session = await $`tmux display-message -p '#{session_name}'`.text();
    const window = await $`tmux display-message -p '#{window_index}'`.text();
    const pane = await $`tmux display-message -p '#{pane_index}'`.text();
    return {
      session: session.trim(),
      window: window.trim(),
      pane: pane.trim()
    };
  } catch {
    return null;
  }
};

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
      return JSON.parse(arg) as CodexNotification;
    } catch {
      return null;
    }
  }

  try {
    return (await Bun.stdin.json()) as CodexNotification;
  } catch {
    return null;
  }
};

const getCodexTitle = (notification: CodexNotification) => {
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
  mkdirSync(STATUS_DIR, { recursive: true });

  const notification = await readNotification();
  if (!notification) return;

  if (notification.type !== "agent-turn-complete") return;

  const tmux = await getTmuxInfo();
  if (!tmux) return;

  const statusFile = `${STATUS_DIR}/${tmux.session}-${tmux.window}-${tmux.pane}.json`;
  const path = notification.cwd ?? process.cwd();

  let prompt: string | undefined;
  try {
    const existing = JSON.parse(readFileSync(statusFile, "utf-8"));
    prompt = existing.prompt;
  } catch {}

  if (!prompt) {
    const sessionTitle = getSessionTitle(notification.transcript_path) ?? getCodexTitle(notification);
    if (sessionTitle) {
      prompt = truncate(sessionTitle.replace(/\n/g, " ").trim(), 40);
    }
  }

  writeFileSync(statusFile, JSON.stringify({
    agent: "codex",
    status: "idle",
    path,
    tmux,
    prompt,
    timestamp: Date.now()
  }));
};

main();
