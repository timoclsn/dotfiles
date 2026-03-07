interface PushoverParams {
  token: string;
  title: string;
  message: string;
}

export const sendPushover = async ({
  token,
  title,
  message,
}: PushoverParams) => {
  const user = process.env.PUSHOVER_USER_KEY;
  if (!user) return;

  await fetch("https://api.pushover.net/1/messages.json", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ token, user, title, message, priority: 0 }),
  });
};
