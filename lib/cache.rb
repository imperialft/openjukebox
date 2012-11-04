module Cache
  @store = Hash.new
  def self.store
    @store
  end
  def object_cache(name)
    Cache.store[name] ||= yield
  end
  def object_cache_set(name, object = nil)
    Cache.store[name] = object || yield
  end
  def object_cache_get(name)
    Cache.store[name]
  end
  def object_cache_delete(name)
    Cache.store[name] = yield
  end
  extend self
end