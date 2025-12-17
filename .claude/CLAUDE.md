# Project Context

You are an instance of Claude Agent running in the cloud.
You are deployed on Railway.com
Your cwd is a Railway volume, where you read and write files.

**Top-level structure:**
- **.claude/** - Claude Code project configuration
  - `CLAUDE.md` - Project context documentation
  - `commands/` - Slash command definitions (7 commands including query-sessions)
  - `settings.json` - Settings
  - `skills/` - Custom skills (eg artifacts-builder, canvas-design, skill-creator)

- **.claude-home/** - Claude Agent runtime home directory
  - `debug/` - Debug files for sessions
  - `plans/` - Planning files
  - `plugins/` - Plugin configuration
  - `projects/` - Session data organized by project
  - `shell-snapshots/` - Shell state snapshots
  - `statsig/` - Feature flag evaluations
  - `session-env/` - Session environment (excluded from tree)
  - `todos/` - Todo items storage (excluded from tree)

- **artifacts/** - Outputs and working files (Public)
  - `commands/` - Backup of slash commands
  - `debug/` - Debug outputs
  - `designs/` - Design files
  - `notes/` - Processed notes
  - `transcripts/` - Processed transcripts
  - `test/` - Test files

- **scripts/** - Utility scripts

- **notes/** - Raw notes/transcripts
- **transcripts/** - Raw transcript files
- **Root files** - Various markdown docs and HTML reports (contract renewal prep, Peregian Hub annual reports, etc.)
- **lost+found/** - System directory


## Management Tools

### Session Analysis

**Query Sessions** - `/query-sessions` slash command
Inspect session data to debug agent behaviour: tool calls, execution errors, missing files, etc.

**Usage:**
- `/query-sessions -n 5` - Get 5 most recent sessions with metadata
- `/query-sessions -s <id>` - Get full session data by ID

**Script:** `/app/workspace/scripts/session_query.sh`

**Session metadata includes:**
- sessionId - Unique session identifier
- firstUserMessage - First user message (truncated to 100 words)
- totalMessages - Total message count (user + assistant)
- firstMessageTimestamp - Session start timestamp
- lastMessageTimestamp - Session end timestamp
- model - Claude model used in the session

### Artifact Management

**List Artifacts** - `/list-artifacts` slash command
Comprehensive utility for managing and exploring artifact files.

**Usage:**
- `/list-artifacts` - List all subdirectories with stats
- `/list-artifacts -d <subdir>` - List files in specific subdirectory
- `/list-artifacts -f <pattern>` - Search for files by name pattern
- `/list-artifacts -c <text>` - Search for files containing text
- `/list-artifacts -r [days]` - Show recent activity (default: 7 days)
- `/list-artifacts --stats` - Show detailed statistics

**Script:** `/app/workspace/scripts/list_artifacts.sh`

**Features:**
- Directory listing with file counts and sizes
- File name pattern search
- Content search across all files
- Recent activity tracking (modified files)
- Statistics: file types, age distribution, largest files, total counts
