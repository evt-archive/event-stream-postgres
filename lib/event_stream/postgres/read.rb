# one get per batch
# (it's a new object, so no dependency)

# after each batch, set stream position to last
# event's steam position

# enumerate batches

module EventStream
  module Postgres
    class Read
      initializer :stream

      dependency :session, Session
      dependency :logger, Telemetry::Logger

      def self.build(stream_name: nil, category: nil, stream_position: nil, batch_size: nil, precedence: nil, session: nil)
        stream = Stream.build stream_name: stream_name, category: category

        new(stream).tap do |instance|
          instance.configure(session: session)
        end
      end

      def self.call(stream_name: nil, category: nil, stream_position: nil, batch_size: nil, precedence: nil, session: nil)
        instance = build(stream_name: stream_name, category: category, stream_position: stream_position, batch_size: batch_size, precedence:precedence, session: session)
        instance.()
      end

      def configure(session: nil)
        Session.configure self, session: session
        Telemetry::Logger.configure self
      end

      def call
        get_event_data
      end

      def get_event_data
        []
      end
    end
  end
end
