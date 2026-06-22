# Memory Graph 2D And 3D Viewer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extend the local Total Agent Memory graph viewer so it keeps the current Cytoscape.js 2D mode and adds a 3D mode powered by `3d-force-graph`.

**Architecture:** Reuse the existing read-only SQLite exporter and `graph.json`. Add a second static HTML page and JavaScript controller for 3D, keep the 2D viewer as `index.html`, and expose simple cross-links between modes.

**Tech Stack:** Python 3 standard library, pytest, static HTML/CSS/JavaScript, Cytoscape.js for 2D, `3d-force-graph` and Three.js via CDN for 3D.

---

## File Structure

- Modify: `src/tools/memory_graph_viewer_export.py`
  - Copy all static assets needed by both 2D and 3D viewers.
- Modify: `src/tools/memory_graph_viewer_assets/index.html`
  - Add a 3D mode link while keeping the 2D layout unchanged.
- Modify: `src/tools/memory_graph_viewer_assets/styles.css`
  - Add shared styles for mode links and the 3D page.
- Create: `src/tools/memory_graph_viewer_assets/viewer-3d.html`
  - 3D viewer shell.
- Create: `src/tools/memory_graph_viewer_assets/viewer-3d.js`
  - 3D graph loading, conversion from Cytoscape shape to force-graph shape, filters, search, focus, and details.
- Modify: `tests/test_memory_graph_viewer_export.py`
  - Assert that the new 3D assets are copied.

## Task 1: Asset Copy Contract

**Files:**
- Modify: `tests/test_memory_graph_viewer_export.py`
- Modify: `src/tools/memory_graph_viewer_export.py`

- [ ] **Step 1: Write the failing test**

Add these assertions to `test_write_graph_json_and_copy_assets`:

```python
assert (output / "viewer-3d.html").exists()
assert (output / "viewer-3d.js").exists()
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
python -m pytest tests/test_memory_graph_viewer_export.py::test_write_graph_json_and_copy_assets -v
```

Expected: FAIL because `viewer-3d.html` and `viewer-3d.js` do not exist yet.

- [ ] **Step 3: Implement minimal exporter change**

Change `copy_assets` to copy:

```python
for asset in ("index.html", "styles.css", "viewer.js", "viewer-3d.html", "viewer-3d.js"):
    shutil.copy2(asset_dir / asset, output_dir / asset)
```

- [ ] **Step 4: Add the 3D asset files**

Create `viewer-3d.html` and `viewer-3d.js` in the asset directory.

- [ ] **Step 5: Run test to verify it passes**

Run:

```powershell
python -m pytest tests/test_memory_graph_viewer_export.py -v
```

Expected: PASS.

## Task 2: 2D/3D Navigation

**Files:**
- Modify: `src/tools/memory_graph_viewer_assets/index.html`
- Modify: `src/tools/memory_graph_viewer_assets/styles.css`
- Create: `src/tools/memory_graph_viewer_assets/viewer-3d.html`

- [ ] **Step 1: Add mode navigation to 2D**

Add:

```html
<nav class="mode-links">
  <a class="active" href="index.html">2D</a>
  <a href="viewer-3d.html">3D</a>
</nav>
```

- [ ] **Step 2: Create the 3D shell**

The 3D page has the same side controls concept: search, type filters, minimum edge weight, fit/reheat/clear buttons, graph canvas, and details panel.

- [ ] **Step 3: Add shared CSS**

Add `.mode-links`, `.graph-3d`, and stable details styles.

## Task 3: 3D Graph Logic

**Files:**
- Create: `src/tools/memory_graph_viewer_assets/viewer-3d.js`

- [ ] **Step 1: Load `graph.json`**

Fetch the same exported graph data used by 2D.

- [ ] **Step 2: Convert data**

Convert:

```javascript
graph.elements.nodes -> [{ id, label, type, val, color, raw }]
graph.elements.edges -> [{ source, target, relation, weight, raw }]
```

- [ ] **Step 3: Render 3D**

Use `ForceGraph3D()(container)` with `graphData`, `nodeLabel`, `nodeColor`, `nodeVal`, `linkWidth`, and `onNodeClick`.

- [ ] **Step 4: Implement filters**

Use active type set, search text, and minimum edge weight to rebuild the graph data.

- [ ] **Step 5: Implement focus/details**

Clicking a node shows metadata and linked memories, then moves camera toward that node.

## Task 4: End-To-End Verification

**Files:**
- Output: `C:\Users\Administrator\Documents\Codex\2026-06-16\new-chat-3\outputs\memory-graph-viewer`

- [ ] **Step 1: Run tests**

```powershell
python -m pytest tests/test_memory_graph_viewer_export.py -v
```

- [ ] **Step 2: Re-export real graph**

```powershell
python src/tools/memory_graph_viewer_export.py --output "C:/Users/Administrator/Documents/Codex/2026-06-16/new-chat-3/outputs/memory-graph-viewer" --max-nodes 1500 --max-edges 4000
```

- [ ] **Step 3: Verify files**

Check `index.html`, `viewer-3d.html`, `viewer.js`, `viewer-3d.js`, `styles.css`, and `graph.json`.

- [ ] **Step 4: Browser verify both modes**

Open:

```text
http://127.0.0.1:8765/index.html
http://127.0.0.1:8765/viewer-3d.html
```

Expected: both pages show `1500 nodes, 2899 edges` and render nonblank graph surfaces.

## Self-Review

- Spec coverage: preserves 2D mode, adds 3D mode using `3d-force-graph`, reuses existing exported graph data.
- Placeholder scan: no placeholder implementation steps remain.
- Type consistency: the plan consistently uses Cytoscape-shaped `graph.json` as the exported format and converts it only inside `viewer-3d.js`.
