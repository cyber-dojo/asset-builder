#!/usr/bin/env bash
set -Eeu

# Compiles Sprockets assets and writes app.js and app.css to <out-dir>.
# Must be run from /app (the Sprockets working directory).
# Usage: /app/config/compile.sh <out-dir>

readonly OUT_DIR="${1}"
mkdir --parents "${OUT_DIR}"
export OUT_DIR

ruby << 'RUBY'
require 'sprockets'
require 'uglifier'

env = Sprockets::Environment.new
env.append_path('app/assets/javascripts')
env.js_compressor  = Uglifier.new(harmony: true)
env.append_path('app/assets/stylesheets')
env.css_compressor = :sassc

out = ENV.fetch('OUT_DIR')
File.write("#{out}/app.js",  env['app.js'].source)
File.write("#{out}/app.css", env['app.css'].source)
RUBY
