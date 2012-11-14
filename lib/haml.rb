require 'haml'

module Haml::Filters
  module CoffeeScript
    include Base
    require 'uglifier'
    require 'coffee_script'
    def render(src)
      compiled = ::Uglifier.compile(::CoffeeScript.compile(src))
      compiled.strip!
      "<script type='text/javascript' data-language='coffeescript'>" + compiled + "</script>"
    end
  end
  module Scss
    include Base
    require 'sass'
    def render(src)
      compiled = ::Sass.compile(src, :cache => false, :style => :compressed)
      compiled.strip!
      "<style type='text/css' data-language='scss'>" + compiled + "</style>"
    end
  end
end