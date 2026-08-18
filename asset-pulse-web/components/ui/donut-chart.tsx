export interface DonutSegment {
  label: string;
  value: number;
  /** A `--color-*` Tailwind class, e.g. "text-chart-1". Read via currentColor
   * so the swatch and the arc always match. */
  colorClassName: string;
}

interface DonutChartProps {
  segments: DonutSegment[];
  centerLabel?: string;
  centerValue?: string | number;
}

const SIZE = 160;
const STROKE = 22;
const RADIUS = (SIZE - STROKE) / 2;
const CIRCUMFERENCE = 2 * Math.PI * RADIUS;
// A hairline gap between adjacent arcs, matching the "surface gap between
// fills" rule for stacked/adjacent marks.
const GAP = 3;

export function DonutChart({ segments, centerLabel, centerValue }: DonutChartProps) {
  const total = segments.reduce((sum, s) => sum + s.value, 0);
  let offset = 0;

  return (
    <div className="flex flex-col items-center gap-5 sm:flex-row sm:items-center sm:justify-center">
      <div className="relative shrink-0" style={{ width: SIZE, height: SIZE }}>
        <svg width={SIZE} height={SIZE} viewBox={`0 0 ${SIZE} ${SIZE}`} className="-rotate-90">
          <circle
            cx={SIZE / 2}
            cy={SIZE / 2}
            r={RADIUS}
            fill="none"
            className="stroke-zinc-100 dark:stroke-zinc-800"
            strokeWidth={STROKE}
          />
          {total > 0 &&
            segments
              .filter((s) => s.value > 0)
              .map((segment) => {
                const length = (segment.value / total) * CIRCUMFERENCE;
                const dash = Math.max(length - GAP, 0);
                const el = (
                  <circle
                    key={segment.label}
                    cx={SIZE / 2}
                    cy={SIZE / 2}
                    r={RADIUS}
                    fill="none"
                    className={`${segment.colorClassName} transition-opacity hover:opacity-80`}
                    stroke="currentColor"
                    strokeWidth={STROKE}
                    strokeDasharray={`${dash} ${CIRCUMFERENCE - dash}`}
                    strokeDashoffset={-offset}
                    strokeLinecap="round"
                  >
                    <title>
                      {segment.label}: {segment.value} ({Math.round((segment.value / total) * 100)}%)
                    </title>
                  </circle>
                );
                offset += length;
                return el;
              })}
        </svg>
        {(centerLabel || centerValue !== undefined) && (
          <div className="pointer-events-none absolute inset-0 flex flex-col items-center justify-center">
            {centerValue !== undefined && (
              <span className="text-2xl font-semibold text-zinc-900 dark:text-zinc-50">
                {centerValue}
              </span>
            )}
            {centerLabel && (
              <span className="text-xs text-zinc-500 dark:text-zinc-400">{centerLabel}</span>
            )}
          </div>
        )}
      </div>

      <ul className="flex w-full flex-col gap-2 sm:w-auto">
        {segments.map((segment) => (
          <li key={segment.label} className="flex items-center gap-2 text-sm">
            <span className={`size-2.5 shrink-0 rounded-sm ${segment.colorClassName} bg-current`} />
            <span className="flex-1 text-zinc-600 dark:text-zinc-400">{segment.label}</span>
            <span className="font-medium text-zinc-900 dark:text-zinc-50">
              {total > 0 ? Math.round((segment.value / total) * 100) : 0}%
            </span>
          </li>
        ))}
      </ul>
    </div>
  );
}
