# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Terminus is a Ruby/Hanami web server for managing TRMNL e-ink display devices on your local network or hosted cloud. It provides a BYOS (Build Your Own Server) implementation compatible with the TRMNL Core server.

## Architecture

### Framework

- **Framework**: Hanami 2.3 (Ruby web framework)
- **Frontend**: htmx for hypermedia-driven UI, Alpine.js for lightweight JS interactions
- **Database**: PostgreSQL with ROM (Ruby Object Mapper)
- **Cache/Queue**: Valkey/Redis with Sidekiq for background jobs
- **Assets**: esbuild via hanami-assets
- **Authentication**: Rodauth via the `authentication` slice
- **Templating**: Hanami views with ERB templates

### Application Structure

```
app/
  actions/        # Controllers - handle HTTP requests, use Deps for DI
  aspects/        # Domain logic: screens, devices, extensions, etc.
  assets/         # CSS and JS (esbuild)
  contracts/      # Dry-validation contracts for form/input validation
  db/             # Database migrations
  jobs/           # Background jobs for Sidekiq
  models/         # ROM models (entities)
  providers/      # Hanami provider configuration
  relations/      # ROM relations (query interface)
  repositories/   # Data access layer, memoized in container
  schemas/        # Dry-schema definitions
  serializers/    # JSON serializers for API responses
  structs/        # Value objects
  templates/      # ERB templates organized by resource
  uploaders/      # Shrine uploaders
  views/          # View layer, exposes data to templates

config/
  app.rb          # Hanami app configuration
  routes.rb       # Route definitions
  settings.rb     # Environment settings

slices/
  authentication/ # Rodauth slice for auth
  health/          # Health check slice

spec/
  app/            # Unit tests mirror app structure
  features/       # Capybara integration tests
  requests/       # API/request specs
```

### Key Patterns

**Actions** (`app/actions/`):
- Inherit from `Terminus::Action`
- Use `Deps[:key]` for dependency injection
- Use `Initable` for constructor injection
- Return data via `response.render view, **data`
- Require authentication by default (via `before :authorize`)

**Views** (`app/views/`):
- Inherit from `Terminus::View`
- Use `Deps` to inject relations/repositories
- Use `expose` to declare data exposed to templates
- Exposures can be simple values or blocks for computed data

**Relations** (`app/relations/`):
- ROM relations for database queries
- Define dataset methods for reusable query logic

**Repositories** (`app/repositories/`):
- Data access layer, memoized in container for caching
- Methods like `all`, `find`, `create`, `update`, `delete`

**Contracts** (`app/contracts/`):
- Dry-validation contracts for input validation
- Inherit from `Terminus::Contract`

## Development Commands

```bash
# Setup (idempotent)
bin/setup

# Run all checks and tests
bin/rake                    # Default: runs quality checks + specs

# Testing
bin/rspec                   # Run all specs
bin/rspec spec/features/dashboard_spec.rb     # Single feature spec
bin/rspec spec/app/actions/dashboard/show_spec.rb  # Single unit spec

# Code Quality
bin/rake quality            # Run all quality checks (rubocop, reek, git-lint, hadolint)
bin/rubocop                 # Ruby style checker

# Development Server
overmind start --port-step 10 --procfile Procfile.dev --can-die assets,migrate
# Or without overmind:
bundle exec puma --config ./config/puma.rb
bundle exec hanami assets watch
bundle exec sidekiq -r ./config/sidekiq.rb

# Console
bin/console                 # Access Hanami console with all deps

# Database
bundle exec hanami db migrate
bundle exec hanami db prepare

# Assets
bundle exec hanami assets compile   # Production
bundle exec hanami assets watch     # Development
```

## Testing

- **RSpec** with Capybara for feature tests (uses Cuprite/headless Chrome)
- **Database Cleaner** with transaction strategy (truncation for JS tests)
- **ROM Factory** for test data factories in `spec/support/factories/`
- **SimpleCov** for coverage (95% minimum line and branch coverage)
- Sidekiq runs inline in test mode

Feature tests in `spec/features/` cover user workflows. Unit tests in `spec/app/` mirror the app structure.

## Environment Variables

Key `.env` variables:
- `DATABASE_URL`: PostgreSQL connection
- `KEYVALUE_URL`: Redis/Valkey connection
- `APP_SECRET`: Session/cookie encryption
- `API_URI`: External URL for device communication
- `HANAMI_PORT`: Server port (default 2300)

## Authentication

- First registered user is auto-verified (admin)
- Subsequent users require manual verification
- Manage account at `/me/login`, `/me/password`

## API

Device API under `/api/` namespace. See `doc/api.adoc` for details. Routes defined in `config/routes.rb`.

## Common Tasks

**Adding a new resource:**
1. Add routes in `config/routes.rb`
2. Create action in `app/actions/{resource}/`
3. Create view in `app/views/{resource}/`
4. Create templates in `app/templates/{resource}/`
5. Add specs

**Database migrations:**
- Place in `app/db/migrate/`
- Run with `bundle exec hanami db migrate`

**Background jobs:**
- Extend `Terminus::Jobs::Base` in `app/jobs/`
- Sidekiq Web UI at `/sidekiq`
