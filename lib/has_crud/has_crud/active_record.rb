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
          # Disable search, pagination and sort by default
          # as in order for orderable to work we need to
          # show all records on one page
          if self.options[:ajaxable].nil?
            self.options[:ajaxable] = false
          end

          if self.options[:searchable].nil?
            self.options[:searchable] = false
          end

          if self.options[:paginate].nil?
            self.options[:paginate] = false
          end

          if self.options[:sortable].nil?
            self.options[:sortable] = false
          end

          scope :ordered, :order => 'ordinal ASC'
        end
      end

      def setup_settings
        if self.options[:settings].eql?(true)
          has_settings

          if table_exists?
            Koi::Settings.collection.each do |key, values|
              create_setting(key, values)
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
          if self.options[:searchable].eql?(true) || self.options[:searchable].eql?(nil)
            setup_default_searchable
          end

          scoped_search :on => self.options[:searchable]
        end
      end

      def setup_default_searchable
        ignore_fields = [:created_at, :updated_at, :slug]
        self.options[:searchable] = column_names.collect { |c| c.to_sym } - ignore_fields
      end

      def setup_scope
        scope = self.options[:scope]

        unless scope.blank?
          warn(<<-EOS
            DEPRECATION WARNING: [KOI] #{self} - using `has_crud scope: "#{scope}"` is deprecated, please set default scope in the model itself by using `default_scope order("id ASC")`
            EOS
          )
        end

        scope ? (default_scope order("id ASC")) : (default_scope order(scope))
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
          setup_default_pagination
          paginates_per self.options[:paginate]
        end
      end

      def setup_default_pagination
        if self.options[:paginate].nil? || self.options[:paginate].eql?(true)
          self.options[:paginate] = 10
        end

        if self.options[:page_list].nil?
          self.options[:page_list] = [10, 20, 50, 100]
        end
      end

    end
  end
end
