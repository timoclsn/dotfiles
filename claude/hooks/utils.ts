import { homedir } from "os";
import { readFileSync } from "fs";

interface SessionEntry {
  sessionId: string;
  customTitle?: string;
}

interface SessionsIndex {
  entries: SessionEntry[];
}

const getCustomTitle = (projectDir: string, sessionId: string) => {
  try {
    const encodedPath = "-" + projectDir.split("/").slice(1).join("-");
    const indexPath = `${homedir()}/.claude/projects/${encodedPath}/sessions-index.json`;
    const index: SessionsIndex = JSON.parse(readFileSync(indexPath, "utf-8"));
    return index.entries.find((e) => e.sessionId === sessionId)?.customTitle;
  } catch {
    return null;
  }
};

const getFirstPrompt = (transcriptPath: string) => {
  try {
    const content = readFileSync(transcriptPath, "utf-8");
    for (const line of content.split("\n")) {
      if (!line.trim()) continue;
      const entry = JSON.parse(line);
      if (entry.type !== "user" || entry.isMeta) continue;
      const text =
        (typeof entry.content === "string" ? entry.content : null) ??
        entry.message?.content;
      if (text && !text.startsWith("<")) return text;
    }
  } catch {}
  return null;
};

interface GetSessionNameOptions {
  projectDir: string;
  sessionId: string;
  transcriptPath: string;
}

export const getSessionName = ({
  projectDir,
  sessionId,
  transcriptPath,
}: GetSessionNameOptions) => {
  const title =
    getCustomTitle(projectDir, sessionId) ?? getFirstPrompt(transcriptPath);
  if (!title) return null;
  const name = title.slice(0, 30).replace(/\n/g, " ");
  return name.length < title.length ? `${name}…` : name;
};
