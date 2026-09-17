# Claude Code Instructions

Read and follow [`AGENTS.md`](AGENTS.md). This repository keeps a single canonical
agent instruction file for Claude Code, Codex, OpenCode, Cursor, Gemini CLI and other
AGENTS-aware harnesses.

Do not duplicate project rules here. Update `AGENTS.md` instead.

## Quick reference

```bash
cp .env.example .env            # obrigatório: nada tem senha padrão no repo
docker compose up -d postgres   # database
bin/setup                       # gems + db:create + db:migrate
bin/dev                         # server on :3000
bin/rails test                  # unit + controller
bin/rails test:system           # end-to-end
bin/rubocop && bin/brakeman --no-pager   # the rest of the gate
```

- Every change starts from an issue. Commits are `type(#issue): message`.
- The brief is `docs/RF/ESW-TRABALHO-PRÁTICO.pdf` — never edit anything under `docs/RF/`.
- The board is a graded deliverable: https://github.com/users/WilsonSousajr/projects/14
- Story points are only `0, 1, 2, 3, 5, 8, 13, 21, 34, 55`; RICE Effort uses the same set.
- RICE score is `(R × I × (C/100.0)) / E`, and `E == 0` returns `nil`.
- `json` is pinned to `~> 2.9` on purpose — unpinning breaks all signed cookies (#36).
- Minitest 6 has no `minitest/mock`; `Rails.stub` does not exist. See `with_env` in
  `test/controllers/concerns/authentication_test.rb`.
- Port 3000 is often taken on this machine — use `bin/rails server -p 3001`.
