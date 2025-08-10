import type { Plugin } from "@opencode-ai/plugin";

export const Notify: Plugin = async ({ app, client, $ }) => {
  return {
    async event({ event }) {
      if (event.type === "session.idle") {
        // Project name
        const pathParts = app.path.cwd.split("/");
        const projectName = pathParts.slice(-2).join("/") || "";

        // Session title
        const sessionID = event.properties.sessionID;
        const { data: currentSession } = await client.session.get({
          path: { id: sessionID },
        });
        const sessionTitle = currentSession?.title || "";
        const message = sessionTitle ? sessionTitle : "Agent run complete";

        await $`terminal-notifier \
          -title "opencode" \
          -subtitle "\[${projectName}]" \
          -message "${message}" \
          -group "opencode-${projectName}-${sessionID}" \
          -activate "com.mitchellh.ghostty"`.quiet();
      }
    },
  };
};
