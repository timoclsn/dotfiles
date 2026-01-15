import { $ } from "bun";

const main = async () => {
  const input = Bun.argv[2] || await Bun.stdin.text();

  await Promise.all([
    $`echo ${input} | bun ${import.meta.dir}/notify.ts`.quiet(),
    $`echo ${input} | bun ${import.meta.dir}/agent-control-center.ts`.quiet(),
  ]);
};

main();
