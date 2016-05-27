module EventStream
  module Postgres
    module Controls
      module StreamName
        def self.example(category: nil, id: nil, random: nil)
          category ||= 'Test'
          id ||= Identifier::UUID.random
          random = true if random.nil?

          if random
            category = "#{category}#{Identifier::UUID.random.gsub('-', '')}"
          end

          "#{category}-#{id}"
        end
      end
    end
  end
end
