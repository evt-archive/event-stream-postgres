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

      # can use configure macro here
      def self.call(stream_name: nil, category: nil, stream_position: nil, batch_size: nil, precedence: nil, session: nil)
        instance = build(stream_name: stream_name, category: category, stream_position: stream_position, batch_size: batch_size, precedence: precedence, session: session)
        instance.()
      end

      def configure(session: nil)
        Session.configure self, session: session
        Telemetry::Logger.configure self
      end

      def call
        get_event_data
      end

      # enumerate block - don't accumulate events
      def get_event_data
        logger.opt_trace "Reading event data"

        event_data = nil
        next_stream_position = self.stream_position

        loop do
          event_data, next_stream_position = get_batch(next_stream_position)
          break if event_data.nil?
        end

        logger.opt_trace "Finished reading event data"

        event_data
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
