import type { Plugin } from "@opencode-ai/plugin";

export const Notify: Plugin = async ({ app, client, $ }) => {
  return {
    async event({ event }) {
      if (event.type === "session.idle") {
        // Project name
        const pathParts = app.path.cwd.split("/");
        const projectName = pathParts.slice(-2).join("/") || "";

        // Session title
        const { data } = await client.session.list();
        const currentSession = data?.find(
          (s) => s.id === event.properties.sessionID,
        );
        const sessionTitle = currentSession?.title || "";
        const message = sessionTitle ? sessionTitle : "Agent run complete";

        await $`terminal-notifier \
          -title "opencode" \
          -subtitle "\[${projectName}]" \
          -message "${message}" \
          -group "opencode-${projectName}" \
          -activate "com.mitchellh.ghostty"`.quiet();
      }
    },
  };
};
