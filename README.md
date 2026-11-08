# Lead Qualification API

A stateless Rails API accepts `POST /api/score` and returns the original lead ID, a 0–100 score, tier, routing, and two-sentence rationale.

I chose `gpt-4.1-mini-2025-04-14` for a focused structured-extraction task. One call extracts commercial signals; Ruby validates exact lead-message citations and applies explicit scoring rules. This separates interpretation from business policy. Actual model accuracy and latency still require live verification after credentials are configured.

Gemini testing is also supported through `LLM_PROVIDER=gemini` and `GEMINI_API_KEY`, using `gemini-3.8-flash`. Record the provider actually deployed before submitting.

Weights prioritize recurring container volume (30), import readiness (25), beverage fit (25), and business credibility (20). Hot starts at 75, Warm at 40. Pending licensing prevents Hot routing. Unknown information stays Warm for qualification; explicit personal consumption or unrelated products is Cold. Scores express prioritization, not calibrated conversion probabilities.

The brief conflicts on Warm routing. I follow its stated business rule: Hot → KAM, Warm → nurture, Cold → archive. Experienced importers can reach Hot without an explicitly stated license; the handoff still requires verification.

Inputs are bounded and validated. Provider errors return JSON errors, never fabricated scores. The provider has a 20-second deadline without retries. Keys stay in environment variables.

With more time: evaluate extraction against independently labeled conversations, calibrate thresholds against sales outcomes, measure cold-start latency, and add durable rate limiting.

See [DEPLOY.md](DEPLOY.md) for setup, [component documentation](app/components/lead_scoring_component/docs/README.md) for the exact policy, and [TESTING.md](TESTING.md) for verification and limitations.

The code follows Luce Backend's domain component conventions. See [directory structure](doc/directory-structure.md) for the request flow and matching specs.
