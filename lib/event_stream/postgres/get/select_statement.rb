module EventStream
  module Postgres
    class Get
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
          @precedence ||= Defaults.precedence
        end

        def stream_name
          stream.name
        end

        def stream_type
          stream.type
        end

        def self.build(stream, stream_position: nil, batch_size: nil, precedence: nil)
          new(stream, stream_position, batch_size, precedence).tap do |instance|
            instance.configure
          end
        end

        def configure
          Telemetry::Logger.configure self
        end

        def sql
          logger.opt_trace "Composing select statement (Stream: #{stream_name}, Type: #{stream_type}, Stream Position: #{stream_position}, Batch Size: #{batch_size}, Precedence: #{precedence})"

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
              #{where_clause_field} = $1
            ORDER BY
              global_position #{precedence.to_s.upcase}
            OFFSET
              $2
            LIMIT
              $3
            ;
          SQL

          logger.opt_debug "Composed select statement (Stream: #{stream_name}, Type: #{stream_type}, Stream Position: #{stream_position}, Batch Size: #{batch_size}, Precedence: #{precedence})"
          logger.opt_data "Statement: #{statement}"

          statement
        end

        def args
          [
            stream_name,
            stream_position,
            batch_size
          ]
        end

        def where_clause_field
          if stream.type == :stream
            'stream_name'
          else
            'category'
          end
        end

        module Defaults
          def self.stream_position
            0
          end

          def self.batch_size
            1000
          end

          def self.precedence
            :asc
          end
        end
      end
    end
  end
end
