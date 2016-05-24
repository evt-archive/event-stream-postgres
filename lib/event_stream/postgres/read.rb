module EventStream
  module Postgres
    class Read
      attr_reader :stream_name
      attr_reader :stream_position

      def batch_size
        @batch_size ||= Defaults.batch_size
      end

      dependency :session, Session
      dependency :logger, Telemetry::Logger

      def initialize(stream_name, stream_position, batch_size=nil)
        @stream_name = stream_name
        @stream_position = stream_position
        @batch_size = batch_size
      end

      def self.build(stream_name, stream_position, batch_size=nil, session: nil)
        new(stream_name, stream_position, batch_size).tap do |instance|
          instance.configure(session: session)
        end
      end

      def self.call(stream_name, stream_position, batch_size=nil, session: nil)
        instance = build(stream_name, stream_position, batch_size, session: session)
        instance.()
      end

      def configure(session: nil)
        Session.configure(self, session: session)
        Telemetry::Logger.configure(self)
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

        sql = <<-SQL
          SELECT
            stream_name::varchar,
            stream_position::int,
            type::varchar,
            category::varchar,
            global_position::bigint,
            data::varchar,
            metadata::varchar,
            created_time::timestamp
          FROM
            events
          WHERE
            stream_name = $1
          ORDER BY
            global_position
          OFFSET
            $2
          LIMIT
            $3
          ;
        SQL

        session.connection.exec_params(sql, sql_args)
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
        def self.batch_size
          100
        end
      end
    end
  end
end
