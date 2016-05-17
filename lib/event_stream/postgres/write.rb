module EventStream
  module Postgres
    class Write
      attr_reader :stream_name
      attr_reader :type
      attr_reader :data
      attr_reader :metadata
      attr_reader :expected_version

      dependency :session, Session
      dependency :logger, Telemetry::Logger

      def initialize(stream_name, type, data, metadata=nil, expected_version: nil)
        @stream_name = stream_name
        @type = type
        @data = data
        @metadata = metadata
        @expected_version = expected_version
      end

      def self.build(stream_name, write_event, expected_version: nil, session: nil)
        new.tap(stream_name, write_event.type, write_event.data, write_event.metadata, expected_version) do |instance|
          instance.configure(session: session)
        end
      end

      def configure(session: nil)
        Session.configure(self, session: session)
        Telemetry::Logger.configure(self)
      end

      def self.call(stream_name, write_event, expected_version: nil, session: nil)
        instance = build(stream_name, write_event, expected_version: expected_version, session: session)
        instance.()
      end

      def call
        insert
      end

      def insert
        logger.opt_trace "Inserting event data (Stream Name: #{stream_name}, Type: #{type}, Expected Version: #{expected_version.inspect})"
        logger.opt_data "Data: #{data.inspect}"
        logger.opt_data "Metadata: #{metadata.inspect}"

        conn = session.connection

        args = [
          stream_name,
          type,
          data,
          metadata,
          expected_version
        ]

        sql = <<-SQL
          SELECT write_event($1::varchar, $2::varchar, $3::jsonb, $4::jsonb, $5::int);
        SQL

        res = conn.exec_params(sql, args)

        stream_version = nil
        unless res[0].nil?
          stream_version = res[0].values[0]
        end

        logger.opt_debug "Inserted event data (Stream Name: #{stream_name}, Type: #{type}, Expected Version: #{expected_version.inspect})"

        stream_version
      end
    end
  end
end
