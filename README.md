# Lead Qualification API

A stateless Rails API accepts `POST /api/score` and returns the original lead ID, a 0–100 score, tier, routing, and two-sentence rationale.

The deployed service uses Gemini `gemini-3.1-flash-lite` for structured evidence extraction. I selected it after a lighter-model live check returned the expected routing for the three examples. Ruby validates citations and applies explicit scoring rules, keeping the routing policy inspectable. Model availability and latency remain external dependencies: a later concurrent check returned provider errors for all 10 requests.

Weights prioritize recurring container volume (30), import readiness (25), beverage fit (25), and business credibility (20). Hot starts at 75, Warm at 40. Pending licensing prevents Hot routing. Unknown information stays Warm for qualification; explicit personal consumption or unrelated products is Cold. Scores express prioritization, not calibrated conversion probabilities.

The brief conflicts on Warm routing. I follow its stated business rule: Hot → KAM, Warm → nurture, Cold → archive. Experienced importers can reach Hot without an explicitly stated license; the handoff still requires verification.

Inputs are bounded and validated. Provider errors return JSON errors, never fabricated scores. The provider has a 27-second overall deadline and a 25-second read timeout without retries. Cold starts add overhead; a reviewer observed a 27.5-second response, close to the 30-second requirement. Keys stay in environment variables.

With more time: evaluate extraction against independently labeled conversations, calibrate thresholds against sales outcomes, measure cold-start latency, and add durable rate limiting.

See [DEPLOY.md](DEPLOY.md) for setup, [component documentation](app/components/lead_scoring_component/docs/README.md) for the exact policy, and [TESTING.md](TESTING.md) for verification and limitations.

Domain logic is grouped into a lead-scoring component. See [directory structure](doc/directory-structure.md) for the request flow and matching specs.
