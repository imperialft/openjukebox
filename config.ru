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

Thread.start do
  Module.new do
    extend Cache
    vlc = VLC.new
    loop do
      if cue = Cue.current_cues.first
        begin
          cue.started_at = DateTime.now
          cue.rate = object_cache('current_rate') { Cue.rate_per_minute }
          cue.save
          object_cache_set('current_cue', cue)
          vlc.play(cue.song.fullpath)
          cue.stopped_at = DateTime.now
          cue.save
          object_cache_delete('current_cue')
        rescue Exception
        end
      else
        if song = Song.first(:offset => rand(Song.count))
          vlc.play(song.fullpath) # Plays some random song.
        else
          sleep 60 # There're no song in the library...
        end
      end
      sleep 5
    end
  end # Module.new do
end

run OpenJukebox::App