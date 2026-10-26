#!/usr/bin/env bun
import { homedir } from "node:os";

// Tracks Claude usage for the tmux status bar and notifications, for the
// account Claude Code uses: the login for CLAUDE_CONFIG_DIR, or the default
// login when that's unset or empty.
//
//   claude-budget status  print "<ok|warning|error><TAB><summary>" for the tmux status bar
//   claude-budget json    print the usage numbers
//
// The work (Enterprise) account has a monthly spend limit, tracked in dollars:
// what's left of it is spread evenly over the month's remaining workdays. The
// personal (Pro/Max) account only has the subscription's 5-hour and weekly
// limits, shown as percentages. The usage comes from the same endpoint Claude
// Code's `/usage` screen reads. It only has the month-to-date spend, so the
// last spend seen is cached locally to know where each day started. The spend
// limit resets on the 1st of the month at 00:00 UTC, so all day and month
// boundaries here are in UTC.

interface Spend {
  kind: "spend";
  usedCents: number;
  // Month-to-date spend at the start of today, so today's own spend doesn't
  // shrink today's share
  usedBeforeTodayCents: number;
  limitCents: number;
}

interface Subscription {
  kind: "subscription";
  sessionPercent: number;
  weeklyPercent: number;
}

type Usage = Spend | Subscription;

interface Money {
  amount_minor: number;
  exponent: number;
}

interface UsageWindow {
  utilization?: number | null;
}

interface UsageResponse {
  five_hour?: UsageWindow | null;
  seven_day?: UsageWindow | null;
  spend?: { used: Money; limit: Money | null } | null;
}

// --- Spend budget math (pure) -----------------------------------------------

// Warn when less than this share of today's budget is left
const LOW_BUDGET_SHARE = 0.2;
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

const getBudget = ({ usedCents, usedBeforeTodayCents, limitCents }: Spend, now: Date) => {
  // Today always counts, so weekend work gets a share too and the month never
  // runs out of days to spread the rest over. Each workday is at 00:00 UTC, so
  // only the ones after today are later than now.
  const daysLeft = workdaysInMonth(now).filter((day) => day > now).length + 1;
  // What was left at the start of today, spread evenly over the days left
  const todayShareCents = (limitCents - usedBeforeTodayCents) / daysLeft;

  return {
    usedCents,
    limitCents,
    todayShareCents,
    // What can still be spent today; negative when over
    leftTodayCents: todayShareCents - (usedCents - usedBeforeTodayCents),
  };
};

type Budget = ReturnType<typeof getBudget>;

const getBudgetHealth = (budget: Budget) => {
  if (budget.usedCents >= budget.limitCents || budget.leftTodayCents < 0) return "error";
  if (budget.leftTodayCents < budget.todayShareCents * LOW_BUDGET_SHARE) return "warning";
  return "ok";
};

const dollars = (cents: number) => `$${Math.round(cents / 100)}`;

// What's left today, e.g. "$83", or "-$12" when over
const formatToday = (budget: Budget) =>
  budget.leftTodayCents < 0 ? `-${dollars(-budget.leftTodayCents)}` : dollars(budget.leftTodayCents);

const formatBudgetSummary = (budget: Budget) => {
  const month = `${dollars(budget.usedCents)}/${Math.round(budget.limitCents / 100)}`;
  return `${TODAY_ICON} ${formatToday(budget)}  ${MONTH_ICON} ${month}`;
};

const formatBudgetWarning = (budget: Budget) => {
  if (budget.usedCents >= budget.limitCents) {
    return `⚠ Monthly Claude limit reached (${dollars(budget.usedCents)} of ${dollars(budget.limitCents)})`;
  }
  return budget.leftTodayCents < 0
    ? `⚠ Claude budget: ${dollars(-budget.leftTodayCents)} over for today`
    : `⚠ Claude budget: only ${dollars(budget.leftTodayCents)} left for today`;
};

// --- Subscription usage math (pure) -----------------------------------------

// Share of a usage limit used at which to warn, and at which to show an error
const WARNING_PERCENT = 75;
const ERROR_PERCENT = 90;

const getSubscriptionHealth = ({ sessionPercent, weeklyPercent }: Subscription) => {
  const highestPercent = Math.max(sessionPercent, weeklyPercent);
  if (highestPercent >= ERROR_PERCENT) return "error";
  if (highestPercent >= WARNING_PERCENT) return "warning";
  return "ok";
};

const formatSubscriptionSummary = ({ sessionPercent, weeklyPercent }: Subscription) =>
  `5h ${sessionPercent}%  7d ${weeklyPercent}%`;

const formatSubscriptionWarning = ({ sessionPercent, weeklyPercent }: Subscription) =>
  sessionPercent >= weeklyPercent
    ? `⚠ Claude usage: ${sessionPercent}% of the 5-hour limit used`
    : `⚠ Claude usage: ${weeklyPercent}% of the weekly limit used`;

// --- Report (pure) ----------------------------------------------------------

const reportBudget = (spend: Spend, now: Date) => {
  const budget = getBudget(spend, now);
  return {
    numbers: budget,
    health: getBudgetHealth(budget),
    summary: formatBudgetSummary(budget),
    warning: formatBudgetWarning(budget),
  };
};

const reportSubscription = (subscription: Subscription) => ({
  numbers: subscription,
  health: getSubscriptionHealth(subscription),
  summary: formatSubscriptionSummary(subscription),
  warning: formatSubscriptionWarning(subscription),
});

// The usage numbers, health, the status bar summary, and a line for
// notifications (null while usage is fine), for either kind of account
export const getReport = (usage: Usage, now: Date) => {
  const { numbers, health, summary, warning } =
    usage.kind === "spend" ? reportBudget(usage, now) : reportSubscription(usage);

  if (health === "ok") return { numbers, health, summary, warning: null };
  // A text marker as well as the colour, so the state is readable without colour
  return { numbers, health, summary: `⚠ ${summary}`, warning };
};

// --- I/O --------------------------------------------------------------------

const CACHE_DIR = `${homedir()}/.cache/claude-budget`;

// Claude Code names the keychain entry after the config dir when
// CLAUDE_CONFIG_DIR is set: the first 8 hex digits of its SHA-256
const getKeychainService = () => {
  const configDir = process.env.CLAUDE_CONFIG_DIR;
  if (!configDir) return "Claude Code-credentials";
  const hash = new Bun.CryptoHasher("sha256").update(configDir).digest("hex");
  return `Claude Code-credentials-${hash.slice(0, 8)}`;
};

const readAccessToken = async () => {
  const result = await Bun.$`security find-generic-password -s ${getKeychainService()} -w`
    .quiet()
    .nothrow();
  if (result.exitCode !== 0) return null;
  const credentials = JSON.parse(result.text()) as { claudeAiOauth?: { accessToken?: string } };
  return credentials.claudeAiOauth?.accessToken ?? null;
};

interface SpendCache {
  day: string;
  usedCents: number;
  usedBeforeTodayCents: number;
}

// A missing, half-written or outdated cache file counts as no cache
const toSpendCache = (value: unknown): SpendCache | null => {
  if (typeof value !== "object" || value === null) return null;
  const { day, usedCents, usedBeforeTodayCents } = value as Record<keyof SpendCache, unknown>;
  if (typeof day !== "string") return null;
  if (typeof usedCents !== "number" || typeof usedBeforeTodayCents !== "number") return null;
  return { day, usedCents, usedBeforeTodayCents };
};

// Where today started, from the last lookup's cache. On the first lookup of a
// day that's the last spend seen before it, so spend before that lookup still
// counts as today's; the month's spend starts again at 0 on the 1st.
const startOfTodayCents = (cached: SpendCache | null, usedCents: number, today: string) => {
  // Nothing to go on yet, so count all spend so far as before today
  if (!cached) return usedCents;
  if (cached.day === today) return cached.usedBeforeTodayCents;
  if (cached.day.slice(0, 7) === today.slice(0, 7)) return cached.usedCents;
  return 0;
};

// The month-to-date spend at the start of today, per account. Every lookup
// records the spend it saw.
const getUsedBeforeTodayCents = async (usedCents: number, now: Date) => {
  const file = Bun.file(`${CACHE_DIR}/${getKeychainService()}.json`);
  const today = toDateKey(now);
  const cached = toSpendCache(await file.json().catch(() => null));
  const usedBeforeTodayCents = startOfTodayCents(cached, usedCents, today);

  await Bun.write(file, JSON.stringify({ day: today, usedCents, usedBeforeTodayCents }));
  return usedBeforeTodayCents;
};

// Amounts come in minor units with a given exponent; normalise to cents
const toCents = ({ amount_minor, exponent }: Money) => amount_minor / 10 ** (exponent - 2);

const toUsage = ({ spend, five_hour, seven_day }: UsageResponse) => {
  if (spend?.limit) {
    return {
      kind: "spend" as const,
      usedCents: toCents(spend.used),
      limitCents: toCents(spend.limit),
    };
  }
  // A window without usage data counts as unused
  const toPercent = (window?: UsageWindow | null) => Math.round(window?.utilization ?? 0);
  if (five_hour || seven_day) {
    return {
      kind: "subscription" as const,
      sessionPercent: toPercent(five_hour),
      weeklyPercent: toPercent(seven_day),
    };
  }
  throw new Error("Usage response has neither a spend limit nor subscription limits");
};

export const fetchUsage = async (now: Date) => {
  const token = await readAccessToken();
  if (!token) throw new Error("No Claude Code login found in the keychain");

  const response = await fetch("https://api.anthropic.com/api/oauth/usage", {
    headers: { Authorization: `Bearer ${token}`, "anthropic-beta": "oauth-2025-04-20" },
    // Short, because notifications wait for this lookup; it usually takes under a second
    signal: AbortSignal.timeout(2000),
  });
  if (!response.ok) throw new Error(`Usage request failed with ${response.status}`);

  const usage = toUsage((await response.json()) as UsageResponse);
  if (usage.kind === "subscription") return usage;
  return {
    ...usage,
    usedBeforeTodayCents: await getUsedBeforeTodayCents(usage.usedCents, now),
  } satisfies Spend;
};

const main = async () => {
  const command = process.argv[2] ?? "status";
  if (command !== "status" && command !== "json") {
    console.error(`Unknown command: ${command}`);
    process.exit(1);
  }

  // A failed fetch exits non-zero, so tmux-powerkit keeps showing the last
  // output and marks it as stale
  const now = new Date();
  const { numbers, health, summary } = getReport(await fetchUsage(now), now);

  if (command === "json") {
    console.log(JSON.stringify(numbers, null, 2));
    return;
  }
  console.log(`${health}\t${summary}`);
};

if (import.meta.main) main();
