class PlayLog
  include DataMapper::Resource
  property :id, Serial
  belongs_to :user
  belongs_to :song
  timestamps :at

  require 'active_support/core_ext/date/calculations'
  def self.usage
    all(:created_at.gte => Date.today.beginning_of_month).inject({}) { |pass, it|
      if pass.has_key?(it.user)
        pass[it.user] += it.song.price
      else
        pass[it.user]  = it.song.price
      end
      pass # return
    }.sort { |(_,a),(_,b)| a <=> b }
  end

end