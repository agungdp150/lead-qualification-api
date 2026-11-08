# Scoring policy

These are explicit candidate assumptions, not an official answer key or an empirically calibrated predictor. Evidence extraction remains probabilistic even with temperature zero.

| Signal | Values and points |
|---|---|
| Import readiness | Licensed 25; experienced 18; pending 10; none/unknown 0 |
| Beverage product fit | Match 25; mismatch/unknown 0 |
| Volume | At least 1 FCL/month 30; smaller or one-off commercial demand 10; personal/unknown 0 |
| Business credibility | Established 20; new 8; unknown 0 |

Intent is a routing constraint, not another weighted feature.

Apply these rules in order:

1. Sum the four weighted signals.
2. Personal intent, personal quantities, or explicit unrelated-product demand caps the score at 39.
3. Otherwise, floor the score at 40. Missing evidence deserves follow-up rather than automatic archive.
4. Hot eligibility requires licensed/experienced importing, beverage fit, recurring container volume, and wholesale intent. Cap other eligible-to-nurture leads at 74.
5. Map 75–100 to Hot/KAM, 40–74 to Warm/nurture, and 0–39 to Cold/archive.

The floor means the final score is a policy-adjusted priority score. Pending or explicitly absent licensing cannot reach Hot. Import experience is useful evidence but does not prove licensing; the rationale preserves that distinction.

Evidence must use exact substrings from lead messages with valid zero-based indices. Agent statements cannot support classifications. The prompt asks for the latest explicit correction to win. Exact-quote validation verifies provenance, not semantic truth; a live model evaluation is still necessary.

## Supplied examples with controlled extraction

| Example | Calculation | Result |
|---|---|---|
| S001, established UAE distributor | 18 + 25 + 30 + 20 | 93, Hot, `kam_handoff` |
| S002, cans for an office party | 0 + 25 + 0 + 0 | 25, Cold, `auto_archive` |
| S003, Ghana entrant with pending license | 10 + 25 + 30 + 8 | 73, Warm, `nurture_pool` |

These results are verified with authored evidence fixtures. They are not claimed as outputs observed from a live LLM. Hidden evaluation inputs should be judged by contract validity, appropriate routing, grounded reasoning, and latency rather than matching these exact numeric scores.

## Error contract

Errors have the form `{"error":{"code":"...","message":"..."}}` and never include a fake score.

| HTTP status | Condition |
|---|---|
| 400 | Malformed JSON |
| 404 | Unknown route |
| 405 | Wrong method on the scoring route |
| 413 | Request larger than 32 KiB |
| 415 | Content type is not `application/json` |
| 422 | Invalid request fields or messages |
| 502 | Invalid/refused/truncated model response or unsupported provider response |
| 503 | Missing credentials, provider authentication/rate-limit/outage, or connection failure |
| 504 | Provider deadline exceeded |

Input limits: 128 characters for lead ID, 32 for channel, 1–100 messages, 4,000 characters per message, and at least one lead message. Channel is accepted as a descriptive string rather than restricting future sources to WhatsApp/email.
