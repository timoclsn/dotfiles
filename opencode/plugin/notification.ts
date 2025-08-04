import type { Plugin } from "@opencode-ai/plugin";

export const NotificationPlugin: Plugin = async ({ app, $ }) => {
  return {
    async event({ event }) {
      if (event.type === "session.idle") {
        const pathParts = app.path.cwd.split("/");
        const projectName = pathParts.slice(-2).join("/") || "";

        await $`terminal-notifier \
          -title "opencode" \
          -subtitle "\[${projectName}]" \
          -message "Agent run complete" \
          -group "opencode-${projectName}" \
          -activate "com.mitchellh.ghostty"`.quiet();
      }
    },
  };
};
