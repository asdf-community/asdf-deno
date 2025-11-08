#!/usr/bin/env bats

@test "install command fails if the input is not version number" {
  run asdf install deno ref
  [ "$status" -eq 1 ]
  echo "$output" | grep "asdf-deno: supports release installs only"
}
