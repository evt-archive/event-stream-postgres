module EventStream
  module Postgres
    module Controls
      module Stream
        def self.example(category: nil, id: nil, randomize_category: nil, stream_name: nil, category_name: nil)
          stream_name ||= StreamName.example category: category, id: id, randomize_category: randomize_category
          ::Stream.build stream_name: stream_name, category: category_name
        end
      end
    end
  end
end
