#!/bin/bash

export MIX_ENV=dev
export PORT=4000
export NODEBIN=`pwd`/assets/node_modules/.bin
export PATH="$PATH:$NODEBIN"

echo "Building..."

mkdir -p ~/.config

mix deps.get
mix compile
(cd assets && npm install)
(cd assets && webpack --mode production)
mix phx.digest

echo "Generating release..."
mix release

echo "Stopping old copy of app, if any..."
_build/prod/rel/memory/bin/memory stop || true

echo "Starting app..."

_build/prod/rel/memory/bin/memory foreground
