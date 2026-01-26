interface HookInput {
  tool_input: {
    file_path: string;
  };
}

const main = async () => {
  const input: HookInput = await Bun.stdin.json();
  const filePath = input.tool_input.file_path;

  await Bun.spawn(["npx", "prettier", "--write", "--ignore-unknown", filePath], {
    stdout: "inherit",
    stderr: "inherit",
  }).exited;
};

main();
