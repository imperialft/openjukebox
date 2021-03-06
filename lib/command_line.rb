module OpenJukebox
  class CommandLine
    def inspect
      "#<#{self.class.to_s} @binary=#{binary} @version=#{version}>"
    end
    def version
      raise NotImplementedError
    end
    def self.killall!
      system "killall #{File.basename(binary)} 2> /dev/null > /dev/null"
    end
    private
    def measure
      t = Time.now
      yield
      (Time.now - t).round # return
    end
    require 'escape'
    def exec(*args)
      args.unshift(self.class.binary)
      `#{Escape.shell_command(args)} 2>&1`.strip
    end
    def self.binary
      raise NotImplementedError
    end
  end
end

class VLC < OpenJukebox::CommandLine
  def play(uri)
    measure do
      exec uri, "vlc://quit", "-I", "dummy", "--no-video", "--audio-filter=normalizer", "--volume=384"
    end
  end
  def version
    @version ||= exec('--version')[/[\d\.]+/]
  end
  private
  def self.binary
    @binary ||= Dir.glob('{/usr/bin/vlc,/usr/local/bin/vlc,/Applications/VLC.app/Contents/MacOS/VLC}').first
  end
end

class FFMPEG < OpenJukebox::CommandLine
  require 'active_support/core_ext/string'
  def metainfo(fullpath)
    content = exec("-i", fullpath).split(/\n/)
    hours, mins, secs, _ = content.find { |s| s =~ /\d{2}:\d{2}:\d{2}\.\d{2}/ }[/\d{2}:\d{2}:\d{2}\.\d{2}/].scan(/\d+/).map(&:to_i)
    { # return
      :album    => (content.find { |s| s =~ /album/ } || 'Unknown Album').split(':').last.strip.titleize,
      :artist   => (content.find { |s| s =~ /artist/ } || 'Unknown Artist').split(':').last.strip.titleize,
      :title    => (content.find { |s| s =~ /title/ } || File.basename(fullpath).sub(/\.[a-z0-9]{3,}$/, '')).split(':').last.strip.titleize,
      :duration => hours * 60 * 60 + mins * 60 + secs
    }
  end
  def version
    @version ||= exec('-version 1')[/[\d\.]+/]
  end
  private
  def self.binary
    @binary ||= Dir.glob('/usr/{bin,local/bin}/ffmpeg').first
  end
end