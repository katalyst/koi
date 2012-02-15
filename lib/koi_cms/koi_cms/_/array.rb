Array.class_eval do

  def take_while!(&block)
    take_until!{ |e| ! yield e }
  end

  def take_until!(&block)
    return self unless i = index(&block)
    delete_at i until i == length
    self
  end

  def take_until
    take_while{ |e| ! yield e }
  end

  def drop_while!
    delete_at(0) while !empty? && yield(first)
    self
  end

  def delete_while
    result = []
    result.push delete_at(0) while !empty? && yield(first)
    result
  end

  def to_h
    invert.invert
  end

  def invert
    Hash[self.each_with_index.to_a]
  end

end
