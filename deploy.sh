#!/usr/bin/env bash

set -xe

gleam build --target erlang
gleam run -m gleescript
cp ./claude_statusline $HOME/.claude/statusline
