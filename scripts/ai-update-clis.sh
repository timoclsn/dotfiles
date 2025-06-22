#!/bin/bash
set -e

echo "Updating AI CLIs..."

npm i -g @anthropic-ai/claude-code
npm i -g @sourcegraph/amp
npm i -g opencode-ai
npm i -g @openai/codex@native

echo "AI CLIs updated successfully!"
