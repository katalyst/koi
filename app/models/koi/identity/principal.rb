# frozen_string_literal: true

module Koi
  module Identity
    class Principal
      def initialize(assertion)
        @assertion = assertion
      end

      def attributes_for_find
        { id: nil }
      end

      class Aws < Principal
        def email
          tag("email")
        end

        def name
          tag("name")
        end

        def attributes_for_find
          { email: }
        end

        private

        def tag(name)
          raise JWT::VerificationError, "unverified assertion" unless @assertion.verified?

          @assertion.claims.dig("https://sts.amazonaws.com/", "principal_tags", name)
        end
      end
    end
  end
end
