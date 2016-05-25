module EventStream
  module Postgres
    class Get
      initializer :select_statement

      dependency :session, Session
      dependency :logger, Telemetry::Logger

      def self.build(stream_name: nil, category: nil, stream_position: nil, batch_size: nil, precedence: nil, session: nil)
        stream = Stream.build stream_name: stream_name, category: category
        select_statement = SelectStatement.build(stream, stream_position: stream_position, batch_size: batch_size, precedence: precedence)

        new(select_statement).tap do |instance|
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
        logger.opt_trace "Getting event data"

        records = get_records
        events = convert(records)

        logger.opt_debug "Got event data (Count: #{events.length})"

        events
      end

      def get_records
        logger.opt_trace "Getting records"

        records = session.connection.exec_params(select_statement.sql, select_statement.args)

        logger.opt_debug "Got records (Count: #{records.ntuples})"

        records
      end

      def convert(records)
        logger.opt_trace "Converting records to events (Records Count: #{records.ntuples})"

        events = records.map do |record|
          record['data'] = Deserialize.data(record['data'])
          record['metadata'] = Deserialize.metadata(record['metadata'])
          record['created_time'] = Time.utc_coerced(record['created_time'])

          EventData::Read.build record
        end

        logger.opt_debug "Converting records to events (Events Count: #{events.length})"

        events
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
    end
  end
end
