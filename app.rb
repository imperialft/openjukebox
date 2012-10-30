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
    get '/' do
      haml :index
    end
  end

end