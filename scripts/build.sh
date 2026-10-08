#!/usr/bin/env bash
# Build Harbor images locally, mirroring .github/workflows/build-image-reusable.yml.
#
# Usage: scripts/build.sh --harbor-version <tag> [--arch x64|arm64|auto] [--namespace <ns>] [--prepare-only]
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HARBOR_DIR="${ROOT_DIR}/harbor"
HARBOR_REPO_URL="https://github.com/goharbor/harbor.git"

HARBOR_VERSION=""
ARCH="auto"
NAMESPACE="local"
PREPARE_ONLY=false

usage() {
  sed -n '2,4p' "$0" | sed 's/^# \{0,1\}//'
}

die() {
  echo "error: $*" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --harbor-version) HARBOR_VERSION="${2:-}"; shift 2 ;;
    --arch)           ARCH="${2:-}"; shift 2 ;;
    --namespace)      NAMESPACE="${2:-}"; shift 2 ;;
    --prepare-only)   PREPARE_ONLY=true; shift ;;
    -h|--help)        usage; exit 0 ;;
    *)                die "unknown argument: $1" ;;
  esac
done

[[ -n "${HARBOR_VERSION}" ]] || die "--harbor-version is required (e.g. v2.15.3)"
[[ "${HARBOR_VERSION}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9.]+)?$ ]] || die "invalid harbor version: ${HARBOR_VERSION}"

# Resolve the target architecture; the image names and trivy download depend on it.
HOST_ARCH="$(uname -m)"
case "${ARCH}" in
  auto)
    case "${HOST_ARCH}" in
      x86_64)        ARCH="x64" ;;
      aarch64|arm64) ARCH="arm64" ;;
      *)             die "unsupported host architecture: ${HOST_ARCH}" ;;
    esac
    ;;
  x64|arm64) ;;
  *) die "--arch must be x64, arm64 or auto" ;;
esac

case "${ARCH}" in
  x64)   TRIVY_ARCH="64bit" ;;
  arm64) TRIVY_ARCH="ARM64" ;;
esac

# Preflight: the build needs these on the host. Docker runs the Go/Node builds in containers.
for tool in git make docker curl sed; do
  command -v "${tool}" >/dev/null 2>&1 || die "${tool} is not installed"
done
docker info >/dev/null 2>&1 || die "docker daemon is not reachable"

if [[ "${ARCH}" == "arm64" && "${HOST_ARCH}" != "aarch64" && "${HOST_ARCH}" != "arm64" ]]; then
  echo "warning: building arm64 images on ${HOST_ARCH} requires qemu/binfmt support in docker" >&2
fi

# Fetch the Harbor release tag into the submodule and check it out.
# Refuse to touch a harbor checkout that has local changes.
[[ -e "${HARBOR_DIR}/.git" ]] || git -C "${ROOT_DIR}" submodule update --init --depth 1 harbor
if [[ -n "$(git -C "${HARBOR_DIR}" status --porcelain)" ]]; then
  die "harbor/ has uncommitted changes; clean it before building"
fi

echo "==> fetching harbor ${HARBOR_VERSION}"
git -C "${HARBOR_DIR}" fetch --depth 1 "${HARBOR_REPO_URL}" "refs/tags/${HARBOR_VERSION}:refs/tags/${HARBOR_VERSION}" \
  || die "tag ${HARBOR_VERSION} not found in ${HARBOR_REPO_URL}"
git -C "${HARBOR_DIR}" -c advice.detachedHead=false checkout --force "${HARBOR_VERSION}"

# Restore the harbor checkout when the script exits, so the patches below do not linger.
restore_harbor() {
  git -C "${HARBOR_DIR}" checkout -- . 2>/dev/null || true
}
trap restore_harbor EXIT

cd "${HARBOR_DIR}"

echo "==> patching harbor sources (arch=${ARCH})"
# Add the repository label to built images, taken from the origin remote.
REPO_URL="$(git -C "${ROOT_DIR}" remote get-url origin 2>/dev/null | sed -e 's|\.git$||' -e 's|^git@github.com:|https://github.com/|')"
REPO_URL="${REPO_URL:-https://github.com/local/harbor-multi-platform}"
sed -i "s|^DOCKERBUILD=\$(DOCKERCMD) build --no-cache --network=\$(DOCKERNETWORK)|DOCKERBUILD=\$(DOCKERCMD) build --no-cache --network=\$(DOCKERNETWORK) --label ${REPO_URL} |g" make/photon/Makefile

# Trivy ships separate tarballs per arch.
sed -i "s|\(trivy_.*_Linux-\)64bit\(.tar.gz\)|\1${TRIVY_ARCH}\2|" Makefile

if [[ "${ARCH}" == "arm64" ]]; then
  # goharbor/photon is amd64-only; use the public multi-arch photon image instead.
  find make/photon -name "Dockerfile.base" \
    -exec sed -i 's|FROM goharbor/photon:|FROM photon:|g' {} \;

  # redis 7.2.x is not in the public photon repos; valkey provides the same redis-* binaries.
  # Newer harbor tags already ship make/photon/valkey instead, so only patch when redis is present.
  if [[ -f make/photon/redis/Dockerfile.base ]]; then
    sed -i 's|tdnf install -y redis\(-[^ ]*\)\?|tdnf install -y valkey|' make/photon/redis/Dockerfile.base
  fi
fi

if [[ "${PREPARE_ONLY}" == "true" ]]; then
  echo "==> prepare-only: sources patched, skipping build"
  git diff --stat
  exit 0
fi

PARM=(
  "DEVFLAG=false"
  "TRIVYFLAG=true"
  "PULL_BASE_FROM_DOCKERHUB=false"
  "IMAGENAMESPACE=${NAMESPACE}"
)

echo "==> compiling"
make compile -e "${PARM[@]}"

echo "==> building images"
make build -e "${PARM[@]}"

echo "==> built images"
docker images --format '{{.Repository}}:{{.Tag}}' | grep "^${NAMESPACE}/" || true
