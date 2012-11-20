task :bundler do
  require 'bundler'
  Bundler.setup :default
end

task :spec do
  system 'rspec'
end

task :default => :spec

task :app => :bundler do
  require './app'
end

desc 'Refresh songs.'
task :refresh => :app do
  Song.refresh!
end