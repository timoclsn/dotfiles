import { mkdirSync, writeFileSync } from "node:fs";
import { $ } from "bun";

const STATUS_DIR = `${process.env.HOME}/.claude/instance-status`;

const getStatus = (event: string) => {
  if (event === "Stop") return "idle";
  if (event === "UserPromptSubmit") return "working";
  return "working";
};

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

const truncate = (str: string, len: number) =>
  str.length > len ? str.slice(0, len) + "…" : str;

const main = async () => {
  mkdirSync(STATUS_DIR, { recursive: true });

  const input = await Bun.stdin.json();

  const status = getStatus(input.hook_event_name);

  const tmux = await getTmuxInfo();
  if (!tmux) return;

  const statusFile = `${STATUS_DIR}/${tmux.session}-${tmux.window}-${tmux.pane}.json`;
  const path = input.workspace?.current_dir ?? input.cwd ?? process.cwd();

  // Read existing file to preserve initial prompt
  let prompt: string | undefined;
  try {
    const existing = JSON.parse(await Bun.file(statusFile).text());
    prompt = existing.prompt;
  } catch {}

  // Only capture prompt on first UserPromptSubmit (when no prompt exists yet)
  if (!prompt && input.hook_event_name === "UserPromptSubmit" && input.prompt) {
    prompt = truncate(input.prompt.replace(/\n/g, " ").trim(), 40);
  }

  writeFileSync(statusFile, JSON.stringify({
    status,
    path,
    tmux,
    prompt,
    timestamp: Date.now()
  }));
};

main();
