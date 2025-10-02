# Repository Guidelines

## Project Structure & Module Organization
Engine code lives under `app/`, mirroring a standard Rails engine: controllers, components, and views compose admin UI, while `app/assets` and `app/javascript/koi` hold the source for bundles shipped via Rollup. Shared Ruby modules and tasks sit in `lib/`, including generators and Rake extensions. Specs reside in `spec/`, with the `spec/dummy` Rails app providing an integration harness; treat it as disposable scaffolding, not a source of production logic.

## Build, Test, and Development Commands
Run `bin/setup` once to install gem and JavaScript dependencies and to scaffold the dummy app. Use `bundle exec rake build` to compile assets (`yarn build`) and prepare the engine. `bundle exec rspec` exercises the full suite; pair it with `bundle exec rake lint` to run RuboCop, ERB lint, and Prettier checks. For interactive demos, launch the sandboxed host app with `bin/dev`, which proxies to `spec/dummy/bin/dev`.

## Coding Style & Naming Conventions
Ruby follows the `rubocop-katalyst` profile: two-space indentation, snake_case for methods and variables, and CamelCase for classes/modules. Prefer service objects and view components that live alongside peers in `app/components`. JavaScript and stylesheet changes should pass Prettier's default formatting; keep ES modules colocated with their Rails counterpart under `app/javascript/koi`. When extending generators or Rake tasks, namespaced constants should sit under `Katalyst::Koi` to avoid collisions.

## Testing Guidelines
Author specs with RSpec; name files `*_spec.rb` within the matching directory (e.g., `spec/components`). Exercise factories via `spec/factories` and update fixtures only when assertions demand it. System specs should target the dummy app flows; reset state with provided helpers in `spec/support`. Before raising a PR, ensure `bundle exec rspec` passes locally and add coverage for each new behaviour or regression fix.

## Commit & Pull Request Guidelines
Commits in this repo favour short, descriptive subjects in sentence case (e.g., `Fix input size for select elements` or `Churn: update dependencies`). Group unrelated changes into separate commits to keep rollbacks trivial. Pull requests should summarise intent, reference any Katalyst issue IDs, and include screenshots or GIFs for admin UI tweaks. Mention required follow-up migrations or configuration changes explicitly so downstream applications can plan upgrades.

## Security & Maintenance
Run `bundle exec rake security` before releases to scan the engine with Brakeman. Keep Rollup outputs clean by running `yarn clean` when removing assets, and verify the dummy app still boots after dependency updates to catch breaking Rails changes early.
