import type { Plugin } from "@opencode-ai/plugin";
import { mkdirSync, writeFileSync, readFileSync } from "node:fs";

const STATUS_DIR = `${process.env.HOME}/.local/share/agent-control-center`;

const truncate = (str: string, len: number) =>
  str.length > len ? str.slice(0, len) + "…" : str;

const getTmuxInfo = async ($: any) => {
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

export const AgentControlCenter: Plugin = async ({ directory, client, $ }) => {
  mkdirSync(STATUS_DIR, { recursive: true });

  const pathParts = directory.split("/").filter(Boolean);
  const projectName = pathParts[pathParts.length - 1] || "";
  const projectCategory = pathParts[pathParts.length - 2] || "";
  const projectPath = `${projectCategory}/${projectName}`;

  return {
    async event({ event }) {
      const tmux = await getTmuxInfo($);
      if (!tmux) return;

      const statusFile = `${STATUS_DIR}/${tmux.session}-${tmux.window}-${tmux.pane}.json`;

      if (event.type === "session.created" || event.type === "session.status") {
        const sessionID = event.properties.sessionID;
        const { data: currentSession } = await client.session.get({
          path: { id: sessionID },
        });

        if (!currentSession) return;
        if (currentSession.parentID) return;

        let prompt: string | undefined;
        try {
          const existing = JSON.parse(readFileSync(statusFile, "utf-8"));
          prompt = existing.prompt;
        } catch {}

        if (!prompt && currentSession.title && !currentSession.title.startsWith("New session - ")) {
          prompt = truncate(currentSession.title.replace(/\n/g, " ").trim(), 40);
        }

        writeFileSync(statusFile, JSON.stringify({
          agent: "opencode",
          status: "working",
          path: directory,
          tmux,
          prompt,
          timestamp: Date.now()
        }));
      }

      if (event.type === "session.idle") {
        const sessionID = event.properties.sessionID;
        const { data: currentSession } = await client.session.get({
          path: { id: sessionID },
        });

        if (!currentSession) return;
        if (currentSession.parentID) return;

        let prompt: string | undefined;
        try {
          const existing = JSON.parse(readFileSync(statusFile, "utf-8"));
          prompt = existing.prompt;
        } catch {}

        if (!prompt && currentSession.title && !currentSession.title.startsWith("New session - ")) {
          prompt = truncate(currentSession.title.replace(/\n/g, " ").trim(), 40);
        }

        writeFileSync(statusFile, JSON.stringify({
          agent: "opencode",
          status: "idle",
          path: directory,
          tmux,
          prompt,
          timestamp: Date.now()
        }));
      }
    },
  };
};
