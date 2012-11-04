class User
  include DataMapper::Resource
  has n, :cues
  property :id, Serial

  property :provider, String, :required => true,
                              :index    => true
  property :uid, String, :required => true,
                         :index    => true
  validates_uniqueness_of :uid, :scope => :provider

  property :info, Json, :default => '{}'

  def name
    info['nickname']
  end

  property :token, String, :index  => true,
                           :unique => true,
                           :length => 40

  @token_chars = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
  def self.generate_token(n = token.length)
    s = ''
    n.times { s << @token_chars.sample }
    s.freeze
    s # return
  end

  def new_token!
    t = self.class.generate_token
    update :token => t
    t # return
  end

end