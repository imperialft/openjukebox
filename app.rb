# :encoding: utf-8

module OpenJukebox

  @env = (ENV['RACK_ENV'] || :development).to_sym
  # @return [Symbol]
  def self.env
    @env
  end

  require 'ripl' unless env == :production

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
    OmniAuth.setup(self)
    get '/' do
      haml :index
    end
    get '/songs' do
      @songs = Song.all
      haml :songs
    end
    get '/songs/refresh' do
      Song.refresh!
      redirect '/songs'
    end
    post '/songs/:id/play' do
      if signed_in?
        if @song = Song.get(params[:id])
          @song.play(user)
        else
          halt 404, "That doesn't exist."
        end
      else
        halt 401, 'Please sign-in first.'
      end
    end
  end

end