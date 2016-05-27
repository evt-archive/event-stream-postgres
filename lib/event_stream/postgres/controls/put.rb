module EventStream
  module Postgres
    module Controls
      module Put
        def self.call(stream_name: nil, event: nil)
          stream_name ||= controls::StreamName.example
          event ||= controls::EventData::Write.example

          written_stream_position = Put.(stream_name, event)

          written_stream_position
        end
      end
    end
  end
end
