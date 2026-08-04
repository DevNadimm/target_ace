# TargetAce: AI Coding Agent Guidelines & Directives

---

## 🤖 1. Overview

This document provides developer guidelines and system directives for AI Coding Assistants (e.g. Google Antigravity, Claude, ChatGPT, AGY CLI) interacting with the **TargetAce** codebase.

---

## 🛑 2. Mandatory Rules & Guardrails

### Rule 1: Dual Database Migration Sync (MCP Directive)
Whenever performing database schema alterations, DDL creations, PostgreSQL trigger modifications, or RPC function updates via MCP tools (`apply_migration` or `execute_sql`), **the AI agent MUST also save a corresponding local `.sql` migration file** under `supabase/migrations/` (timestamped e.g. `YYYYMMDDHHMMSS_name.sql`).
- *Rationale*: Database updates executed directly via MCP can cause local repository migration files to become backdated if not saved locally.

### Rule 2: Typography Standardization (`AppFonts`)
- Direct instantiation of `GoogleFonts.poppins(...)` or `GoogleFonts.hindSiliguri(...)` in UI widgets is strictly forbidden by `.agents/skills/uiux-design-system/SKILL.md`.
- All text styles must use `AppFonts.body(...)` or `AppFonts.heading(...)` from `lib/core/config/typography.dart`.

### Rule 3: Preserving Comments & Code Architecture
- Maintain all pre-existing documentation comments and docstrings.
- Follow Clean Architecture: Data layer sources throw `ServerException`, Repositories return `Either<Failure, T>`, Domain UseCases contain zero Flutter UI code.

### Rule 4: Verification Before Task Completion
- Never declare a task resolved without running:
  1. `flutter analyze` (Must pass with 0 errors).
  2. `flutter test` (Must pass 100% of unit tests).

---

## ⚡ 3. Slash Commands Reference

Recommended slash commands available in the chat UI:

| Command | Usage & Purpose |
| :--- | :--- |
| `/goal` | Autonomous execution mode for complex multi-step refactoring tasks. |
| `/schedule` | Set one-shot timers or background cron jobs for periodic task checks. |
| `/learn` | Save new user directives or project workflows permanently. |
| `/grill-me` | Interactive interview mode to clarify underspecified architectural decisions. |
| `/browser` | Web browsing and online documentation retrieval mode. |
