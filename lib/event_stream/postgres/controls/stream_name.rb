module EventStream
  module Postgres
    module Controls
      module StreamName
        def self.example(category: nil, id: nil, randomize_category: nil)
          category ||= 'Test'
          id ||= Identifier::UUID.random
          randomize_category = true if randomize_category.nil?

          if randomize_category
            category = "#{category}#{Identifier::UUID.random.gsub('-', '')}"
          end

          "#{category}-#{id}"
        end
      end
    end
  end
end
