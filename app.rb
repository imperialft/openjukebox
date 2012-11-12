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
      @songs = Song.all(:order => :path.asc)
      haml :songs
    end
    get '/songs/refresh' do
      Thread.start { Song.refresh! }
      if params[:ajax]
        halt 200, 'Started refreshing songs.'
      else
        redirect '/'
      end
    end
    get '/songs/:id/cue' do
      require_user!
      if @song = Song.get(params[:id])
        Cue.create :user => user,
                   :song => @song,
                   :priority => :cue
        if params[:ajax]
          halt 200, 'The cue has been added.'
        else
          redirect '/songs'
        end
      else
        halt 404, "That doesn't exist."
      end
    end
    delete '/cues/:id' do
      if cue = Cue.get(params[:id])
        if cue.user == user
          cue.destroy
          if params[:ajax]
            halt 200, 'The cue has been deleted.'
          else
            redirect '/cues'
          end
        else
          halt 401, 'You are not authorized.'
        end
      else
        halt 404, 'Cue could not been found.'
      end
    end
  end

end