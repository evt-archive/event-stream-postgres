module EventStream
  module Postgres
    class Write
      initializer :stream_name, :type, :data, r(:metadata, nil)

      def insert
      end
    end
  end
end
