import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

export const IDLE_THRESHOLD = 60;

export const getIdleTime = async () => {
  try {
    if (typeof Bun !== "undefined" && Bun.spawn) {
      const proc = Bun.spawn(["ioreg", "-c", "IOHIDSystem", "-d", "4"]);
      const output = await new Response(proc.stdout).text();
      const match = output.match(/"HIDIdleTime"\s*=\s*(\d+)/);
      if (!match) return 0;
      return Number(match[1]) / 1_000_000_000;
    }

    const { stdout } = await execFileAsync("ioreg", [
      "-c",
      "IOHIDSystem",
      "-d",
      "4",
    ]);
    const match = stdout.match(/"HIDIdleTime"\s*=\s*(\d+)/);
    if (!match) return 0;
    return Number(match[1]) / 1_000_000_000;
  } catch {
    return 0;
  }
};

