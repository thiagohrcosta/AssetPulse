import { CheckIcon } from "@/components/icons";

const STEPS = ["Account", "Company", "Plan"];

interface StepIndicatorProps {
  /** 1-based index of the current step. */
  current: number;
}

// Shared across the three-step signup flow: register -> company/new ->
// subscription. Each page owns its own form; this just shows where the
// visitor is in that flow.
export function StepIndicator({ current }: StepIndicatorProps) {
  return (
    <ol className="mb-8 flex items-center gap-2">
      {STEPS.map((label, i) => {
        const step = i + 1;
        const done = step < current;
        const active = step === current;

        return (
          <li key={label} className="flex flex-1 items-center gap-2 last:flex-none">
            <div className="flex items-center gap-2">
              <span
                className={`flex size-7 shrink-0 items-center justify-center rounded-full text-xs font-semibold transition ${
                  done
                    ? "bg-brand-navy text-white dark:bg-white dark:text-brand-navy"
                    : active
                      ? "bg-brand-red text-white"
                      : "bg-zinc-200 text-zinc-500 dark:bg-zinc-800 dark:text-zinc-400"
                }`}
              >
                {done ? <CheckIcon className="size-3.5" /> : step}
              </span>
              <span
                className={`hidden text-sm font-medium sm:inline ${
                  active
                    ? "text-zinc-900 dark:text-zinc-50"
                    : done
                      ? "text-zinc-700 dark:text-zinc-300"
                      : "text-zinc-400 dark:text-zinc-500"
                }`}
              >
                {label}
              </span>
            </div>
            {step !== STEPS.length && (
              <span
                className={`h-px flex-1 ${done ? "bg-brand-navy dark:bg-white" : "bg-zinc-200 dark:bg-zinc-800"}`}
                aria-hidden
              />
            )}
          </li>
        );
      })}
    </ol>
  );
}
