import type { ButtonHTMLAttributes } from "react";

interface SubmitButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  pending?: boolean;
  pendingLabel?: string;
}

export function SubmitButton({
  pending,
  pendingLabel = "Please wait…",
  children,
  disabled,
  className,
  ...rest
}: SubmitButtonProps) {
  return (
    <button
      type="submit"
      disabled={disabled || pending}
      className={`inline-flex items-center justify-center rounded-lg bg-zinc-900 px-4 py-2.5 text-sm font-medium text-white transition hover:bg-zinc-700 disabled:cursor-not-allowed disabled:opacity-60 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200 ${className ?? ""}`}
      {...rest}
    >
      {pending ? pendingLabel : children}
    </button>
  );
}
