# frozen_string_literal: true

$stdout.sync = true
$stderr.sync = true

require_relative '../app/app'
require_relative '../app/externals'
externals = Externals.new
run App.new(externals)
