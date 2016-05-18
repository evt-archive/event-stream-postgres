module EventStream
  module Postgres
    class Read
      attr_reader :stream_name
      attr_reader :stream_position

      def batch_size
        @batch_size ||= 1
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

      def call
        select
      end

      def configure(session: nil)
        Session.configure(self, session: session)
        Telemetry::Logger.configure(self)
      end

      def select
        logger.opt_trace "Selecting event data (Stream Name: #{stream_name}, Stream Position: #{stream_position.inspect})"

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
          OFFSET
            $2
          LIMIT
            $3
          ;
        SQL

        records = session.connection.exec_params(sql, sql_args)

        record = records[0].dup

        serialized_data = record['data']
        data = Serialize::Read.(serialized_data, EventData::Hash, :json)
        record['data'] = data

        serialized_metadata = record['metadata']
        metadata = nil
        unless serialized_metadata.nil?
          metadata = Serialize::Read.(serialized_metadata, EventData::Hash, :json)
        end
        record['metadata'] = metadata

        localized_created_time = record['created_time']
        utc_coerced_time = Clock::UTC.coerce(localized_created_time)
        record['created_time'] = utc_coerced_time

        read_event = EventData::Read.build record

        logger.opt_debug "Selecting event data (Stream Name: #{stream_name}, Stream Position: #{stream_position.inspect})"

        read_event
      end
    end
  end
end
