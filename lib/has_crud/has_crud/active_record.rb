require_relative 'active_record/crud_additions'

module HasCrud
  module ActiveRecord
    extend ActiveSupport::Concern

    module ClassMethods
      def has_crud(options={})
        send :include, HasCrud::ActiveRecord::CrudAdditions
        send :include, Rails.application.routes.url_helpers

        cattr_accessor :crud
        cattr_accessor :options

        self.crud = KoiConfig::Config.new

        #FIXME: refactor
        has_navigation if options[:navigation].eql?(true)

        if options[:settings].eql?(true)
          has_settings
        else
          options[:settings] = false
        end

        if options[:settings] && table_exists?
          Koi::Settings.collection.each do |key, values|
            unless Setting.find_by_prefix_and_key(settings_prefix, key)
              Setting.create(values.merge(key: key, prefix: settings_prefix))
            end
          end
        end

        if options[:orderable]
          options[:ajaxable]   = false if options[:ajaxable].nil?
          options[:searchable] = false if options[:searchable].nil?
          options[:paginate]   = false if options[:paginate].nil?
          options[:sortable]   = false if options[:sortable].nil?
        end

        scope :ordered, :order => 'ordinal ASC' if options[:orderable]

        options[:sortable] = true if options[:sortable].eql?(nil)
        options[:ajaxable] = true unless options[:ajaxable].eql?(false)

        if !options[:searchable].eql?(false) && table_exists?
          ignore_fields = [:created_at, :updated_at, :slug]
          if options[:searchable].eql?(true) || options[:searchable].eql?(nil)
            options[:searchable] = column_names.collect { |c| c.to_sym } - ignore_fields
          end
          scoped_search :on => options[:searchable]
        end

        options[:scope] ? (default_scope order("id ASC")) : (default_scope order(options[:scope]))

        if !options[:slugged].eql?(false) && table_exists? && column_names.include?("slug")
          send :extend, FriendlyId
          friendly_id (options[:slugged] || :to_s), :use => :slugged
        end

        unless options[:paginate].eql?(false)
          options[:paginate] = 10 if options[:paginate].nil? || options[:paginate].eql?(true)
          options[:page_list] = [10, 20, 50, 100] if options[:page_list].nil?
          paginates_per options[:paginate]
        end

        self.options = options
      end

      def has_crud?
        false
      end
    end
  end
end
