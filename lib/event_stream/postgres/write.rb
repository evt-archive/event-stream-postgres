module EventStream
  module Postgres
    class Write
      attr_reader :stream_name
      attr_reader :type
      attr_reader :data
      attr_reader :metadata

      def initialize(stream_name, type, data, metadata=nil)
        @stream_name = stream_name
        @type = type
        @data = data
        @metadata = metadata
      end

      def insert
        conn = PG::Connection.open(:dbname => 'eventstream')
        conn.type_map_for_results = PG::BasicTypeMapForResults.new(conn)

        args = [
          'SomeStream-123',
          'SomeType',
          '{"someField":"some value"}',
          '{"someMetadataField":"some metadata value"}',
          nil
        ]

        sql = <<-SQL
          SELECT write_event($1::varchar, $2::varchar, $3::jsonb, $4::jsonb, $5::int);
        SQL

        res = conn.exec_params(sql, args)

        stream_version = nil
        unless res[0].nil?
          stream_version = res[0].values[0]
        end

        stream_version
      end
    end
  end
end
