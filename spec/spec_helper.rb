#!/usr/bin/env ruby
# :encoding: utf-8

ENV['RACK_ENV'] = 'test'
require_relative '../app'
Dir.glob(File.expand_path('../behaviors/**/*.rb', __FILE__)).each { |rb| require(rb) }
DataMapper.auto_upgrade!

describe OpenJukebox do
  its(:env) { should == :test }
end