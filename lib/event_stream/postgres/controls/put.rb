module EventStream
  module Postgres
    module Controls
      module Put
        def self.call(instances: nil, stream_name: nil, event: nil)
          instances ||= 1
          stream_name ||= StreamName.example
          event ||= EventData::Write.example

          EventStream::Postgres::Put.(stream_name, event)

          stream_name
        end
      end
    end
  end
end
