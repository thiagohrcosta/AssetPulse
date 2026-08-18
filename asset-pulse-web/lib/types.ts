import type { z } from "zod";

import type {
  companySchema,
  planSchema,
  subscriptionSchema,
  subscriptionStatusSchema,
  userSchema,
} from "./schemas";

// Types are inferred from the zod schemas in lib/schemas.ts (single source
// of truth) so the compile-time shape and the runtime validation can never
// drift apart.

export type User = z.infer<typeof userSchema>;
export type Company = z.infer<typeof companySchema>;
export type Plan = z.infer<typeof planSchema>;
export type SubscriptionStatus = z.infer<typeof subscriptionStatusSchema>;
export type Subscription = z.infer<typeof subscriptionSchema>;
