class Cue
  include DataMapper::Resource
  timestamps :at
  property :id, Serial
  belongs_to :user
  belongs_to :song
  property :priority, Enum[:cue, :cut_in], :required => true,
                                             :index    => true,
                                             :default  => :cue
  property :started_at, DateTime
  property :stopped_at, DateTime
  property :rate, Decimal, :scale     => 2,
                           :precision => 5

  # @return [Numeric] per minute price of a song.
  def self.rate_per_minute
    10
  end
  
  # @return [Numeric] per minute price multiplier when cut into a song that hasn't finished.
  def self.cut_in_multiplier
    1.5
  end

  def self.current_cues
    all(:started_at => nil, :order => :created_at.asc)
  end

  def self.stats
    t = Date.today
    all(:started_at.gte => Time.new(t.year, t.month), :stopped_at.not => nil).inject Hash.new(0) do |hash, cue|
      hash[cue.user] += (cue.stopped_at - cue.started_at) * 1440 * cue.rate
      hash # next
    end
  end

end