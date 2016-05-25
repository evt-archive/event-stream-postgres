module EventStream
  module Postgres
    class SelectStatement
      initializer :stream, w(:stream_position), w(:batch_size), w(:precedence)

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

      def self.build(stream, stream_position: nil, batch_size: nil, precedence: nil)
        new(stream, stream_position, batch_size, precedence).tap do |instance|
          instance.configure
        end
      end

      def self.call(stream, stream_position: nil, batch_size: nil, precedence: nil)
        instance = build(stream, category: category, stream_position: stream_position, batch_size: batch_size, precedence: precedence)
        instance.()
      end

      def configure
        Telemetry::Logger.configure self
      end

      def call
        get
      end

      def get
        logger.opt_trace "Composing select statement (Stream Name: #{stream_name}, Stream Position: #{stream_position}, Batch Size: #{batch_size}, Precedence: #{precedence})"

        statement = <<-SQL
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
            global_position $2
          OFFSET
            $3
          LIMIT
            $4
          ;
        SQL

        logger.opt_debug "Composed select statement (Stream Name: #{stream_name}, Stream Position: #{stream_position}, Batch Size: #{batch_size}, Precedence: #{precedence})"

        statement
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
