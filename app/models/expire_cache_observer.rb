class ExpireCacheObserver < ActiveRecord::Observer

  observe :nav_item

  def after_save(record)
    clear_cache("saving", record)
  end

  def after_destroy(record)
    clear_cache("deleting", record)
  end

  private

    def clear_cache(msg, record)
      Rails.logger.warn("[CACHE CLEAR] - Clearning entire cache after #{msg} #{record.class} #{record.id}")
      NavItem.clear_cache
    end

end
