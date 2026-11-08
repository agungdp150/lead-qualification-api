# Directory structure

Adapted from Luce Backend's `doc/contributing/directory-structure-and-naming.md`: domain components, purpose-based subdirectories, namespaced classes, service suffixes, a component documentation entry point, and matching RSpec folders.

```text
app/
  components/
    lead_scoring_component/
      docs/
        README.md
      helpers/
        evidence_helper.rb
        transcript_helper.rb
      interactors/
        score_lead.rb
      services/
        evidence_extractor_service.rb
        scoring_policy_service.rb
  controllers/
    api/
      scores_controller.rb
    application_controller.rb
    errors_controller.rb
    health_controller.rb
  errors/
    scoring_error.rb
api/
  index.rb
config/
  application.rb
  boot.rb
  environment.rb
  routes.rb
doc/
  directory-structure.md
lib/
  vercel_adapter.rb
scripts/
  verify_live.rb
spec/
  components/
    lead_scoring_component/
      helpers/
        evidence_helper_spec.rb
      interactors/
        score_lead_spec.rb
      services/
        evidence_extractor_service_spec.rb
        scoring_policy_service_spec.rb
  fixtures/
    lead_scoring/
  lib/
    vercel_adapter_spec.rb
  requests/
    api/
      scores_spec.rb
    health_spec.rb
  support/
    lead_scoring_helpers.rb
  rails_helper.rb
  spec_helper.rb
```

## Request flow

`POST /api/score` → `Api::ScoresController#create` → `LeadScoringComponent::Interactors::ScoreLead.call`.

The interactor coordinates `Helpers::TranscriptHelper`, `Services::EvidenceExtractorService`, and `Services::ScoringPolicyService`. Evidence structure and provenance are checked by `Helpers::EvidenceHelper`. HTTP concerns stay in controllers; `ApplicationController` renders shared scoring errors.

Rails' normal Zeitwerk loading maps each component directory to its namespace. No custom loader or global class aliases are required.

## Scope of the adaptation

This service keeps the assessment's JSON HTTP contract. Its single interactor is a plain Ruby class exposing `.call`; it does not need Luce's application-specific BaseInteractor or GraphQL context. The stateless feature has no database, workers, or models.

RSpec specs mirror the implementation. Shared fixture and provider helpers live in `spec/support`. Provider responses remain explicit WebMock fixtures because API credentials were deferred; they are not presented as recorded live API traffic.

```sh
bundle exec rspec
bundle exec rspec spec/components/lead_scoring_component
bundle exec rspec spec/requests
```

`bundle exec rake spec` is also supported; `rake test` remains an alias for compatibility with earlier instructions.
