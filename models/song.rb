class Song
  include DataMapper::Resource
  property :id, Serial
  property :title, String, :required => true,
                           :index    => true,
                           :length   => 100
  property :artist, String, :required => true,
                            :index    => true,
                            :length   => 100
  property :album, String, :required => true,
                           :index    => true,
                           :length   => 100             
  validates_uniqueness_of :title, :scope => [:artist, :album]
  property :path, String, :required => true,
                          :length   => 2**16
end