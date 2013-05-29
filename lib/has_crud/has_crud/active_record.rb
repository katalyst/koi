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

        self.options = options

        self.crud = KoiConfig::Config.new

        setup_crud
      end

      def has_crud?
        false
      end

      private

      def setup_crud
        setup_navigation
        setup_settings
        setup_orderable
        setup_sortable
        setup_ajaxable
        setup_searchable
        setup_scope
        setup_slug
        setup_pagination
      end

      def setup_navigation
        has_navigation if self.options[:navigation].eql?(true)
      end

      def setup_orderable
        if self.options[:orderable]
          self.options[:ajaxable]   = false if self.options[:ajaxable].nil?
          self.options[:searchable] = false if self.options[:searchable].nil?
          self.options[:paginate]   = false if self.options[:paginate].nil?
          self.options[:sortable]   = false if self.options[:sortable].nil?
          scope :ordered, :order => 'ordinal ASC'
        end
      end

      def setup_settings
        if self.options[:settings].eql?(true)
          has_settings

          if table_exists?
            Koi::Settings.collection.each do |key, values|
              unless Setting.find_by_prefix_and_key(settings_prefix, key)
                Setting.create(values.merge(key: key, prefix: settings_prefix))
              end
            end
          end
        else
          self.options[:settings] = false
        end
      end

      def setup_sortable
        self.options[:sortable] = true if self.options[:sortable].eql?(nil)
      end

      def setup_ajaxable
        self.options[:ajaxable] = true unless self.options[:ajaxable].eql?(false)
      end

      def setup_searchable
        if !self.options[:searchable].eql?(false) && table_exists?
          ignore_fields = [:created_at, :updated_at, :slug]
          if self.options[:searchable].eql?(true) || self.options[:searchable].eql?(nil)
            self.options[:searchable] = column_names.collect { |c| c.to_sym } - ignore_fields
          end
          scoped_search :on => self.options[:searchable]
        end
      end

      def setup_scope
        self.options[:scope] ? (default_scope order("id ASC")) : (default_scope order(self.options[:scope]))
      end

      def setup_slug
        if !self.options[:slugged].eql?(false) && table_exists? && column_names.include?("slug")
          send :extend, FriendlyId
          use = [:slugged]
          use << :history if FriendlyIdSlug.table_exists?
          friendly_id (self.options[:slugged] || :to_s), use: use
        end
      end

      def setup_pagination
        unless self.options[:paginate].eql?(false)
          self.options[:paginate] = 10 if self.options[:paginate].nil? || self.options[:paginate].eql?(true)
          self.options[:page_list] = [10, 20, 50, 100] if self.options[:page_list].nil?
          paginates_per self.options[:paginate]
        end
      end

    end
  end
end
