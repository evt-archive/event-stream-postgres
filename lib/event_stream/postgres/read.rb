module EventStream
  module Postgres
    class Read
      initializer :stream_name, :category, :stream_position, :batch_size, :precedence, :session

      dependency :session, Session
      dependency :logger, Telemetry::Logger

      def self.build(stream_name: nil, category: nil, stream_position: nil, batch_size: nil, precedence: nil, session: nil)
        new(stream_name, category, stream_position, batch_size, precedence, session).tap do |instance|
          instance.configure(session: session)
        end
      end

      def self.call(stream_name: nil, category: nil, stream_position: nil, batch_size: nil, precedence: nil, session: nil, &action)
        instance = build(stream_name: stream_name, category: category, stream_position: stream_position, batch_size: batch_size, precedence: precedence, session: session)
        instance.(&action)
      end

      def configure(session: nil)
        Session.configure self, session: session
        Telemetry::Logger.configure self
      end

      def call(&action)
        get_event_data(&action)

        return AsyncInvocation::Incorrect
      end

      def get_event_data(&action)
        logger.opt_trace "Reading event data"

        event_data = nil
        next_stream_position = self.stream_position

        loop do
          event_data, next_stream_position = get_batch(next_stream_position)
          break if event_data.nil?

          self.class.enumerate_event_data(event_data, &action)
        end

        logger.opt_trace "Finished reading event data"
      end

      def self.enumerate_event_data(event_data, &action)
        return if action.nil?

        event_data.each do |datum|
          action.(datum)
        end
      end

      def get_batch(stream_position)
        logger.opt_trace "Getting batch (Stream Position: #{stream_position})"

        event_data = Get.(stream_name: stream_name, category: category, stream_position: stream_position, batch_size: batch_size, precedence: precedence, session: session)

        unless event_data.nil?
          next_stream_position = event_data.last.stream_position + 1
        end

        logger.opt_debug "Finished getting batch (Stream Position: #{stream_position}, Last Stream Position: #{next_stream_position})"

        return event_data, next_stream_position
      end
    end
  end
end
