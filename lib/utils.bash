#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/denoland/deno"
TOOL_NAME="deno"
TOOL_TEST="deno --version"

fail() {
  echo "asdf-${TOOL_NAME}: $*"
  exit 1
}

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_all_versions() {
  curl -fsSL "https://deno.com/versions.json" |
    sed -n 's/.*"cli":\[\(.*\)\].*/\1/p' |
    grep -o '"v[0-9.]\+\(-rc\.[0-9]\+\)\?"' |
    sed 's/"v\(.*\)"/\1/'
}

latest_version() {
  list_all_versions | sort_versions | tail -n1 | xargs echo
}

resolve_version() {
  local version="$1"

  if [ "$version" = "latest" ]; then
    version="$(latest_version)"
  fi

  echo "$version"
}

download_release() {
  local version filename url
  version="$1"
  filename="$2"

  url="$(release_url "$version")"

  echo "* Downloading ${TOOL_NAME} release ${version}..."
  curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download ${url}"
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="${3%/bin}/bin"

  if [ "$install_type" != "version" ]; then
    fail "asdf-${TOOL_NAME} supports release installs only"
  fi

  (
    mkdir -p "$install_path"
    cp -R "${ASDF_DOWNLOAD_PATH}/." "$install_path"

    # Assert deno executable exists
    local tool_cmd
    tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
    test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

    # Create .deno directory if strictly needed here,
    # but exec-env handles DENO_INSTALL_ROOT.
    # The original install script created it, so we keep it.
    mkdir -p "${install_path}/../.deno"

    echo "$TOOL_NAME $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error occurred while installing $TOOL_NAME $version."
  )
}

detect_platform() {
  local version="$1"
  local platform=""

  # Legacy logic from original install script
  if [[ $version > "0.35.0" ]]; then
    case "$OSTYPE" in
      darwin*) platform="apple-darwin" ;;
      linux*) platform="unknown-linux-gnu" ;;
      msys*) platform="pc-windows-msvc" ;;
      *) fail "Unsupported platform" ;;
    esac
  else
    case "$OSTYPE" in
      darwin*) platform="osx" ;;
      linux*) platform="linux" ;;
      *) fail "Unsupported platform" ;;
    esac
  fi
  echo "$platform"
}

detect_architecture() {
  local version="$1"
  local architecture=""

  if [[ $version > "0.35.0" ]]; then
    case "$(uname -m)" in
      x86_64) architecture="x86_64" ;;
      aarch64 | arm64) architecture="aarch64" ;;
      *) fail "Unsupported architecture" ;;
    esac
  else
    case "$(uname -m)" in
      x86_64) architecture="x64" ;;
      *) fail "Unsupported architecture" ;;
    esac
  fi
  echo "$architecture"
}

release_url() {
  local version="$1"
  local platform architecture archive_format archive_file download_base_url

  platform="$(detect_platform "$version")"
  architecture="$(detect_architecture "$version")"

  if [[ $version > "0.35.0" ]]; then
    archive_format="zip"
    archive_file="deno-${architecture}-${platform}.${archive_format}"

    download_base_url="${GH_REPO}/releases/download"
    # Logic for dl.deno.land override
    # ! < 1.0.1 means >= 1.0.1.
    # OR == 1.0.0.
    # So >= 1.0.0 uses dl.deno.land according to original script?
    # Original: if ! [[ $version < "1.0.1" ]] || [[ $version == "1.0.0" ]]; then ...
    # Bash string comparison: "1.0.0" < "1.0.1" is True.
    # So if version >= 1.0.1 OR version == 1.0.0, use dl.deno.land.
    if ! [[ $version < "1.0.1" ]] || [[ $version == "1.0.0" ]]; then
      download_base_url="https://dl.deno.land/release"
    fi
  else
    archive_format="gz"
    archive_file="deno_${platform}_${architecture}.${archive_format}"
    download_base_url="${GH_REPO}/releases/download"
  fi

  echo "${download_base_url}/v${version}/${archive_file}"
}
