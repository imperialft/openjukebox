#!/usr/bin/env ruby -S rackup
# :encoding: utf-8

require File.expand_path('../app', __FILE__)

map '/assets' do
  require 'sprockets'
  require 'coffee_script'
  require 'sass'
  environment = Sprockets::Environment.new
  require 'uglifier'
  environment.js_compressor = Uglifier.new(:unsafe => true, :copyright => false)
  %w(images javascripts stylesheets vendor).each do |name|
    environment.append_path "assets/#{name}"
  end
  run environment
end

run OpenJukebox::App