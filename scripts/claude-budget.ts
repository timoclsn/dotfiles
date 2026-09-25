#!/usr/bin/env bun
// Tracks the official Claude Enterprise spend against the monthly spend limit.
//
//   claude-budget status  print "<ok|warning|error><TAB><summary>" for the tmux status bar
//   claude-budget json    print the budget numbers
//
// The spend comes from the same endpoint Claude Code's `/usage` screen reads,
// authenticated with the login Claude Code keeps in the macOS keychain. Nothing
// is stored: callers decide how often to ask (tmux-powerkit caches the output).
// The limit resets on the 1st of the month at 00:00 UTC, so all day and month
// boundaries here are in UTC.

interface Spend {
  usedCents: number;
  limitCents: number;
}

interface UsageResponse {
  spend?: {
    used: { amount_minor: number; exponent: number };
    limit: { amount_minor: number; exponent: number };
  };
}

// --- Budget math (pure) -----------------------------------------------------

// Warn when less than this share of an average workday's budget is left today
const LOW_BUDGET_SHARE = 0.2;
const BAR_CELLS = 10;
// Nerd Font icons: md-calendar_today and md-calendar_month
const TODAY_ICON = "\u{F00F6}";
const MONTH_ICON = "\u{F0E17}";

const toDateKey = (date: Date) => date.toISOString().slice(0, 10);

const isWorkday = (date: Date) => date.getUTCDay() !== 0 && date.getUTCDay() !== 6;

const workdaysInMonth = (date: Date) => {
  const year = date.getUTCFullYear();
  const month = date.getUTCMonth();
  const daysInMonth = new Date(Date.UTC(year, month + 1, 0)).getUTCDate();
  return Array.from(
    { length: daysInMonth },
    (_, index) => new Date(Date.UTC(year, month, index + 1)),
  ).filter(isWorkday);
};

export const getBudget = ({ usedCents, limitCents }: Spend, now: Date) => {
  const workdays = workdaysInMonth(now);
  const today = toDateKey(now);
  const workdaysThroughToday = workdays.filter((day) => toDateKey(day) <= today).length;
  const workdaysBeforeToday = workdaysThroughToday - (isWorkday(now) ? 1 : 0);
  const msSinceMidnight = now.getTime() - new Date(`${today}T00:00:00Z`).getTime();
  const todayDone = isWorkday(now) ? msSinceMidnight / (24 * 60 * 60 * 1000) : 0;
  // The limit spread evenly over the month's workdays: where spend should be by
  // the end of today, and where it should be right now
  const endOfTodayPaceCents = (limitCents * workdaysThroughToday) / workdays.length;
  const currentPaceCents = (limitCents * (workdaysBeforeToday + todayDone)) / workdays.length;

  return {
    usedCents,
    limitCents,
    currentPaceCents,
    // What can still be spent today while staying on pace; negative when over
    leftTodayCents: endOfTodayPaceCents - usedCents,
    workdayShareCents: limitCents / workdays.length,
  };
};

type Budget = ReturnType<typeof getBudget>;

export const getHealth = (budget: Budget) => {
  if (budget.usedCents >= budget.limitCents || budget.leftTodayCents < 0) return "error";
  if (budget.leftTodayCents < budget.workdayShareCents * LOW_BUDGET_SHARE) return "warning";
  return "ok";
};

const dollars = (cents: number) => `$${Math.round(cents / 100)}`;

// Month spend as a bar with a marker between the cells where spend should be
// right now: "▒▒▒▒▒▒▒▒░│░" is under pace, "▒▒▒▒▒│▒░░░░" is over it
export const formatMonthBar = (budget: Budget) => {
  const toCells = (cents: number) => Math.round((cents / budget.limitCents) * BAR_CELLS);
  const filledCells = Math.min(toCells(budget.usedCents), BAR_CELLS);
  const cells = "▒".repeat(filledCells) + "░".repeat(BAR_CELLS - filledCells);
  const paceCell = toCells(budget.currentPaceCents);

  return `${cells.slice(0, paceCell)}│${cells.slice(paceCell)}`;
};

// What's left today, e.g. "$83", or "-$12" when over
const formatToday = (budget: Budget) =>
  budget.leftTodayCents < 0 ? `-${dollars(-budget.leftTodayCents)}` : dollars(budget.leftTodayCents);

export const formatSummary = (budget: Budget) => {
  const month = `${dollars(budget.usedCents)}/${Math.round(budget.limitCents / 100)}`;
  const summary = `${TODAY_ICON} ${formatToday(budget)}  ${MONTH_ICON} ${formatMonthBar(budget)} ${month}`;
  // A text marker as well as the colour, so the state is readable without colour
  return getHealth(budget) === "ok" ? summary : `⚠ ${summary}`;
};

// One line for notifications, or null while the budget is fine
export const formatWarning = (budget: Budget) => {
  if (getHealth(budget) === "ok") return null;
  if (budget.usedCents >= budget.limitCents) {
    return `⚠ Monthly Claude limit reached (${dollars(budget.usedCents)} of ${dollars(budget.limitCents)})`;
  }
  return budget.leftTodayCents < 0
    ? `⚠ Claude budget: ${dollars(-budget.leftTodayCents)} over for today`
    : `⚠ Claude budget: only ${dollars(budget.leftTodayCents)} left for today`;
};

// --- I/O --------------------------------------------------------------------

const readAccessToken = async () => {
  const result = await Bun.$`security find-generic-password -s ${"Claude Code-credentials"} -w`
    .quiet()
    .nothrow();
  if (result.exitCode !== 0) return null;
  const credentials = JSON.parse(result.text()) as { claudeAiOauth?: { accessToken?: string } };
  return credentials.claudeAiOauth?.accessToken ?? null;
};

export const fetchSpend = async (): Promise<Spend> => {
  const token = await readAccessToken();
  if (!token) throw new Error("No Claude Code login found in the keychain");

  const response = await fetch("https://api.anthropic.com/api/oauth/usage", {
    headers: { Authorization: `Bearer ${token}`, "anthropic-beta": "oauth-2025-04-20" },
    // Short, because notifications wait for this lookup; it usually takes under a second
    signal: AbortSignal.timeout(2000),
  });
  if (!response.ok) throw new Error(`Usage request failed with ${response.status}`);

  const { spend } = (await response.json()) as UsageResponse;
  if (!spend) throw new Error("Usage response has no spend data");

  // Amounts come in minor units with a given exponent; normalise to cents
  const toCents = ({ amount_minor, exponent }: { amount_minor: number; exponent: number }) =>
    amount_minor / 10 ** (exponent - 2);
  return { usedCents: toCents(spend.used), limitCents: toCents(spend.limit) };
};

const main = async () => {
  const command = process.argv[2] ?? "status";
  if (command !== "status" && command !== "json") {
    console.error(`Unknown command: ${command}`);
    process.exit(1);
  }

  // A failed fetch exits non-zero, so tmux-powerkit keeps showing the last
  // output and marks it as stale
  const budget = getBudget(await fetchSpend(), new Date());

  if (command === "json") {
    console.log(JSON.stringify(budget, null, 2));
    return;
  }
  console.log(`${getHealth(budget)}\t${formatSummary(budget)}`);
};

if (import.meta.main) main();
