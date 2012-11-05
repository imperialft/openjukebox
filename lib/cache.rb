module Cache
  @store ||= Hash.new
  def self.store
    @store
  end
  def object_cache(name)
    Cache.store[name] ||= yield
  end
  def object_cache_set(name, object = nil)
    puts "Setting #{name} = #{object.inspect}"
    Cache.store[name] = object || yield
  end
  def object_cache_get(name)
    Cache.store[name]
  end
  def object_cache_delete(name)
    Cache.store.delete(name)
  end
  extend self
end