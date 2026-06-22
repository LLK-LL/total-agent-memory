# Memory Graph Cytoscape Viewer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a local Cytoscape.js viewer for the Total Agent Memory knowledge graph and remove the previous Obsidian mirror exporter from the temporary Codex work area.

**Architecture:** Add a read-only Python exporter that reads `graph_nodes`, `graph_edges`, `knowledge_nodes`, and `knowledge` from `memory.db`, writes a self-contained viewer directory, and copies static HTML/CSS/JS assets. The browser UI loads `graph.json` locally or over a simple static file server, then provides search, type filters, edge-weight filtering, node details, and neighborhood focus.

**Tech Stack:** Python 3 standard library, SQLite read-only URI connections, pytest, Cytoscape.js from CDN with a vendored no-network fallback note, static HTML/CSS/JavaScript.

---

## File Structure

- Create: `src/tools/memory_graph_viewer_export.py`
  - CLI and reusable functions for read-only graph export.
- Create: `src/tools/memory_graph_viewer_assets/index.html`
  - Viewer shell and controls.
- Create: `src/tools/memory_graph_viewer_assets/styles.css`
  - Quiet operational UI styling.
- Create: `src/tools/memory_graph_viewer_assets/viewer.js`
  - Cytoscape initialization, filters, search, details, and layout controls.
- Create: `tests/test_memory_graph_viewer_export.py`
  - Unit tests with temporary SQLite fixture.
- Delete after verification: `C:\Users\Administrator\Documents\Codex\2026-06-16\superpowers-writing-plans-c-users-administrator-2\tools\export_obsidian_memory_vault.py`
- Delete after verification: `C:\Users\Administrator\Documents\Codex\2026-06-16\superpowers-writing-plans-c-users-administrator-2\tools\obsidian_memory_exporter`

## Task 1: Exporter Core

**Files:**
- Create: `src/tools/memory_graph_viewer_export.py`
- Test: `tests/test_memory_graph_viewer_export.py`

- [ ] Step 1: Write fixture tests for read-only export, limiting, metadata, and orphan edge removal.
- [ ] Step 2: Run the tests and verify they fail because the module does not exist.
- [ ] Step 3: Implement `connect_readonly`, `load_graph`, `write_graph_json`, and `copy_assets`.
- [ ] Step 4: Run the tests and verify they pass.

## Task 2: Static Viewer

**Files:**
- Create: `src/tools/memory_graph_viewer_assets/index.html`
- Create: `src/tools/memory_graph_viewer_assets/styles.css`
- Create: `src/tools/memory_graph_viewer_assets/viewer.js`

- [ ] Step 1: Add a static HTML shell with search, node type filters, edge weight slider, layout buttons, stats, graph viewport, and details panel.
- [ ] Step 2: Add JavaScript that fetches `graph.json`, renders Cytoscape elements, applies filters, highlights neighborhoods, and reports selected node details.
- [ ] Step 3: Add CSS with stable panel sizing and readable dense controls.
- [ ] Step 4: Export the real graph and manually verify that `index.html`, assets, and `graph.json` are generated.

## Task 3: Obsidian Mirror Cleanup

**Files:**
- Delete: `C:\Users\Administrator\Documents\Codex\2026-06-16\superpowers-writing-plans-c-users-administrator-2\tools\export_obsidian_memory_vault.py`
- Delete: `C:\Users\Administrator\Documents\Codex\2026-06-16\superpowers-writing-plans-c-users-administrator-2\tools\obsidian_memory_exporter`

- [ ] Step 1: Confirm paths exist and are under the temporary Codex work directory.
- [ ] Step 2: Delete only those paths.
- [ ] Step 3: Verify they no longer exist.

## Task 4: End-To-End Verification

**Files:**
- Output: `C:\Users\Administrator\Documents\Codex\2026-06-16\new-chat-3\outputs\memory-graph-viewer`

- [ ] Step 1: Run pytest for the exporter test.
- [ ] Step 2: Export the real graph to the output directory.
- [ ] Step 3: Verify JSON counts and generated files.
- [ ] Step 4: Start a local static HTTP server and open the viewer in the in-app browser.
- [ ] Step 5: Verify the page is nonblank and loads graph data.
