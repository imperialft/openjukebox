source :rubygems

gem 'sinatra', :require => 'sinatra/base'
gem 'tilt'
gem 'haml'
gem 'sprockets'
gem 'coffee-script', :require => 'coffee_script'
gem 'sass'
gem 'less'
gem 'therubyracer', :require => 'v8'
gem 'execjs'
gem 'uglifier'

gem 'dm-core'
gem 'dm-types'
gem 'dm-validations'
gem 'dm-migrations'
gem 'dm-timestamps'

group :production do
  gem 'dm-mysql-adapter'
end

group :development, :test do
  gem 'dm-sqlite-adapter'
end

gem 'puma'

group :test do
  gem 'rspec-core'
  gem 'rspec-expectations'
  gem 'rspec-mocks'
end