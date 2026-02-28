#!/usr/bin/env bash
# Render build script for ex338
# Replaces Heroku buildpacks (elixir_buildpack.config + phoenix_static_buildpack.config)
set -o errexit

# Initial setup
mix deps.get --only prod
MIX_ENV=prod mix compile

# Install npm dependencies for asset build
cd assets && npm ci && cd ..

# Build assets
MIX_ENV=prod mix assets.deploy

# Generate release files and build the release
MIX_ENV=prod mix phx.gen.release
MIX_ENV=prod mix release --overwrite
