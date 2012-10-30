module OpenJukebox
  module AppHelper

    # @param [String] file
    # @return [String]
    def asset_tag(file, type = nil)
      case type ? ".#{type}" : file[/\.[\w\d]+$/]
      when '.css'
        '<link rel="stylesheet" type="text/css" href="' + asset_path(file) + '"></link>'
      when '.js'
        '<script type="text/javascript" src="' + asset_path(file) +'"></script>'
      when '.gif', '.png', '.jpg', '.jpeg'
        '<img src="' + asset_path(file) + '"/>'
      else
        raise ArgumentError.new('Cannot determine an asset tag for ' + file.inspect)
      end
    end

    # @param [String] file
    # @return [String]
    def asset_path(file)
      file =~ /^https?:\/\// ? file : '/assets/' + file
    end

  end # module AppHelper
end # module OpenJukebox