module EventStream
  module Postgres
    class Read
      class Error < RuntimeError; end

      initializer :stream_name, :category, :stream_position, :batch_size, :precedence

      dependency :session, Session
      dependency :iterator, Iterator
      dependency :logger, Telemetry::Logger

      def self.build(stream_name: nil, category: nil, stream_position: nil, batch_size: nil, precedence: nil, session: nil)
        new(stream_name, category, stream_position, batch_size, precedence).tap do |instance|
          Iterator.configure instance, stream_name: stream_name, category: category, stream_position: stream_position, batch_size: batch_size, precedence: precedence, session: session
          Telemetry::Logger.configure instance
        end
      end

      def self.call(stream_name: nil, category: nil, stream_position: nil, batch_size: nil, precedence: nil, session: nil, &action)
        instance = build(stream_name: stream_name, category: category, stream_position: stream_position, batch_size: batch_size, precedence: precedence, session: session)
        instance.(&action)
      end

      def self.configure(receiver, attr_name: nil, stream_name: nil, category: nil, stream_position: nil, batch_size: nil, precedence: nil, session: nil)
        attr_name ||= :reader
        instance = build(stream_name: stream_name, category: category, stream_position: stream_position, batch_size: batch_size, precedence: precedence, session: session)
        receiver.public_send "#{attr_name}=", instance
      end

      def call(&action)
        if action.nil?
          error_message = "Reader must be actuated with a block"
          logger.error error_message
          raise Error, error_message
        end

        enumerate_event_data(&action)

        return AsyncInvocation::Incorrect
      end

      def enumerate_event_data(&action)
        logger.opt_trace "Reading event data (Stream Name: #{stream_name.inspect}, Category: #{category.inspect}, Stream Position: #{stream_position.inspect}, Batch Size: #{batch_size.inspect}, Precedence: #{precedence.inspect})"

        event_data = nil
        next_stream_position = self.stream_position

        loop do
          event_data, next_stream_position = get_batch(next_stream_position)
          break if event_data.nil?

          self.class.enumerate_event_data(event_data, &action)
        end

        logger.opt_debug "Finished reading event data (Stream Name: #{stream_name.inspect}, Category: #{category.inspect}, Stream Position: #{stream_position.inspect}, Batch Size: #{batch_size.inspect}, Precedence: #{precedence.inspect})"
      end

      def get_batch(stream_position)
        logger.opt_trace "Getting batch (Stream Position: #{stream_position.inspect})"

        event_data = Get.(stream_name: stream_name, category: category, stream_position: stream_position, batch_size: batch_size, precedence: precedence, session: session)

        unless event_data.nil?
          next_stream_position = event_data.last.stream_position + 1
        end

        logger.opt_debug "Finished getting batch (Stream Position: #{stream_position.inspect}, Last Stream Position: #{next_stream_position.inspect})"

        return event_data, next_stream_position
      end

      def self.enumerate_event_data(event_data, &action)
        return if action.nil?

        event_data.each do |datum|
          action.(datum)
        end
      end
    end
  end
end
