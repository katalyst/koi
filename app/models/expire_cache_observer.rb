class ExpireCacheObserver < ActiveRecord::Observer

  observe :nav_item

  def after_save(record)
    clear_cache("saving", record) if Koi::Caching.enabled
  end

  def after_destroy(record)
    clear_cache("deleting", record) if Koi::Caching.enabled
  end

  private

    def clear_cache(msg, record)
      Rails.logger.warn("[CACHE CLEAR] - Clearning entire cache after #{msg} #{record.class} #{record.id}")
      Rails.cache.clear
    end

end
