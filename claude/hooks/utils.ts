import { readFileSync } from "fs";

const findLastEntry = (transcriptContent: string, type: string) => {
  const index = transcriptContent.lastIndexOf(`"type":"${type}"`);
  if (index === -1) return null;
  const start = transcriptContent.lastIndexOf("\n", index) + 1;
  const end = transcriptContent.indexOf("\n", index);
  return JSON.parse(
    transcriptContent.slice(start, end === -1 ? undefined : end),
  );
};

// Title entries get re-appended over time, so the newest one wins.
// A /rename (custom-title) beats the generated ai-title.
const getSessionTitle = (transcriptContent: string) =>
  findLastEntry(transcriptContent, "custom-title")?.customTitle ??
  findLastEntry(transcriptContent, "ai-title")?.aiTitle ??
  null;

const extractFromXml = (text: string) => {
  const afterXml = text.replace(/<[^>]+>[^<]*<\/[^>]+>/g, "").trim();
  if (afterXml && !afterXml.startsWith("<")) return afterXml;
  return null;
};

const extractText = (content: unknown): string | null => {
  if (typeof content === "string") return content;
  if (Array.isArray(content)) {
    const textBlock = content.findLast(
      (block: { type: string }) => block.type === "text",
    );
    return textBlock?.text ?? null;
  }
  return null;
};

const getFirstPrompt = (transcriptContent: string) => {
  for (const line of transcriptContent.split("\n")) {
    if (!line.trim()) continue;
    const entry = JSON.parse(line);
    if (entry.type !== "user" || entry.isMeta) continue;
    const text =
      extractText(entry.content) ?? extractText(entry.message?.content);
    if (!text) continue;
    if (!text.startsWith("<")) return text;
    const extracted = extractFromXml(text);
    if (extracted) return extracted;
  }
  return null;
};

export const getSessionName = (transcriptPath: string) => {
  try {
    const transcriptContent = readFileSync(transcriptPath, "utf-8");
    const title =
      getSessionTitle(transcriptContent) ?? getFirstPrompt(transcriptContent);
    if (!title) return null;
    const name = title.trim().slice(0, 50).replace(/\n/g, " ");
    return name.length < title.length ? `${name.trimEnd()}…` : name;
  } catch {
    return null;
  }
};

export const getLastAssistantMessage = (transcriptPath: string) => {
  try {
    const lines = readFileSync(transcriptPath, "utf-8").split("\n");
    for (let i = lines.length - 1; i >= 0; i--) {
      if (!lines[i].trim()) continue;
      const entry = JSON.parse(lines[i]);
      if (entry.type !== "assistant") continue;
      const text = extractText(entry.message?.content);
      if (text) return text;
    }
  } catch {}
  return null;
};
