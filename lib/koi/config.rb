# frozen_string_literal: true

module Koi
  class Config
    attr_reader :settings

    def setup(defaults = nil)
      @namespace = []
      @settings = Hash.new({})
      @settings = defaults || {
        ignore: %i[id created_at updated_at cached_slug slug ordinal aasm_state],
        admin:  { ignore: %i[id created_at updated_at cached_slug slug ordinal aasm_state] },
        map:    {
          image_uid: :image,
          file_uid:  :file,
          data_uid:  :data,
        },
        fields: {
          description: { type: :rich_text },
          image:       { type: :image },
          file:        { type: :file },
        }
      }
    end

    def initialize(args = {})
      if args.empty?
        setup
      else
        setup(deep_merge(args[:defaults], {
                           ignore: [],
                           admin:  { ignore: [] },
                           map:    {},
                           fields: {},
                         }))
      end
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

    def respond_to_missing?(_sym)
      true
    end

    def to_inspect
      @settings
    end

    def find(*attrs)
      attr_count = attrs.size
      current_val = @settings
      (0..(attr_count - 1)).each do |i|
        attr_name = attrs[i]
        return current_val[attr_name] if i == (attr_count - 1)
        return nil if current_val[attr_name].nil?

        current_val = current_val[attr_name]
      end
      nil
    end

    def merge!(config)
      @settings = deep_merge(@settings, config)
    end

    private

    def deep_merge(hash1, hash2)
      hash1.deep_merge(hash2) do |_key, this_val, other_val|
        if this_val.is_a?(Array) && other_val.is_a?(Array)
          this_val + other_val
        else
          other_val
        end
      end
    end

    def namespace_value(hash = {})
      if @namespace.empty?
        @settings = deep_merge(@settings, hash)
      else
        namespace = @namespace.dup
        lastkey = namespace.pop
        subhash = namespace.reduce(@settings) { |result, k| result[k] }
        subhash[lastkey] = deep_merge(subhash[lastkey], hash)
      end
    end
  end
end
