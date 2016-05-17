module EventStream
  module Postgres
    module Controls
      module EventData
        def self.type
          'SomeType'
        end

        def self.data
          { :some_attribute => 'some value' }
        end
      end
    end
  end
end
