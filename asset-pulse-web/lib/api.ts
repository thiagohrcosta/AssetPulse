import { z } from "zod";

import {
  authResponseSchema,
  checkoutSessionSchema,
  companySchema,
  planSchema,
  subscriptionSchema,
} from "./schemas";
import type { Company, Plan, Subscription } from "./types";

// NEXT_PUBLIC_API_URL already includes the /api prefix (see .env), routes
// below only need the /v1/... suffix from config/routes.rb.
const API_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:3000/api";

export class ApiError extends Error {
  status: number;
  fieldErrors?: string[];

  constructor(message: string, status: number, fieldErrors?: string[]) {
    super(message);
    this.name = "ApiError";
    this.status = status;
    this.fieldErrors = fieldErrors;
  }
}

// Every call site passes the zod schema for the response it expects, so a
// backend contract drift throws a clear error here instead of `undefined`
// surfacing silently deep inside a component.
async function request<Schema extends z.ZodType>(
  path: string,
  schema: Schema,
  options: RequestInit & { token?: string } = {}
): Promise<z.infer<Schema>> {
  const { token, headers, ...rest } = options;
  const isFormData = rest.body instanceof FormData;

  const response = await fetch(`${API_URL}${path}`, {
    ...rest,
    headers: {
      Accept: "application/json",
      ...(isFormData ? {} : { "Content-Type": "application/json" }),
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...headers,
    },
  });

  const contentType = response.headers.get("content-type") ?? "";
  const data =
    response.status !== 204 && contentType.includes("application/json")
      ? await response.json()
      : undefined;

  if (!response.ok) {
    const fieldErrors: string[] | undefined = data?.errors;
    const message =
      fieldErrors?.join(", ") ?? data?.error ?? response.statusText ?? "Unexpected error";
    throw new ApiError(message, response.status, fieldErrors);
  }

  const parsed = schema.safeParse(data);
  if (!parsed.success) {
    console.error(`[api] response for ${path} did not match the expected shape`, parsed.error);
    throw new ApiError("Unexpected response from the server", response.status);
  }

  return parsed.data;
}

// ---- Auth -------------------------------------------------------------

export interface RegisterPayload {
  email: string;
  password: string;
  password_confirmation: string;
  full_name: string;
  document_number: string;
  address_zip_code: string;
  address_street: string;
  address_number: string;
  address_city: string;
  address_complement?: string;
  address_state: string;
}

export interface LoginPayload {
  email: string;
  password: string;
}

export type AuthResponse = z.infer<typeof authResponseSchema>;

// POST /api/v1/auth/register — note the fields are sent flat (not nested
// under `user`), see Api::V1::AuthController#user_params.
export function registerUser(payload: RegisterPayload) {
  return request("/v1/auth/register", authResponseSchema, {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export function loginUser(payload: LoginPayload) {
  return request("/v1/auth/login", authResponseSchema, {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

// ---- Companies ----------------------------------------------------------

export interface CompanyPayload {
  name: string;
  registration_number: string;
  address_zip_code: string;
  address_street: string;
  address_number: string;
  address_city: string;
  address_complement?: string;
  address_state: string;
  logo?: File | null;
}

export function listCompanies(token: string): Promise<Company[]> {
  return request("/v1/companies", z.array(companySchema), { token });
}

// POST /api/v1/companies — fields must be nested under `company`, see
// Api::V1::CompaniesController#company_params.
export function createCompany(token: string, payload: CompanyPayload): Promise<Company> {
  const { logo, ...fields } = payload;

  if (logo) {
    const form = new FormData();
    Object.entries(fields).forEach(([key, value]) => {
      if (value !== undefined && value !== null && value !== "") {
        form.append(`company[${key}]`, value);
      }
    });
    form.append("company[logo]", logo);

    return request("/v1/companies", companySchema, { method: "POST", body: form, token });
  }

  return request("/v1/companies", companySchema, {
    method: "POST",
    body: JSON.stringify({ company: fields }),
    token,
  });
}

// ---- Plans ----------------------------------------------------------------

export function listPlans(token: string): Promise<Plan[]> {
  return request("/v1/plans", z.array(planSchema), { token });
}

// ---- Subscriptions ----------------------------------------------------

export function getSubscription(token: string, companyId: number): Promise<Subscription> {
  return request(`/v1/companies/${companyId}/subscription`, subscriptionSchema, { token });
}

export function startTrial(token: string, companyId: number): Promise<Subscription> {
  return request(`/v1/companies/${companyId}/subscription/trial`, subscriptionSchema, {
    method: "POST",
    token,
  });
}

export function createCheckoutSession(
  token: string,
  companyId: number,
  payload: { plan_slug: string; success_url?: string; cancel_url?: string }
) {
  return request(
    `/v1/companies/${companyId}/subscription/checkout_session`,
    checkoutSessionSchema,
    { method: "POST", body: JSON.stringify(payload), token }
  );
}
