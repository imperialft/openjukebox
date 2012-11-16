class Song
  include DataMapper::Resource
  has n, :play_logs

  property :id, Serial
  property :path, String, :required => true,
                          :unique   => true,
                          :index    => true,
                          :length   => 65536
  property :album, String, :index => true,
                           :length   => 65536
  property :artist, String, :required => true,
                            :index    => true,
                            :length   => 65536
  property :title, String, :required => true,
                           :index    => true,
                           :length   => 65536

  property :duration, Integer, :required => true

  attr_accessor :user # for use as a queue.

  def fullpath
    self.class.root + path
  end

  @formats = %w(mp3 m4a ogg wma flac ra aac wav mp4)
  def self.formats
    @formats
  end

  def self.per_minute_price
    (1 + Math.sqrt(5)) / 2
  end

  def price
    (duration / 60.0 * self.class.per_minute_price).round
  end

  @root = OpenJukebox.root + 'media'
  def self.root
    @root
  end

  def self.glob
    Dir.glob(root + '**' + "*.{#{formats.join(',')}}")
  end

  def self.refresh!
    ffmpeg = FFMPEG.new
    (glob - repository.adapter.select("SELECT DISTINCT(path) FROM #{storage_name}").map { |s| (root + s).to_s }).each do |s|
      puts "Discovered: #{s}"
      song = new(ffmpeg.metainfo(s))
      song.path = s.sub(/^#{root}\/?/, '')
      song.save || puts("Failed to save: #{song.inspect} (#{song.errors.inspect})")
    end
  end

  @current_queue = nil unless @current_queue
  def self.current_queue
    @current_queue
  end

  def self.autoplay!
    Thread.start do
      loop do
        refresh!
        sleep 60 * 5
      end
    end
    Thread.start do
      begin
        vlc = VLC.new
        at_exit { VLC.killall! }
        loop do
          if queue = queues(:shift) # See if there is a queue.
            fullpath = queue.fullpath.to_s
            puts "Got #{queue.title} (#{queues(:size)} queue(s) remaining)"
            puts "Playing."
            @mutex.synchronize { @current_queue = queue }
            if File.exists?(fullpath)
              vlc.play(fullpath)
            else
              puts "File '#{fullpath}' does not exist."
            end
            @mutex.synchronize { @current_queue = nil }
            puts "Playback ended."
          else
            vlc.play(glob.shuffle.first)
            puts "Queue empty."
          end
          sleep 3
        end
      rescue Exception => e
        Thread.main.raise(e)
      end
    end
  end

  @mutex = Mutex.new unless @mutex
  @queues = [] unless @queues
  def self.queues(op = nil, *args)
    @mutex.synchronize do
      op ? @queues.send(op, *args) : @queues
    end
  end

end