import { homedir } from "os";
import { readFileSync } from "fs";

interface SessionEntry {
  sessionId: string;
  customTitle?: string;
  summary?: string;
}

interface SessionsIndex {
  entries: SessionEntry[];
}

const getSessionTitle = (projectDir: string, sessionId: string) => {
  try {
    const encodedPath = "-" + projectDir.split("/").slice(1).join("-");
    const indexPath = `${homedir()}/.claude/projects/${encodedPath}/sessions-index.json`;
    const index: SessionsIndex = JSON.parse(readFileSync(indexPath, "utf-8"));
    const entry = index.entries.find((e) => e.sessionId === sessionId);
    return entry?.customTitle ?? entry?.summary ?? null;
  } catch {
    return null;
  }
};

const extractFromXml = (text: string) => {
  const afterXml = text.replace(/<[^>]+>[^<]*<\/[^>]+>/g, "").trim();
  if (afterXml && !afterXml.startsWith("<")) return afterXml;
  return null;
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
      if (!text) continue;
      if (!text.startsWith("<")) return text;
      const extracted = extractFromXml(text);
      if (extracted) return extracted;
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
    getSessionTitle(projectDir, sessionId) ?? getFirstPrompt(transcriptPath);
  if (!title) return null;
  const name = title.slice(0, 30).replace(/\n/g, " ");
  return name.length < title.length ? `${name}…` : name;
};
