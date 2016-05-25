module EventStream
  module Postgres
    class Get
      initializer :stream, w(:stream_position), w(:batch_size), w(:precedence)

      dependency :session, Session
      dependency :logger, Telemetry::Logger

      def stream_position
        @stream_position ||= Defaults.stream_position
      end

      def batch_size
        @batch_size ||= Defaults.batch_size
      end

      def precedence
        @precedence ||= 'ASC'
      end

      def stream_name
        stream.name
      end

      def self.build(stream_name: nil, category: nil, stream_position: nil, batch_size: nil, precedence: nil, session: nil)
        stream = Stream.build stream_name: stream_name, category: category

        new(stream, stream_position, batch_size, precedence).tap do |instance|
          instance.configure(session: session)
        end
      end

      def self.call(stream_name: nil, category: nil, stream_position: nil, batch_size: nil, precedence: nil, session: nil)
        instance = build(stream_name: stream_name, category: category, stream_position: stream_position, batch_size: batch_size, session: session)
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
        logger.opt_trace "Getting event data (Stream Name: #{stream_name}, Stream Position: #{stream_position.inspect})"

        records = get_records
        events = convert(records)

        logger.opt_debug "Got event data (Stream Name: #{stream_name}, Stream Position: #{stream_position.inspect}, Count: #{events.length})"

        events
      end

      def get_records
        sql_args = [
          stream_name,
          stream_position,
          batch_size
        ]

        statement = SelectStatement.(stream, stream_position: stream_position, batch_size: batch_size, precedence: precedence)

        session.connection.exec_params(statement, sql_args)
      end

      def convert(records)
        records.map do |record|
          record['data'] = Deserialize.data(record['data'])
          record['metadata'] = Deserialize.metadata(record['metadata'])
          record['created_time'] = Time.utc_coerced(record['created_time'])

          EventData::Read.build record
        end
      end

      module Deserialize
        def self.data(serialized_data)
          Serialize::Read.(serialized_data, EventData::Hash, :json)
        end

        def self.metadata(serialized_metadata)
          if serialized_metadata.nil?
            nil
          else
            Serialize::Read.(serialized_metadata, EventData::Hash, :json)
          end
        end
      end

      module Time
        def self.utc_coerced(local_time)
          Clock::UTC.coerce(local_time)
        end
      end

      module Defaults
        def self.stream_position
          0
        end

        def self.batch_size
          100
        end
      end
    end
  end
end
