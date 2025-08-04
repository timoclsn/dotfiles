import type { Plugin } from "@opencode-ai/plugin";

export const Notify: Plugin = async ({ app, client, $ }) => {
  return {
    async event({ event }) {
      if (event.type === "session.idle") {
        const pathParts = app.path.cwd.split("/");
        const projectName = pathParts.slice(-2).join("/") || "";

        const sessions = await client.session.list();
        const currentSession = sessions.find(
          (s) => s.id === event.properties.sessionID,
        );

        await $`terminal-notifier \
          -title "opencode" \
          -subtitle "\[${projectName}]" \
          -message "Run complete: ${currentSession.title}" \
          -group "opencode-${projectName}" \
          -activate "com.mitchellh.ghostty"`.quiet();
      }
    },
  };
};
