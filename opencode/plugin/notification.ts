export const NotificationPlugin = async ({ app, client, $ }) => {
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
