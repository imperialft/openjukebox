# :encoding: utf-8

module OpenJukebox

  @env = (ENV['RACK_ENV'] || :development).to_sym
  # @return [Symbol]
  def self.env
    @env
  end

  require 'pathname'
  @root = Pathname.new(File.expand_path('../', __FILE__))
  # @return [Pathname]
  def self.root
    @root
  end

  require 'bundler'
  Bundler.setup(:default, env)

  require 'dm-core'
  require 'dm-types'
  require 'dm-validations'
  require 'dm-migrations'
  require 'dm-timestamps'

  # @return [Array[String]]
  def self.reload!
    Dir.glob(root + "{lib,models}" + "**" + "*.rb").each do |rb|
      env == :production ? require(rb) : load(rb)
    end
  end
  if ENV['DATABASE_URL']
    DataMapper.setup(:default, ENV['DATABASE_URL'])
  else
    DataMapper.setup(:default, :adapter => 'sqlite3', :database => root + 'tmp' + "openjukebox_#{env}.sqlite3")
  end
  reload!
  DataMapper.auto_upgrade!

  require 'sinatra/base'
  class App < Sinatra::Base
    helpers AppHelper
    require 'tilt'
    require 'less'
    set :environment, OpenJukebox.env
    if environment == :development
      before do
        OpenJukebox.reload!
      end
    end
    require 'omniauth'
    use OmniAuth::Builder do
      # Obtain this from here: https://dev.twitter.com/apps/3548274/show
      provider :twitter, 'ofa8iNrVBp2Wkm15fEMg', 'jv4Jm1XlMJWKPz9m88lqPruAeAk8vcYAuASQTBfwu8'
    end
    get '/' do
      haml :index
    end
    get '/auth/:name/callback' do
      data = request.env['omniauth.auth']
      Ripl.start binding:binding
    end
  end

end