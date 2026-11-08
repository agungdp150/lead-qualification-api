# Setup and deployment

## Current status

Implementation and local tests are complete. Public deployment and real-model checks are pending account setup. The user requested a blank API key to configure later. No public URL or repository URL has been created; this is not yet a complete submission.

## Local setup

### Gemini option

The local `.env` now selects Gemini for testing:

```dotenv
LLM_PROVIDER=gemini
GEMINI_API_KEY=
GEMINI_MODEL=gemini-3.8-flash
```

Fill in `GEMINI_API_KEY` locally, then load `.env` and restart the server using the commands below. Gemini uses Google's OpenAI-compatible endpoint, with the same evidence schema and scoring rules. A Gemini key must not be placed in `OPENAI_API_KEY`. Select `LLM_PROVIDER=openai` to use the original provider. Only the selected provider's key is required; there is no automatic fallback between providers.

Google reference: [OpenAI compatibility](https://ai.google.dev/gemini-api/docs/openai). Gemini live scoring remains unverified until a real key is configured. For deployment, set `LLM_PROVIDER`, the selected provider's key, and its model in Vercel too.

Use Ruby 3.2 or 3.3 and Bundler 2.6.6. The local verification used Ruby 3.2.2. Vercel documents Ruby 3.3 as its default; cloud compatibility remains to be verified. The lockfile includes macOS ARM and Linux x86_64.

From this `submission/` directory:

```sh
bundle install
cp .env.example .env
```

Edit `.env` locally to set `OPENAI_API_KEY`. It is ignored by Git. The application does not automatically load `.env`; export it in the shell before starting:

```sh
set -a
source .env
set +a
bundle exec rackup -s puma -p 3000
```

Without a key, `GET /health` works and scoring returns `503 configuration_missing`.

```sh
curl -i http://localhost:3000/health
curl -i http://localhost:3000/api/score \
  -H 'Content-Type: application/json' \
  --data-binary @spec/fixtures/lead_scoring/hot.json
bundle exec rspec
```

## Vercel

1. Sign in to Vercel and import `agungdp150/lead-qualification-api`. This repository contains the API directly, so leave Root Directory at the repository root (`./`).
2. Choose the **Other** framework preset. The Ruby function entrypoint is `api/index.rb`; `vercel.json` rewrites requests to it. That entrypoint uses the Rails adapter in `lib/vercel_adapter.rb`.
3. Set `RAILS_ENV=production`, `OPENAI_API_KEY`, and `OPENAI_MODEL=gpt-4.1-mini-2025-04-14` in the project environment. Do not put key values in source control.
4. Deploy from the project dashboard, or from this directory using `npx vercel --prod` after signing in.
5. Ensure the submitted URL is publicly accessible without Vercel authentication. Confirm `/health` before running model checks.
6. Run the live verifier below. If build or routing fails, resolve that before treating deployment as complete. A passing local adapter test does not prove a Vercel deployment.

```sh
bundle exec ruby scripts/verify_live.rb https://YOUR-PROJECT.vercel.app
```

The Ruby runtime is beta. Vercel's runtime source was checked to confirm its handler receives WEBrick requests. Native gem installation, actual request rewrites, production cold starts, and real provider latency still need the deployed smoke test.

## Repository and handoff

Create a GitHub/GitLab repository with reviewer access. Include this directory's source, tests, and lockfile; exclude `.env`, installed dependencies, and local tool output. If using the complete assessment as the repository root, add equivalent secret exclusions at that root too.

Before sending, replace the pending fields below with real values:

- Live endpoint: **pending**
- Code repository: https://github.com/agungdp150/lead-qualification-api
- Actual time spent, including planning: **candidate to record**
- Real-model/live verification: **pending**

Submit the entire assessment folder as a ZIP by reply-all to the recruiter email, with each test's work in its own `submission/` folder. Include both Test 1 URLs and total time.

## References

- Original brief: supplied separately in the assessment package.
- [Vercel Ruby runtime](https://vercel.com/docs/functions/runtimes/ruby)
- [Vercel Ruby handler implementation](https://github.com/vercel/vercel/blob/main/packages/ruby/vc_init.rb)
- [Rails API-only applications](https://guides.rubyonrails.org/api_app.html)
- [OpenAI Structured Outputs](https://developers.openai.com/api/docs/guides/structured-outputs?api-mode=chat)
- [GPT-4.1 mini](https://developers.openai.com/api/docs/models/gpt-4.1-mini)
