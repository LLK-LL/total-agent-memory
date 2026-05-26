#!/usr/bin/env bash
# Smoke test: `docker run total-agent-memory:latest` must produce a working
# dashboard at http://127.0.0.1:37737 on a fresh volume in under 90s.
#
# Builds the image locally (uses ./Dockerfile) — drop --build to test a
# specific pre-built tag via SMOKE_IMAGE env.
#
# Required on host: Docker.
#
# Exit codes:
#   0 — /healthz 200, /api/stats 200, docker healthcheck=healthy
#   1 — image build failed
#   2 — container failed to start
#   3 — /healthz never responded
#   4 — /api/stats never returned 200
#   5 — docker healthcheck never reached healthy
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$HERE/../.." && pwd)"

IMAGE="${SMOKE_IMAGE:-total-agent-memory:smoke-$$}"
PORT="${SMOKE_PORT:-37739}"
VOLUME="tam-smoke-vol-$$"
CONTAINER="tam-smoke-$$"

cleanup() {
  echo "→ cleanup"
  docker rm -f "$CONTAINER" 2>/dev/null || true
  docker volume rm "$VOLUME" 2>/dev/null || true
  if [ -z "${SMOKE_IMAGE:-}" ]; then
    docker rmi "$IMAGE" 2>/dev/null || true
  fi
}
trap cleanup EXIT

if [ -z "${SMOKE_IMAGE:-}" ]; then
  echo "→ building $IMAGE from $REPO_ROOT"
  docker build -t "$IMAGE" "$REPO_ROOT" || exit 1
fi

echo "→ launching container on :$PORT (fresh volume $VOLUME)"
docker run -d --name "$CONTAINER" -p "$PORT:37737" -v "$VOLUME:/data" "$IMAGE" >/dev/null \
  || exit 2

echo "→ waiting for /healthz (max 60s)"
for i in $(seq 1 30); do
  if curl -fsS -m 2 "http://127.0.0.1:$PORT/healthz" >/dev/null 2>&1; then
    echo "  ✓ /healthz responded after $((i*2))s"
    break
  fi
  if [ "$i" = "30" ]; then
    echo "FAIL: /healthz never responded"
    docker logs "$CONTAINER" | tail -30
    exit 3
  fi
  sleep 2
done

echo "→ waiting for /api/stats 200 (depends on DB migration, max 90s)"
for i in $(seq 1 45); do
  code=$(curl -s -o /dev/null -w "%{http_code}" -m 3 "http://127.0.0.1:$PORT/api/stats" || echo 000)
  if [ "$code" = "200" ]; then
    echo "  ✓ /api/stats → 200 after $((i*2))s"
    break
  fi
  if [ "$i" = "45" ]; then
    echo "FAIL: /api/stats never returned 200 (last: $code)"
    docker logs "$CONTAINER" | tail -30
    exit 4
  fi
  sleep 2
done

echo "→ waiting for docker healthcheck=healthy (max 60s)"
for i in $(seq 1 20); do
  h=$(docker inspect "$CONTAINER" --format '{{.State.Health.Status}}' 2>/dev/null || echo unknown)
  if [ "$h" = "healthy" ]; then
    echo "  ✓ docker healthcheck = healthy"
    break
  fi
  if [ "$i" = "20" ]; then
    echo "FAIL: docker healthcheck never healthy (last: $h)"
    docker logs "$CONTAINER" | tail -30
    exit 5
  fi
  sleep 3
done

echo "→ verifying clean shutdown"
START=$(date +%s)
docker stop "$CONTAINER" >/dev/null
STOP_TOOK=$(($(date +%s) - START))
echo "  ✓ stopped in ${STOP_TOOK}s"
if [ "$STOP_TOOK" -gt "10" ]; then
  echo "WARN: docker stop took >10s (signal handling may be slow)"
fi

echo "✓ docker single-image smoke OK"
