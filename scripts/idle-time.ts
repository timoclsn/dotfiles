export const IDLE_THRESHOLD = 60;

export const getIdleTime = async () => {
  const proc = Bun.spawn(["ioreg", "-c", "IOHIDSystem", "-d", "4"]);
  const output = await new Response(proc.stdout).text();
  const match = output.match(/"HIDIdleTime"\s*=\s*(\d+)/);
  if (!match) return 0;
  return Number(match[1]) / 1_000_000_000;
};
