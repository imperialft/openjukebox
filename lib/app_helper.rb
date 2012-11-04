module OpenJukebox
  module AppHelper
    require_relative './cache'
    include Cache

    def number_to_yen(n)
      '&yen;' + n.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
    end

    def link_to_twitter(user)
      '<a href="http://twitter.com/' + user.info['nickname'] + '">@' + user.info['nickname'] + '</a>'
    end

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