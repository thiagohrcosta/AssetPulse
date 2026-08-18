import { z } from "zod";

// Runtime schemas mirroring swagger/v1/swagger.yaml. Every response coming
// back from asset-pulse-api is parsed through one of these before it
// reaches a component, so a backend contract change fails loudly here
// instead of silently as `undefined` deep inside some JSX.

export const userSchema = z.object({
  id: z.number(),
  email: z.string(),
  full_name: z.string(),
  document_number: z.string(),
  address_zip_code: z.number(),
  address_street: z.string(),
  address_number: z.number(),
  address_city: z.string(),
  address_complement: z.string().nullable(),
  address_state: z.string(),
  access: z.enum(["user", "admin", "company_admin"]),
  created_at: z.string(),
  updated_at: z.string(),
});

export const authResponseSchema = z.object({
  token: z.string(),
  user: userSchema,
});

export const companySchema = z.object({
  id: z.number(),
  name: z.string(),
  registration_number: z.string(),
  address_zip_code: z.number(),
  address_street: z.string(),
  address_number: z.number(),
  address_city: z.string(),
  address_complement: z.string().nullable(),
  address_state: z.string(),
  logo_url: z.string().nullable(),
  created_at: z.string(),
  updated_at: z.string(),
});

export const planSchema = z.object({
  id: z.number(),
  slug: z.enum(["basic", "premium"]),
  name: z.string(),
  amount_cents: z.number(),
  amount: z.number(),
  currency: z.string(),
  interval: z.string(),
  ai_enabled: z.boolean(),
});

export const subscriptionStatusSchema = z.enum([
  "none",
  "trialing",
  "active",
  "past_due",
  "unpaid",
  "canceled",
  "incomplete",
  "incomplete_expired",
]);

export const subscriptionSchema = z.object({
  id: z.number().nullable(),
  status: subscriptionStatusSchema,
  plan: z.string().nullable(),
  trial_ends_at: z.string().nullable(),
  current_period_end: z.string().nullable(),
  cancel_at_period_end: z.boolean().nullable(),
  access_granted: z.boolean(),
});

export const checkoutSessionSchema = z.object({
  checkout_url: z.string(),
});
