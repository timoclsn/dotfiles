import { createGoogleGenerativeAI } from "@ai-sdk/google";
import { tool } from "@opencode-ai/plugin";
import { generateText } from "ai";

const google = createGoogleGenerativeAI({
  apiKey: process.env.GEMINI_API_KEY!,
});

export default tool({
  description:
    "Run a search query to search the internet for results. Use this to look up latest information or find documentation.",
  args: {
    query: tool.schema.string().describe("Keyword or phrase to search for"),
  },
  async execute(args) {
    const { text } = await generateText({
      model: google("gemini-3-flash"),
      tools: {
        google_search: google.tools.googleSearch({}),
      },
      prompt: `Search the web for "${args.query}". Summarize your findings in bullets points. Also list your sources (URLs). Your findings will be used by a coding agent.`,
    });

    return text;
  },
});
