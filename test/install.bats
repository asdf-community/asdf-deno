#!/usr/bin/env bats

[ "$(git status -s)" = "" ] || (
  echo >&2 "You have an unclean workdir. Test need to operate on the latest commit, not a workdir."
  exit 1
)

unset asdf
export ASDF_DIR=$(mktemp -d)/asdf
git clone -q https://github.com/asdf-vm/asdf.git $ASDF_DIR

setup() {
  . $ASDF_DIR/asdf.sh
  asdf plugin add gh "$PWD"
}

teardown() {
  asdf plugin remove gh
}

@test "install" {
  # Random early version that doesn't look too special.
  # Won't work on arm64, tho :/
  run asdf install gh 0.4.0
  [ "$status" -eq 0 ]
  echo "$output" | grep "Downloading gh version 0.4.0"
}

@test "install latest" {
  run asdf install gh latest
  [ "$status" -eq 0 ]
  echo "$output" | grep "Downloading gh version "
}

@test "list all gh" {
  run asdf list all gh
  [ "$status" -eq 0 ]
  echo "$output" | grep "0.4.0"
  echo "$output" | grep "0.6.2"
}
