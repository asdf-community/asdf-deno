#!/usr/bin/env bash

fail() {
  echo -e "\e[31mFail:\e[m $*" >&2
  exit 1
}

cli_platform() {
  case "$(uname -s)" in
    Darwin) echo macOS ;;
    Linux) echo linux ;;
    *) fail "Unsupported platform" ;;
  esac
}

cli_arch() {
  if [ "$(cli_platform)" = 'macOS' ]; then
    echo amd64
    return 0
  fi

  case "$(arch)" in
    arm64) echo arm64 ;;
    *64) echo amd64 ;;
    *86) echo 386 ;;
    *) fail "Unsupported arch" ;;
  esac
}
