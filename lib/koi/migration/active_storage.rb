module Koi
  module Migration
    class ActiveStorage
      # This migration is used to convert dragonfly accessors to active storage attachments.
      # @param migrations [Array] list of migrations to perform in the format "model_name:dragonfly_attribute:attachment_attribute"
      def migrate_models(migrations: [], dry_run: false)
        check_prerequisites

        migrations.each do |migration|
          model_name, dragonfly_attribute, attachment_attribute = migration.split(/:/)
          puts "migrating #{model_name} records #{dragonfly_attribute} -> #{attachment_attribute}"

          model_name.constantize.find_each do |record|
            data = record.public_send(dragonfly_attribute)
            next if data.nil?

            content_type = MIME::Types.type_for(data.name).first&.content_type
            description  = "#{model_name}:#{record.id} (#{data.name} #{content_type})"

            if record.public_send(attachment_attribute).present?
              puts "skipping #{description}, #{attachment_attribute} already present"
              next
            end

            record.public_send(attachment_attribute)
                  .attach(io:           StringIO.new(data.data),
                          filename:     data.name,
                          content_type: content_type)
            record.save! unless dry_run

            puts "converted #{description}"
          end
        end
      end

      # This migration is used to update URLs in model attributes from dragonfly files/images to active storage.
      # @param migrations [Array] list of migrations to perform in the format "model_name:attribute_name"
      #
      # 1. For every model_name record in the database, the description attribute is scanned for dragonfly media urls.
      # 2. For each dragonfly media url found, the dragonfly uid is extracted from the base64 encoded data.
      # 3. Attempt to find a record for a model that defines a dragonfly_accessor with a matching uid.
      #     For example, for the Koi Document model with a dragonfly_accessor :data, if a Document is found with
      #     data_uid equal to the extracted uid it will be used as a match.
      # 4. If a match is found, the 'url' method of the matching record is called to construct a replacement url.
      # 5. The url in the attribute is substituted from the result from step 4 and the record is saved.
      def migrate_attributes(migrations: [], dry_run: false)
        check_prerequisites

        migrations.each do |migration|
          model_name, attribute_name = migration.split(/:/)
          puts "migrating #{model_name} records #{attribute_name} attributes"

          application_host = Rails.application.config.action_mailer.default_url_options[:host]

          # scan model name records
          model_name.constantize.find_each do |record|
            description = "#{model_name}:#{record.id} #{attribute_name}"

            value = record[attribute_name]
            next if value.blank?

            # substitute dragonfly media urls in this attribute
            record[attribute_name] = value.gsub(%r{(?:https?://[^/]+)?/media/([^/]{16,})/[^"'\b]+}) do |match|
              base64         = $1
              dragonfly_data = parse_dragonfly_data(base64)
              uid            = dragonfly_data[:uid]

              if uid.blank?
                puts "skipped #{description}, could not parse base64: #{base64} (#{match})"
                next
              end

              # convert dragonfly media url to new url defined by target_record.url_method
              target_record, target_attribute_name = find_record_by_dragonfly_uid(uid)
              url_method                           = "#{target_attribute_name}_url"

              if target_record.blank?
                puts "skipped #{description}, could not find matching uid #{uid} in database"
                match
              elsif !target_record.respond_to?(url_method)
                puts "skipped #{description} as it does not define #{url_method}"
                match
              else
                url = target_record.send(url_method, dragonfly_data).sub(/^#{application_host}/, '')
                puts "converted #{description} #{match} -> #{url} (#{target_record.class.name}:#{target_record.id})"
                url
              end
            end

            record.save! unless dry_run
          end
        end
      end

      private

      def check_prerequisites
        raise "Dragonfly is not enabled" unless Koi::KoiAsset.use_dragonfly?
        raise "Active storage is not enabled" unless Koi::KoiAsset.use_active_storage?
      end

      def parse_dragonfly_data(base64)
        dragonfly_data = JSON.parse(Base64.decode64(base64))
        # ["p", "thumb", "300x300"]
        result        = {
          uid: dragonfly_data.dig(0, 1)
        }
        result[:size] = dragonfly_data.dig(1, 2) if dragonfly_data.dig(1, 1) == "thumb"
        result
      rescue JSON::ParserError => e
        nil
      end

      # @return result [Array] [record, attribute_name]
      def find_record_by_dragonfly_uid(uid)
        dragonfly_attributes.each do |klass, attribute_names|
          attribute_names.each do |attribute_name|
            record_id = dragonfly_uid_map(klass, attribute_name)[uid]
            next if record_id.blank?

            return [klass.find(record_id), attribute_name]
          end
        end
        nil
      end

      # @param klass [Class] ApplicationRecord subclass which defines a dragonfly accessor
      # @param attribute [String] Dragonfly accessor attribute name, e.g. data
      # @return [Hash] mapping from dragonfly uid to record id for the class and attribute
      def dragonfly_uid_map(klass, attribute)
        @dragonfly_uid_map ||= {}
        key                = "#{klass.name}:#{attribute}"
        return @dragonfly_uid_map[key] if @dragonfly_uid_map.include?(key)

        @dragonfly_uid_map[key] = klass.pluck("#{attribute}_uid", :id).to_h
      end

      def dragonfly_attributes
        @dragonfly_attributes ||= find_dragonfly_attributes
      end

      def find_dragonfly_attributes
        Rails.application.eager_load!
        # NOTE: ApplicationRecord descendants does not include Koi models
        ActiveRecord::Base.descendants
                          .select { |klass| klass.respond_to?(:dragonfly_attachment_classes) }
                          .select { |klass| klass.dragonfly_attachment_classes.present? }
                          .map { |klass| [klass, klass.dragonfly_attachment_classes.map(&:attribute)] }
      end
    end
  end
end
