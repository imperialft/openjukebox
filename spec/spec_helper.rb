#!/usr/bin/env ruby
# :encoding: utf-8

ENV['RACK_ENV'] = 'test'
require_relative '../app'

describe OpenJukebox do
  its(:env) { should == :test }
end