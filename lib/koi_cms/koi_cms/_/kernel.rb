Kernel.module_eval do

  def with(arg)
    yield arg unless arg.nil?
  end

end
