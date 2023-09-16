#!/usr/bin/env bats

@test "install command fails if the input is a ref and cargo is not installed" {
  run asdf install deno ref
  [ "$status" -eq 1 ]
  echo "$output" | grep "build from source (latest) require 'cargo' to be installed"
}
