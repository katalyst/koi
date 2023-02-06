# frozen_string_literal: true

require_relative "active_record/crud_additions"

module HasCrud
  module ActiveRecord
    extend ActiveSupport::Concern

    def crud
      self.class.crud
    end

    def options
      self.class.options
    end

    module ClassMethods
      attr_accessor :crud, :options

      def has_crud(options = {})
        send :include, HasCrud::ActiveRecord::CrudAdditions
        send :include, Rails.application.routes.url_helpers

        self.options = options

        self.crud = default_crud_config

        before_setup_crud
        setup_crud
        after_setup_crud
      end

      def has_crud?
        false
      end

      private

      def default_crud_config
        Koi::Config.new default_crud_config_options
      end

      def default_crud_config_options
        {}
      end

      def before_setup_crud; end

      def after_setup_crud; end

      def setup_crud
        setup_orderable
        setup_sortable
        setup_ajaxable
        setup_searchable
        setup_scope
        setup_pagination
        setup_exportable
      rescue ::ActiveRecord::ConnectionNotEstablished, ::ActiveRecord::NoDatabaseError
        # skip initialization, no database available
      end

      def setup_orderable
        if options[:orderable]
          # Disable search, pagination and sort by default
          # as in order for orderable to work we need to
          # show all records on one page
          options[:ajaxable]   = false if options[:ajaxable].nil?

          options[:searchable] = false if options[:searchable].nil?

          options[:paginate]   = false if options[:paginate].nil?

          options[:sortable]   = false if options[:sortable].nil?

          scope :ordered, -> { order("ordinal ASC") }
        end
      end

      def setup_sortable
        options[:sortable] = true if options[:sortable].eql?(nil)
      end

      def setup_ajaxable
        options[:ajaxable] = true if options[:ajaxable].eql?(true)
      end

      def setup_searchable
        if !options[:searchable].eql?(false) && database_and_table_exists?
          setup_default_searchable if options[:searchable].eql?(true) || options[:searchable].eql?(nil)

          scoped_search on: options[:searchable]
        end
      end

      def setup_default_searchable
        ignore_fields        = %i[created_at updated_at slug]
        options[:searchable] = column_names.map(&:to_sym) - ignore_fields
      end

      def setup_scope
        scope = options[:scope]

        if scope.present?
          warn <<~WARN
            DEPRECATION WARNING: [KOI] #{self} - using `has_crud scope: "#{scope}"` is deprecated,
            please set default scope in the model itself by using `default_scope order("id ASC")`
          WARN
        end

        scope ? (default_scope { order("id ASC") }) : (default_scope { order(scope) })
      end

      # Note: table_exists? throws an exception if the database doesn't exist.
      def database_and_table_exists?
        table_exists?
      rescue ::ActiveRecord::StatementInvalid
        false
      end

      def setup_pagination
        unless options[:paginate].eql?(false)
          setup_default_pagination
          paginates_per options[:paginate]
        end
      end

      def setup_default_pagination
        options[:paginate]  = 10 if options[:paginate].nil? || options[:paginate].eql?(true)

        options[:page_list] = [10, 20, 50, 100] if options[:page_list].nil?
      end

      def setup_exportable
        # set exportable: true by default
        options[:exportable] = true if options[:exportable].nil?
        make_exportable if options[:exportable]
      end
    end
  end
end
