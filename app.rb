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
    set :environment, OpenJukebox.env
    before { OpenJukebox.reload! } if environment == :development
    OmniAuth.setup(self)

    get '/' do
      haml :index
    end

    get '/songs' do
      require_user!
      @songs = if params[:s] && params[:s] != ''
                 Song.all(:artist.like => '%' + params[:s] + '%') | Song.all(:title.like => '%' + params[:s] + '%')
               else
                 Song.all
               end
      haml :songs
    end

    get '/songs/refresh' do
      require_user!
      Thread.start { Song.refresh! }
      redirect '/songs'
    end

    post '/songs/:id/cue' do
      require_user!
      if song = Song.get(params[:id])
        PlayLog.create(:user => user, :song => song)
        song.user = user
        queues_count = Song.queues(:push, song).size
        VLC.killall! if queues_count <= 1 && !Song.current_queue
        halt 200, queues_count.to_s # return
      else
        halt 404 # return
      end
    end

  end

end