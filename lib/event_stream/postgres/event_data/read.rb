module EventStream
  module Postgres
    class EventData
      class Read < EventData
        include Schema::DataStructure

        attribute :stream_name
        attribute :stream_position
        attribute :category
        attribute :global_position
        attribute :created_time
      end
    end
  end
end
