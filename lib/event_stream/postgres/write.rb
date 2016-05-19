module EventStream
  module Postgres
    class Write
      class ExpectedVersionError < RuntimeError; end

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
        new(stream_name, write_event.type, write_event.data, write_event.metadata, expected_version: expected_version).tap do |instance|
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
        logger.opt_trace "Inserting event data (Stream Name: #{stream_name}, Type: #{type}, Expected Version: #{expected_version.inspect})"

        logger.opt_data "Data: #{data.inspect}"
        logger.opt_data "Metadata: #{metadata.inspect}"

        logger.opt_data "Serialized Metadata: #{serialized_metadata.inspect}"

        stream_position = insert_event

        logger.opt_debug "Inserted event data (Stream Name: #{stream_name}, Type: #{type}, Expected Version: #{expected_version.inspect})"

        stream_position
      end

      def insert_event
        records = execute_query
        stream_position(records)
      end

      def execute_query
        sql_args = [
          stream_name,
          type,
          serialized_data,
          serialized_metadata,
          expected_version
        ]

        begin
          records = session.connection.exec_params(statement, sql_args)
        rescue PG::RaiseException => e
          raise_error e
        end

        records
      end

      def statement
        "SELECT write_event($1::varchar, $2::varchar, $3::jsonb, $4::jsonb, $5::int);"
      end

      def serialized_data
        serializable_data = EventData::Hash[data]
        serialized_data = Serialize::Write.(serializable_data, :json)
        logger.opt_data "Serialized Data: #{serialized_data.inspect}"
        serialized_data
      end

      def serialized_metadata
        serializable_metadata = EventData::Hash[metadata]
        serialized_metadata = nil
        unless metadata.nil?
          serialized_metadata = Serialize::Write.(serializable_metadata, :json)
        end
        logger.opt_data "Serialized Metadata: #{serialized_metadata.inspect}"
        serialized_metadata
      end

      def stream_position(records)
        stream_position = nil
        unless records[0].nil?
          stream_position = records[0].values[0]
        end
        stream_position
      end

      def raise_error(pg_error)
        error_message = pg_error.message
        if error_message.include? 'Wrong expected version'
          error_message.gsub!('ERROR:', '').strip!
          raise ExpectedVersionError, error_message
        end
        raise pg_error
      end
    end
  end
end
