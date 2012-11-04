class Song
  include DataMapper::Resource
  has n, :cues
  property :id, Serial
  property :title, String, :required => true,
                           :index    => true,
                           :length   => 100
  property :artist, String, :index    => true,
                            :length   => 100
  validates_uniqueness_of :title, :scope => :artist  
  property :path, String, :required => true,
                          :length   => 2**16,
                          :unique   => true

  property :sha1, String, :required => true,
                          :length   => 40,
                          :index    => true,
                          :unique   => true

  def self.root
    @root ||= OpenJukebox.root + 'media/'
  end

  @supported_format = %w(mp3 m4a ogg flac wav)
  def self.supported_format
    @supported_format
  end

  require 'digest/sha1'
  
  def self.refresh!
    Dir.glob(root + "**/*.{#{supported_format.join(',')}}").map { |s| s.sub(/^#{root}/, '')}.each do |path|
      Song.create :title  => File.basename(path),
                  :path   => path,
                  :sha1   => Digest::SHA1.hexdigest(File.read(root + path))
    end
  end

  def fullpath
    (self.class.root + path).to_s
  end

end