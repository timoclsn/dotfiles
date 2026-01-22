import type { Plugin } from "@opencode-ai/plugin";

export const Notify: Plugin = async ({ directory, client }) => {
  return {
    async event({ event }) {
      if (event.type === "session.idle") {
        // Project name
        const pathParts = directory.split("/").filter(Boolean);
        const projectName = pathParts[pathParts.length - 1] || "";
        const projectCategory = pathParts[pathParts.length - 2] || "";
        const subtitle = `\\[${projectCategory}/${projectName}\]`;

        // Session title
        const sessionID = event.properties.sessionID;
        const { data: currentSession } = await client.session.get({
          path: { id: sessionID },
        });

        if (!currentSession) return;
        if (currentSession.parentID) return; // Ignore child sessions

        const sessionTitle = currentSession.title;

        if (sessionTitle === "ai-commit") {
          await client.session.delete({
            path: { id: sessionID },
          });

          return;
        }

        const isDefaultTitle = sessionTitle.startsWith("New session - ");
        const message =
          sessionTitle && !isDefaultTitle ? sessionTitle : "Agent run complete";

        const onClick = `osascript \
          -e 'tell application "Ghostty" to activate' \
          -e 'tell application "System Events" to key code 49 using control down' \
          -e 'tell application "System Events" to keystroke ":"' \
          -e 'delay 0.1' \
          -e 'tell application "System Events" to keystroke "switch-client -t ${projectName}:3"' \
          -e 'tell application "System Events" to key code 36'`;

        Bun.spawn([
          'terminal-notifier',
          '-title', 'opencode',
          '-subtitle', subtitle,
          '-message', message,
          '-group', `opencode-${projectName}-${sessionID}`,
          '-execute', onClick
        ]);
      }
    },
  };
};
