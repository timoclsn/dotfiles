import { $ } from "bun";

interface StatusLineInput {
  model: {
    display_name: string;
  };
  workspace: {
    current_dir: string;
    project_dir: string;
  };
  version: string;
  cost: {
    total_cost_usd: number;
    total_duration_ms: number;
    total_lines_added: number;
    total_lines_removed: number;
  };
}

const getGitBranch = async () => {
  try {
    const result = await $`git branch --show-current`.quiet();
    const branch = result.text().trim();
    return branch ? `:${branch}` : "";
  } catch {
    return "";
  }
};

const main = async () => {
  const input: StatusLineInput = await Bun.stdin.json();

  const model = input.model.display_name;
  const dir = input.workspace.current_dir.split("/").pop() ?? "";
  const gitBranch = await getGitBranch();

  console.log(`[${model}]  ${dir}${gitBranch}`);
};

main();
