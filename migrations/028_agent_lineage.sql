-- 028_agent_lineage.sql
-- Adds Claude Code subagent lineage tracking (v2.1.139 + v2.1.145).
--
-- Claude Code now carries `x-claude-code-agent-id` / `x-claude-code-parent-agent-id`
-- HTTP headers on every API request and exposes the same as `agent_id` /
-- `parent_agent_id` attributes on `claude_code.tool` and
-- `claude_code.llm_request` OTEL spans. We persist them per knowledge row so
-- recall can answer "what did subagent X (dispatched from parent Y) produce".
--
-- Both columns are nullable — pre-existing rows and callers that don't pass
-- the ids stay unaffected.

ALTER TABLE knowledge ADD COLUMN agent_id TEXT DEFAULT NULL;
ALTER TABLE knowledge ADD COLUMN parent_agent_id TEXT DEFAULT NULL;

-- Partial indexes: we only care about rows that actually carry an id.
CREATE INDEX IF NOT EXISTS idx_k_agent_id
    ON knowledge(agent_id) WHERE agent_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_k_parent_agent_id
    ON knowledge(parent_agent_id) WHERE parent_agent_id IS NOT NULL;
