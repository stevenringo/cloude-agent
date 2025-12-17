# Clawed (Claude Agent SDK API + Web Chat)

A FastAPI-based API plus single-page chat UI for a Claude Code agent that can chat, use tools, manage skills, and read/write files on a Railway-mounted workspace volume with Redis volume for chat persistence.

## Features
- Chat API with streaming (`/chat/stream`) and model selection.
- File-aware agent: reads/writes in `/app/workspace` (Railway volume-backed).
- Skill management: list/get/add/delete/upload/download skills.
- Web chat UI (`chat.html`): sidebar for model choice, skills, workspace files; drag/drop skill zips; streaming responses; one-click open/download/curl for files.
- Permissions modes: default is `acceptEdits`; toggle `bypassPermissions` in UI.

## API
- `POST /chat` — non-streaming chat
- `POST /chat/stream` — SSE streaming chat
- `GET /workspace` — list workspace files
- `GET /workspace/{path}` — download workspace file (requires `X-API-Key`)
- `DELETE /workspace/{path}` — delete workspace file
- `GET /skills` — list skills
- `GET /skills/{id}` — get SKILL.md + files
- `POST /skills` — add/update a SKILL.md
- `POST /skills/upload` — upload skill zip
- `GET /skills/{id}/download` — download skill zip
- `DELETE /skills/{id}` — delete skill
- `GET /commands` — list commands
- `GET /commands/{id}` — get command template
- `POST /commands` — add/update a command template
- `DELETE /commands/{id}` — delete a command
- `GET /health` — health check

## Auth
- All endpoints except `/health` require authentication (set via `API_KEY` env).
- **Header (preferred):** `X-API-Key: your-key`
- **Query param (webhooks only):** `?api_key=your-key`

Startup guardrails:
- `API_KEY` is required at startup.

## Security Notes
- Don’t commit secrets: keep API keys in env vars (e.g. `.env`, Railway variables). This repo ignores `.env` and `.claude/settings.local.json`.
- If you ever committed an API key, rotate it (and consider rewriting git history if the repo is public).

## Permissions Modes
- `default` — standard checks
- `acceptEdits` (default) — auto-approve file edits/fs ops
- `bypassPermissions` — auto-approve all tools (requires non-root; we run as `appuser`)
Pass via `context.permission_mode` in `/chat` or toggle in the UI.
`bypassPermissions` is disabled by default; enable it by setting `ALLOW_BYPASS_PERMISSIONS=1`.

## Workspace Files (volume)
- Mounted at `/app/workspace` (Railway volume).
- Agent works in this directory (SDK `cwd` set).
- UI “Workspace Files” shows new files after each run with buttons: Open, Download, Copy link, Copy curl.

## Skills
- Skills live on the volume at `$WORKSPACE_DIR/.claude/skills/{skill_id}/SKILL.md` (+ supporting files).
- Skills are **not** baked into the Docker build - they persist on the volume and can be added/modified without redeployment.
- Manage via API or UI (drag/drop zip).
- After uploading skills with scripts, they are automatically made executable on container start.

## Commands (Slash Commands)
- Commands are prompt templates stored at `$WORKSPACE_DIR/.claude/commands/{command_id}.md`
- Invoke via `command` parameter in `/chat`: `{"command": "voice-transcript", "message": "the transcript text..."}`
- Commands use Claude Code’s markdown format (YAML frontmatter + prompt body). Frontmatter `allowed-tools` controls what the command is allowed to run.
- Inside command markdown, use `$ARGUMENTS` (or positional `$1`, `$2`, etc.) to consume the arguments passed after `/{command}`.
- Manage via API: `GET/POST/DELETE /commands` (and/or edit the files on the volume).
- Useful for webhooks that need consistent prompt formatting and reliable routing.

## Webhooks (non-interactive permissions)
Webhook-triggered runs can’t click “approve”, so **any tool that would normally prompt must be pre-approved** or you’ll see errors like “This command requires approval”.

- Use `POST /webhook` to map arbitrary payloads into a session + message, optionally invoking a slash command:
  - Example: `POST /webhook?api_key=...&command=voice-transcript&session_id=id&message=transcript&raw_response=true`
- Recommended: keep permissions locked down and add explicit allow rules in `.claude/settings.json` (seeded into the volume by `entrypoint.sh`).
- Avoid relying on `bypassPermissions` for production webhooks unless you fully trust the deployment and isolation.

## Voice Transcript Workflow
This repo includes a volume-managed voice pipeline intended for webhook ingestion from a voice app:

- Command: `.claude/commands/voice-transcript.md`
  - Saves the raw transcript to `./artifacts/transcripts/` via `.claude/commands/scripts/save_transcript.py` (unique filename, returns a public URL).
  - Routes:
    - `/process-note` → `.claude/commands/process-note.md` → saves cleaned notes to `./artifacts/notes/`
    - `/process-meeting` → `.claude/commands/process-meeting.md` → saves diarised notes to `./artifacts/meeting-notes/`

## Running Locally
1) `python -m venv .venv && source .venv/bin/activate`
2) `pip install -r requirements.txt`
3) `export API_KEY=dev-local-key` (or your key)
4) `uvicorn main:app --reload`
5) Open `chat.html` in a browser (set `API_URL` at top if needed).

## Env Vars
- `API_KEY` (required)
- `REDIS_URL` (default `redis://localhost:6379`)
- `PORT` (default `8080`)
- `WORKSPACE_DIR` (default `/app/workspace`)
- `SKILLS_DIR` (default `$WORKSPACE_DIR/.claude/skills`)
- `COMMANDS_DIR` (default `$WORKSPACE_DIR/.claude/commands`)
- `PROJECT_CONTEXT_PATH` (default `$WORKSPACE_DIR/.claude/CLAUDE.md`)
- `MAX_PROJECT_CONTEXT_CHARS` (default `50000`)
- `ALLOW_BYPASS_PERMISSIONS` (default `0`) — set to `1` to allow `permission_mode=bypassPermissions`
- `PUBLIC_BASE_URL` (optional) — used by slash commands to generate fully-qualified artifact URLs (defaults to the production Railway URL in the included commands).

## Deployment (Railway)
- Dockerfile installs node + Claude CLI, creates `appuser`, uses entrypoint to `chown` `/app/workspace` before dropping privileges.
- Attach a volume to `/app/workspace` for persistence.
- Run `railway up --detach` to deploy.
- `entrypoint.sh` seeds default `.claude/commands/`, `.claude/skills/`, `.claude/settings.json`, `.claude/CLAUDE.md`, and `.claude/commands/scripts/` into the volume **only if missing** (non-destructive). To pick up image updates, edit the volume files (preferred) or delete the specific file(s) from the volume so they can be re-seeded.

## Notable Files
- `main.py` — FastAPI app and endpoints
- `agent_manager.py` — chat logic, streaming, skills, workspace helpers
- `chat.html` — single-page UI
- `Dockerfile`, `entrypoint.sh` — image and permissions fix
- `.claude/settings.json` — project permission rules used for non-interactive runs (webhooks)
- `.claude/CLAUDE.md` — project context (volume-managed) appended to the system prompt
- `.claude/commands/scripts/` — helper scripts invoked by commands


## Current Limitations
- Workspace download URLs require API key (by design). UI provides one-click open/download/curl to ease this.
- SDK streams messages (not tokens); long tool runs may show status but not partial text.
