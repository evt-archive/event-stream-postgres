# one get per batch
# (it's a new object, so no dependency)

# after each batch, set stream position to last
# event's steam position

# enumerate batches

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

      def get_event_data
        Get.(stream_name: stream_name, category: category, stream_position: stream_position, batch_size: batch_size, precedence: precedence, session: session)

      end
    end
  end
end
