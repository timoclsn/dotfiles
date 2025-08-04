import type { Plugin } from "@opencode-ai/plugin";

export const NotificationPlugin: Plugin = async ({ app, $ }) => {
  return {
    async event({ event }) {
      if (event.type === "session.idle") {
        const projectName = app.path.cwd.split("/").pop() || "";

        await $`terminal-notifier \
          -title "opencode" \
          -subtitle "Project: ${projectName}" \
          -message "Agent run complete" \
          -group "opencode-${projectName}" \
          -activate "com.mitchellh.ghostty"`.quiet();
      }
    },
  };
};
