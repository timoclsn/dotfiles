#!/usr/bin/env bun
// Tracks Claude usage for the tmux status bar and notifications, for the
// account Claude Code uses: the login for CLAUDE_CONFIG_DIR, or the default
// login when that's unset or empty.
//
//   claude-budget status  print "<ok|warning|error><TAB><summary>" for the tmux status bar
//   claude-budget json    print the usage numbers
//
// The work (Enterprise) account has a monthly spend limit, tracked in dollars
// against an even pace over the month's workdays. The personal (Pro/Max)
// account only has the subscription's 5-hour and weekly limits, shown as
// percentages. The usage comes from the same endpoint Claude Code's `/usage`
// screen reads. The spend limit resets on the 1st of the month at 00:00 UTC,
// so all day and month boundaries here are in UTC.

interface Spend {
  kind: "spend";
  usedCents: number;
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

// Warn when less than this share of an average workday's budget is left today
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

const getBudget = ({ usedCents, limitCents }: Spend, now: Date) => {
  const workdays = workdaysInMonth(now);
  const today = toDateKey(now);
  const workdaysThroughToday = workdays.filter((day) => toDateKey(day) <= today).length;
  // The limit spread evenly over the month's workdays: where spend should be by
  // the end of today
  const endOfTodayPaceCents = (limitCents * workdaysThroughToday) / workdays.length;

  return {
    usedCents,
    limitCents,
    // What can still be spent today while staying on pace; negative when over
    leftTodayCents: endOfTodayPaceCents - usedCents,
    workdayShareCents: limitCents / workdays.length,
  };
};

type Budget = ReturnType<typeof getBudget>;

const getBudgetHealth = (budget: Budget) => {
  if (budget.usedCents >= budget.limitCents || budget.leftTodayCents < 0) return "error";
  if (budget.leftTodayCents < budget.workdayShareCents * LOW_BUDGET_SHARE) return "warning";
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

// Amounts come in minor units with a given exponent; normalise to cents
const toCents = ({ amount_minor, exponent }: Money) => amount_minor / 10 ** (exponent - 2);

const toUsage = ({ spend, five_hour, seven_day }: UsageResponse): Usage => {
  if (spend?.limit) {
    return { kind: "spend", usedCents: toCents(spend.used), limitCents: toCents(spend.limit) };
  }
  // A window without usage data counts as unused
  const toPercent = (window?: UsageWindow | null) => Math.round(window?.utilization ?? 0);
  if (five_hour || seven_day) {
    return {
      kind: "subscription",
      sessionPercent: toPercent(five_hour),
      weeklyPercent: toPercent(seven_day),
    };
  }
  throw new Error("Usage response has neither a spend limit nor subscription limits");
};

export const fetchUsage = async () => {
  const token = await readAccessToken();
  if (!token) throw new Error("No Claude Code login found in the keychain");

  const response = await fetch("https://api.anthropic.com/api/oauth/usage", {
    headers: { Authorization: `Bearer ${token}`, "anthropic-beta": "oauth-2025-04-20" },
    // Short, because notifications wait for this lookup; it usually takes under a second
    signal: AbortSignal.timeout(2000),
  });
  if (!response.ok) throw new Error(`Usage request failed with ${response.status}`);

  return toUsage((await response.json()) as UsageResponse);
};

const main = async () => {
  const command = process.argv[2] ?? "status";
  if (command !== "status" && command !== "json") {
    console.error(`Unknown command: ${command}`);
    process.exit(1);
  }

  // A failed fetch exits non-zero, so tmux-powerkit keeps showing the last
  // output and marks it as stale
  const { numbers, health, summary } = getReport(await fetchUsage(), new Date());

  if (command === "json") {
    console.log(JSON.stringify(numbers, null, 2));
    return;
  }
  console.log(`${health}\t${summary}`);
};

if (import.meta.main) main();
