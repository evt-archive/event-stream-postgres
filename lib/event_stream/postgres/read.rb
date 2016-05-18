module EventStream
  module Postgres
    class Read
      dependency :session, Session
      dependency :logger, Telemetry::Logger

      initializer(:stream_name, :stream_position)

      def self.build(stream_name, stream_position, session: nil)
        new(stream_name, stream_position).tap do |instance|
          instance.configure(session: session)
        end
      end

      def configure(session: nil)
        Session.configure(self, session: session)
        Telemetry::Logger.configure(self)
      end

      def self.call(stream_name, stream_position, session: nil)
        instance = build(stream_name, stream_position, session: session)
        instance.()
      end

      def call
        select
      end

      def select
      end

      def insert
        logger.opt_trace "Inserting event data (Stream Name: #{stream_name}, Type: #{type}, Expected Version: #{expected_version.inspect})"

        logger.opt_data "Data: #{data.inspect}"
        logger.opt_data "Metadata: #{metadata.inspect}"

        serializable_data = EventData::Hash[data]
        serialized_data = Serialize::Write.(serializable_data, :json)

        serializable_metadata = EventData::Hash[metadata]
        serialized_metadata = nil
        unless metadata.nil?
          serialized_metadata = Serialize::Write.(serializable_metadata, :json)
        end

        logger.opt_data "Serialized Data: #{serialized_data.inspect}"
        logger.opt_data "Serialized Metadata: #{serialized_metadata.inspect}"

        args = [
          stream_name,
          type,
          serialized_data,
          serialized_metadata,
          expected_version
        ]

        sql = <<-SQL
          SELECT write_event($1::varchar, $2::varchar, $3::jsonb, $4::jsonb, $5::int);
        SQL

        res = session.connection.exec_params(sql, args)

        stream_position = nil
        unless res[0].nil?
          stream_position = res[0].values[0]
        end

        logger.opt_debug "Inserted event data (Stream Name: #{stream_name}, Type: #{type}, Expected Version: #{expected_version.inspect})"

        stream_position
      end
    end
  end
end
