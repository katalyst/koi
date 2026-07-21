# frozen_string_literal: true

module Koi
  module Identity
    class Principal
      include ActiveModel::Model
      include ActiveModel::Attributes

      def self.from_assertion(config:, provider:, assertion:)
        # Note: consider pattern matching to extract name/email in the future
        return nil unless config[:subject] == assertion.subject

        attributes = {
          provider: config[:provider],
          scope:    config[:scope],
          subject:  assertion.subject,
        }

        case URI.parse(provider.issuer).host
        when /\.sts\.global\.api\.aws\z/
          attributes.merge!(
            **assertion.claims.dig("https://sts.amazonaws.com/", "principal_tags")&.slice("name", "email"),
          )
        end

        Principal.new(**attributes)
      end

      def self.dump(principal)
        principal&.attributes&.to_json
      end

      def self.load(json)
        return if json.blank?

        Principal.new(**JSON.parse(json).slice(*attribute_names))
      end

      # Required attributes
      attribute :provider, :string
      attribute :subject, :string
      attribute :scope, :string

      # Optional extensions, required for user authentication
      attribute :name, :string
      attribute :email, :string

      def attributes_for_find
        { email: }
      end

      def inspect
        "<#{self.class.name} provider=#{provider.inspect} scope=#{scope.inspect} subject=#{subject.inspect} " \
          "name=#{name.inspect} email=#{email.inspect}>"
      end

      alias :to_s :inspect
    end
  end
end
