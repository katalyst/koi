# frozen_string_literal: true

require "active_support/core_ext/module/delegation"
require "active_support/core_ext/object/blank"
require "json"
require "logger"
require "active_support/logger"

# Wraps any standard Logger object to provide structured logging capabilities.
#
# May be called with a block:
#
#   logger = StructuredLogging.new(Logger.new(STDOUT))
#   logger.context(key: value) { logger.info 'Stuff' } # Logs "{ message: 'Stuff', key: 'value' }"
module Koi
  module StructuredLogging
    module Formatter # :nodoc:
      # This method is invoked when a log event occurs.
      def call(severity, time, progname, msg)
        payload = {
          type: "default",
          env:  Rails.env,
        }
        payload = current_contexts.reduce(payload, &:merge)

        payload = if msg.is_a?(Hash)
                    payload.merge(msg)
                  else
                    payload.merge(message: msg.to_s)
                  end

        super(severity, time.iso8601(6), progname || File.basename($0), payload)
      end

      def context(**context)
        new_context = push_contexts(context)
        yield self
      ensure
        pop_contexts(new_context.size)
      end

      def push_contexts(*contexts)
        contexts.compact_blank!
        current_contexts.concat contexts
        contexts
      end

      def pop_contexts(size = 1)
        current_contexts.pop size
      end

      def clear_contexts!
        current_contexts.clear
      end

      def current_contexts
        # We use our object ID here to avoid conflicting with other instances
        thread_key = @thread_key ||= "structured_logging_context:#{object_id}"
        ActiveSupport::IsolatedExecutionState[thread_key] ||= []
      end
    end

    class BasicFormatter # :nodoc:
      # This method is invoked when a log event occurs.
      def call(severity, time, _progname, payload)
        if payload.is_a?(Hash)
          message = payload.delete(:message) || ""
          if Rails.env.local?
            payload.delete(:env)
            payload.delete(:type)
          end
        else
          message = payload
          payload = {}
        end

        payload_string = payload.map { |k, v| "#{k}: #{v}" }.join(", ")
        message        = message.strip + " (#{payload_string})" if payload_string.present?
        format("[%<time>s] %<severity>6s -- %<message>s\n", time:, severity:, message:)
      end
    end

    class JsonFormatter # :nodoc:
      # This method is invoked when a log event occurs.
      def call(severity, time, progname, payload)
        payload = { message: payload } if payload.is_a?(String)

        ::JSON.dump(time:, level: severity, program: progname, **payload).concat("\n")
      end
    end

    module LocalContextStorage # :nodoc:
      attr_accessor :current_contexts

      def self.extended(base)
        base.current_contexts = []
      end
    end

    def self.new(logger)
      logger = logger.clone

      logger.formatter = if logger.formatter
                           logger.formatter.dup
                         else
                           # Ensure we set a default formatter so we aren't extending nil!
                           StructuredLogging::BasicFormatter.new
                         end

      logger.formatter.extend Formatter
      logger.extend(self)
    end

    delegate :push_contexts, :pop_contexts, :clear_contexts!, to: :formatter

    def context(**context)
      if block_given?
        formatter.context(**context) { yield self }
      else
        logger = StructuredLogging.new(self)
        logger.formatter.extend LocalContextStorage
        logger.push_contexts(*formatter.current_contexts, context)
        logger
      end
    end

    def flush
      clear_contexts!
      super if defined?(super)
    end
  end
end
