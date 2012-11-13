class VLC

  # Plays a media located at the given URI.
  # If it's a local file, the URI needs to be like file:///home/hama/some_music.mp3
  # 
  # NOTE: This blocks the thread until the end of playback, or the interrupts.
  # 
  # @return [Fixnum] Number of seconds played.
  def play(uri)
    t = Time.now
    exec '"' + uri.gsub('"', '\\"') + '"' + ' ' + playback_options
    (Time.now - t).round # return    
  end

  def version
    @version ||= exec('--version')[/[\d\.]+/]
  end

  def binary
    @binary ||= Dir.glob('{/usr/bin/vlc,/usr/local/bin/vlc,/Applications/VLC.app/Contents/MacOS/VLC}').first
  end

  def self.killall!
    system "killall VLC 2> /dev/null > /dev/null"
  end

  private

  def playback_options
    'vlc://quit --no-video --audio-filter=normalizer'
  end

  def exec(options)
    `#{binary} -I dummy #{options} 2>&1`
  end

end

__END__

    info = `ffprobe "#{path.gsub('"', '\"')}" 2>&1`.strip.split(/\n/)
    { # return
      :artist => info.find { |s| s =~ /artist/ }.split(':', 2).last.strip,
      :title  => info.find { |s| s =~ /title/  }.split(':', 2).last.strip
    }
