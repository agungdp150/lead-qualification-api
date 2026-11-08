# Verification record

## Local checks performed

On November 8, 2026, using Ruby 3.2.2 and Rails 7.2.2.2:

```sh
bundle exec rspec
```

Result: **39 RSpec examples, zero failures** (migrated from the original 21 Minitest tests).

Coverage includes:

- All three supplied transcripts through the Rails request stack, using controlled provider evidence.
- All 540 combinations of evidence categories for bounded scores and consistent routing.
- Missing information and pending-license policy.
- Malformed, oversized, and structurally invalid inputs; unsupported content types and methods.
- Missing credentials, provider errors, timeout, refusal, malformed output, and truncated output.
- Rejection of invented citations, negative indices, and agent messages used as lead evidence.
- Separation of transcript instructions from the system prompt.
- Rails requests through the Vercel adapter.

The Vercel entrypoint also booted locally with `RAILS_ENV=production`; `/health` returned `200 {"status":"ok"}`.

After restructuring into Luce-style components, production eager loading and the same health response were verified again. The RSpec suite covers the same scoring and error behavior, with separate examples for provider statuses and invalid responses.

Real HTTP requests to a local Puma server in production mode confirmed:

- `GET /health`: HTTP 200, JSON `{"status":"ok"}`.
- `POST /api/score` with the Hot fixture and no key: HTTP 503, JSON error code `configuration_missing`.

Linux x86_64 dependencies were resolved against RubyGems and added to the lockfile.

## What remains unverified

- Real model extraction quality and semantic citation accuracy.
- Live prompt-injection resistance and handling of contradictory statements.
- Vercel build, runtime routing, cold starts, and deployed response latency.
- Reviewer access to a code repository and public endpoint.

The user explicitly deferred API key setup. Network calls in unit/request tests are intercepted by WebMock; those tests do not prove live model performance. There is no production fixture fallback.

After configuring credentials and deploying, run:

```sh
bundle exec ruby scripts/verify_live.rb https://YOUR-PROJECT.vercel.app
```

Record the actual output and manually inspect rationales before submission. Exact sample scores are policy examples, not an official answer key.
