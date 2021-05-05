module KoiConfig
  class Config
    attr_reader :settings

    def setup(defaults=nil)
      @namespace = []
      @settings = Hash.new({})
      @settings = defaults || {
        :ignore => [:id, :created_at, :updated_at, :cached_slug, :slug, :ordinal, :aasm_state],
        :admin =>  { :ignore => [:id, :created_at, :updated_at, :cached_slug, :slug, :ordinal, :aasm_state] },
        :map => {
          :image_uid => :image,
          :file_uid => :file,
          :data_uid => :data
        },
        :fields => {
          :description => { :type => :rich_text },
          :image => { :type => :image },
          :file => { :type => :file }
        }
      }
    end

    def initialize(args={})
      args.empty? ? setup : setup(args[:defaults].deeper_merge!({
                              :ignore => [], :admin => { :ignore => [] },
                              :map => {}, :fields => {}
                            }))
    end

    def method_missing(sym, *args, &block)
      if sym.eql?(:config) && !args.empty?
        @namespace.push(args.first)
      else
        namespace_value({sym => args.first}) if args.size > 0
      end
      instance_eval(&block) if block_given?
      @namespace.pop if sym.eql?(:config) && !args.empty?
    end

    def to_inspect
      @settings
    end

    def find(*attrs)
      attr_count = attrs.size
      current_val = @settings
      for i in 0..(attr_count-1)
        attr_name = attrs[i]
        return current_val[attr_name] if i == (attr_count-1)
        return nil if current_val[attr_name].nil?
        current_val = current_val[attr_name]
      end
      return nil
    end

    private

    def namespace_value(hash={})
      if @namespace.empty?
        @settings.deeper_merge!(hash)
      else
        namespace = @namespace.dup
        lastkey = namespace.pop
        subhash = namespace.inject(@settings) { |hash, k| hash[k] }
        subhash[lastkey].deeper_merge!(hash)
      end
    end
  end
end
