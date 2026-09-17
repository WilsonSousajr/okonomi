# AGENTS.md — okonomi contributor guide

Single canonical instruction file for AI coding agents in this repository.
`CLAUDE.md` is only a pointer here — do not duplicate rules into it.

## Project overview

okonomi is a web application for **requirements management in projects that use user
stories**. It is the practical assignment for the Software Engineering course
(2026.2). The full brief is `docs/RF/ESW-TRABALHO-PRÁTICO.pdf`.

The system lets an authenticated user keep projects; each project holds **one** product
backlog and **many** sprint backlogs. User stories live in a backlog, may be grouped
under epics, carry acceptance criteria, and are estimated and prioritised with story
points, MoSCoW labels and RICE scoring.

Two things make this repository unusual, and both are deliberate:

- **The brief is the spec.** Every one of the 19 functional requirements in section 2
  of the PDF maps to exactly one issue labelled `RF`. Every one of the 30 instructions
  in section 4 and every bullet of the 9 evaluation criteria in section 5 appears as a
  checkbox inside a deliverable issue. Nothing in the brief is untracked.
- **The project board is itself a graded deliverable.** Evaluation criterion 01 marks
  the Kanban board, the description of each column and the information on each card.
  Sloppy board hygiene costs marks directly — it is not overhead.

**Language convention:** issues, `docs/*` and user-facing copy are written in
**Portuguese**, because they are what gets graded. Code, identifiers, commit types and
this file are written in **English**.

## Technology stack

Versions are pinned exactly and must match across `.mise.toml`, `Gemfile.lock` and
`.github/workflows/ci.yml`. A floating minor silently drifts and the same gate then
passes on CI and fails locally.

- **Ruby 3.4.10**, managed by `mise` (`.mise.toml`). The macOS system Ruby is 2.6 and
  cannot run Rails 8.
- **Rails 8.1.3.1**, full stack — no API-only split, no separate front-end.
- **PostgreSQL 17.** Chosen over SQLite because the domain needs a partial unique index
  (one product backlog per project) and exact `decimal` for RICE Impact.
- **Hotwire** (Turbo + Stimulus), **Propshaft**, **Importmap**. No bundler, no SPA
  framework, no jQuery.
- **Tailwind CSS v4.**
- **Solid Queue / Solid Cache / Solid Cable** — background jobs, cache and websockets
  on Postgres. No Redis.
- **Puma + Thruster**, deployed with **Kamal**.
- **Tests:** Minitest plus Capybara for system tests. Fixtures, not factories.
- **Static analysis:** RuboCop (`rubocop-rails-omakase`), Brakeman, bundler-audit.

## Repository layout

```
app/
├── models/              domain entities and their invariants (see below)
├── controllers/         thin: authenticate, authorise, call a model, render
├── views/               ERB + Turbo frames/streams
├── javascript/          Stimulus controllers only
└── services/            POROs for logic that spans models
config/
db/                      migrations + schema.rb (never edit schema.rb by hand)
test/
├── models/              one file per model, invariants covered explicitly
├── controllers/         authorisation and happy path
├── system/              end-to-end, one per acceptance scenario in the RF issues
└── fixtures/
docs/
├── RF/                  the course brief (PDF) and the .odt templates — DO NOT EDIT
├── PROCESSO.md          artefato 1 — Kanban process description
├── VISAO.md             artefato 2 — vision and scope
├── REQUISITOS-NAO-FUNCIONAIS.md   artefato 3
├── HISTORIAS-DE-USUARIO.md        artefato 4
├── ARQUITETURA.md       artefato 5 — architecture notebook
├── INTERFACE/           artefato 6 — storyboards and wireframes
├── BANCO-DE-DADOS.md    artefato 7 — physical database design
├── INFRAESTRUTURA.md    artefato 9 — deployment infrastructure
└── ENTREGA.md           authorship table and final delivery checklist
.githooks/commit-msg     enforces the commit message pattern
```

`docs/RF/` is the assignment as received. Never modify anything under it.

## Build and test commands

Run the full local gate before claiming any change is ready. CI runs the same steps,
and the `ci` check is required to merge:

```bash
bin/rubocop                              # rubocop-rails-omakase
bin/brakeman --no-pager                  # static security analysis
bundle exec bundler-audit check --update # known CVEs in dependencies
bin/importmap audit                      # known CVEs in pinned JS
bin/rails test                           # unit + controller
bin/rails test:system                    # end-to-end, headless
```

Day-to-day:

```bash
docker compose up -d postgres            # database (no local install needed)
bin/setup                                # install gems, create and migrate the DB
bin/dev                                  # server + Tailwind watcher on :3000
bin/rails db:migrate
RAILS_ENV=test bin/rails db:migrate
```

The gate is necessary, not sufficient. A green gate says the units pass; it does not
say the screens work. **Every requirement issue also ends with the flow exercised in a
real browser**, because the evaluated deliverable is a working prototype plus a video
(#32), not a test report.

## Code style guidelines

- **Follow `rubocop-rails-omakase`.** Formatting is its business; do not argue style
  beyond it.
- **Model file ordering**, always in this sequence:

  ```ruby
  class UserStory < ApplicationRecord
    # 1. associations
    belongs_to :backlog
    belongs_to :epic, optional: true
    has_many :acceptance_criteria, dependent: :destroy

    # 2. normalizations
    normalizes :role, with: ->(value) { value.squish }

    # 3. constants and enums
    STORY_POINTS = [ 0, 1, 2, 3, 5, 8, 13, 21, 34, 55 ].freeze

    # 4. validations
    validates :role, :action, :benefit, presence: true

    # 5. callbacks
    before_validation :default_to_product_backlog, on: :create

    # 6. scopes
    scope :prioritised, -> { order(rice_score: :desc) }

    # 7. public instance methods
    def rice_score = ...

    # 8. private
    private
      def default_to_product_backlog = ...
  end
  ```

- **`Time.current`, never `Time.now`.** Same for `Date.current`.
- **Controllers stay thin.** Authenticate, authorise, call one model or service method,
  render. Business rules belong in the model; logic spanning several models belongs in
  a PORO under `app/services/`.
- **Always scope queries through the current user.** `Current.user.projects.find(params[:id])`,
  never `Project.find(params[:id])`. This is how the ownership rule in #3 and #4 is
  actually enforced.
- **Names say what the thing is.** Banned: `data`, `info`, `handler`, `manager`,
  `util`, `helper`, `process`, `obj`, `temp`.
- **Hotwire first.** Reach for a Turbo Frame or Stream before writing JavaScript. A new
  Stimulus controller needs a reason that a frame could not cover.
- Small, scoped, behaviour-preserving changes. No opportunistic refactors, no
  speculative abstractions, no unreachable stubs.

## Comments

- **Keep existing comments.** Do not strip them during a refactor — they carry intent
  and provenance you do not have.
- Write **WHY, not WHAT**. Never `# increment the counter` above `counter += 1`.
- When a line exists because of a specific requirement or bug, **name the issue
  number** in the comment: `# Effort = 0 yields nil rather than dividing by zero (#19)`.
- Document every non-obvious domain rule at the point it is enforced, with the RF it
  comes from.

## Dependencies

- **Check what Rails 8 already does before adding a gem.** Authentication, background
  jobs, caching, websockets, asset pipeline and deployment all ship in the box. Adding
  Devise, Sidekiq, Redis or Webpack to this project is a decision that has to be argued
  in the issue first.
- Injection through constructor or parameter. No package-level mutable state, no global
  singletons, no `init`-time side effects.
- Every new dependency is a line in `docs/INFRAESTRUTURA.md` (#33) and a licence to
  declare in `docs/REQUISITOS-NAO-FUNCIONAIS.md` (#27). Adding one is not free.

## Cross-cutting invariants (do not violate)

These come straight from section 2 of the brief. Each is validated **in the model**,
and where the database can enforce it, **also by a constraint** — a rule that lives
only in a form is not a rule.

1. **Story points are exactly `[0, 1, 2, 3, 5, 8, 13, 21, 34, 55]`** (#15). The same
   set is the domain of RICE Effort (#18). One constant, referenced twice.
2. **A project has at most one product backlog; sprint backlogs are unlimited**
   (#5, #6). Enforced by a model validation *and* a partial unique index.
3. **A user story is three columns — role, action, benefit — never free text** (#9).
   An acceptance criterion is three columns — context, action, outcome (#13). This is
   how the mandated format becomes impossible to violate rather than merely requested.
4. **A story is created in the product backlog** (#7) and can only be moved between
   backlogs **of the same project** (#8).
5. **A story can only be linked to an epic of its own project** (#11).
6. **RICE domains are closed sets** (#18): Reach is an integer >= 0; Impact is a
   `decimal` in `{3, 2, 1, 0.5, 0.25}` — decimal, not float, so 0.25 is exact;
   Confidence is an integer percentage in `{100, 80, 50}`; Effort is a story point.
7. **RICE score is `(reach * impact * (confidence / 100.0)) / effort`** (#19).
   Confidence is stored as a percentage and divided by 100 in the formula.
   **`effort == 0` returns `nil`**, not an exception and not infinity. The brief does
   not define this case; this is our decision and it is recorded in #19.
8. **Every user sees only their own data.** Every query is scoped through the current
   user; cross-user access returns not-found, not forbidden.
9. **Every functional requirement in section 2 maps to exactly one issue labelled `RF`.**
   If you find work that no issue covers, open the issue first.

## Testing instructions

- **TDD is mandatory.** Write the failing test first. Every new method gets a test.
- **Every acceptance criterion in an RF issue becomes a test.** The issues are written
  as `Dado … quando … então …` precisely so the translation is mechanical. An RF issue
  is not done while one of its checkboxes has no test behind it.
- **Test the invariants above at the model level**, including the rejection path.
  Asserting that a valid value is accepted proves nothing about a closed domain —
  assert that `4`, `7` and `-1` are rejected as story points.
- Tests are **fast, independent, repeatable, self-validating**. No `sleep` for
  synchronisation. No test depends on another's ordering.
- **Fixtures, not factories.** Keep them minimal and named for their role.
- System tests cover one acceptance scenario each and are the source of the video
  script in #32.

### Every bug gets a regression test. No exceptions.

A bug fixed without a test is a bug that is coming back. The test is not paperwork
after the fix — it is how you know you fixed the right thing.

**In this order:**

1. **Reproduce it as a failing test first**, before touching production code.
2. **Run it and read the failure.** It must fail *because of the bug*, not because of a
   typo or a missing import. A test that fails for the wrong reason proves nothing.
3. **Only now fix the code.**
4. **Run it again and watch it pass.** If it passed before the fix, it was never
   testing the bug — go back to step 1.

Name the test after the bug, with the issue number:
`test_moving_story_across_projects_is_rejected_issue_8`.

**This applies to every bug however it was found** — reported, spotted in review,
caught by CI, or noticed in your own uncommitted work. "I found it before I committed"
is not an exemption: the bug was reachable, so something can reach it again.

**Never delete or weaken a regression test.** If one starts failing, the bug is back.

## Security considerations

- **Never commit secrets.** Credentials go in Rails encrypted credentials or the
  environment. `.env` is gitignored; `.env.example` documents the keys with dummy
  values.
- **Passwords are stored as digests** via `has_secure_password`, never in plain text.
- **Strong parameters everywhere.** Never `permit!`.
- **Authorisation is checked on every action**, not just hidden in the view. A link
  that is not rendered is not access control.
- **Brakeman runs in the gate** and its warnings are fixed, not silenced. A suppression
  needs a comment saying why.
- Authentication failures return a **generic** message — never reveal whether an
  e-mail is registered (#3).

## Project tracking and Git workflow

- **Work is tracked on the GitHub Project board**
  ([okonomi, project 14](https://github.com/users/WilsonSousajr/projects/14)).
  Everything syncs with the remote — no local-only branches, no unpushed work at the
  end of a session.
- **Orient yourself by issues.** Read the issue before starting. If the work is not
  covered by an issue, open one first, label it, and put it on the board.
- **Every issue and PR is on the board, in exactly one column:**

  | Column | Means | Exit criterion |
  |---|---|---|
  | Backlog | Captured and prioritised. Nobody is on it. | Scope understood, MoSCoW/RICE set |
  | Sprint Backlog | Committed to the current iteration; ready to pull. | Acceptance criteria written, points estimated |
  | Doing | Being worked on right now. WIP limit: one card per person. | Branch open and linked to the issue |
  | Review | PR open, awaiting review and CI. | Approved and `ci` green |
  | Done | Merged to `main`, CI green, acceptance verified. | Evidence recorded on the issue |

  **Move the card when the state changes, not in a batch at the end.** The board is
  graded on being an honest record of the work.

- **Labels.** Every issue carries one **type** label and, where applicable, an
  **area** label and an **artefato** label.

  - Type: `feat` `fix` `docs` `test` `refactor` `chore` `build` `ci` `perf` `style` —
    the same set as the commit types, so a `feat`-labelled issue produces `feat(#N):`
    commits.
  - Area: `area:auth` `area:projects` `area:backlogs` `area:stories` `area:epics`
    `area:criteria` `area:estimation` `area:prioritization` `area:ui` `area:db`
    `area:infra`.
  - Artefato: `artefato:processo` `artefato:visao` `artefato:rnf` `artefato:historias`
    `artefato:arquitetura` `artefato:interface` `artefato:bd` `artefato:prototipo`
    `artefato:infraestrutura`. **These map 1:1 to the evaluation criteria in section 5
    of the brief** — the label is how a deliverable is traced to the mark it earns.
  - Flags: `RF` (implements a numbered functional requirement), `regression` (needs a
    test that fails before the fix), `blocked`, `entrega`.

- **Milestones** are `M0 — Fundação` through `M5 — Implantação e Entrega`. Every open
  issue carries one.

- **Commit messages:** `type(#issue_number): message`

  ```
  feat(#15): restrict story points to the Fibonacci scale
  fix(#8): reject moving a story to another project's backlog
  docs(#31): document the acceptance_criteria table
  ```

  Enforced by `.githooks/commit-msg`. Enable it once per clone:
  `git config core.hooksPath .githooks`.

- **Branches:** `type/issue-N-short-slug`, e.g. `feat/issue-15-story-points-scale`.
- **PR titles use the same pattern as commits.** The body links the issue with
  `Closes #N` and states what changed, why, and how it was verified.
- **`main` is protected:** pull request required, `ci` must pass, force-push and
  deletion refused. This applies to the repository owner too — that is the point of it.
- **Every bug found gets an issue and a regression test**, even when fixed immediately.
  Label it `regression`.
- **No version bump and no release tag without explicit approval.**

## Documentation map

- `docs/RF/ESW-TRABALHO-PRÁTICO.pdf` — the assignment. The source of truth for every
  requirement, instruction and evaluation criterion. Read it before proposing anything.
- `docs/RF/Templates/` — the `.odt` templates the brief asks us to use (instruction 3).
- `docs/PROCESSO.md` — how we run the board (artefato 1, criterion 01).
- `docs/ARQUITETURA.md` — architecture notebook (artefato 5, criterion 05).
- `docs/BANCO-DE-DADOS.md` — physical database design (artefato 7, criterion 07).
- `docs/ENTREGA.md` — who built what, and the final packaging checklist.
- `README.md` — what this is and how to run it.
