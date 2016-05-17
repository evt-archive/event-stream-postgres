# module EventStream
#   module Postgres
#     module Controls
#       module EventData
#         module Write
#           def self.data(id=nil)
#             id ||= ::Controls::ID.get sample: false

#             {
#               :event_id => id,
#               :event_type => 'SomeType',
#               :data => { :some_attribute => 'some value' },
#               :metadata => EventData::Metadata.data
#             }
#           end

#           module JSON
#             def self.data(id=nil)
#               data = Write.data id

#               Casing::Camel.(data, symbol_to_string: true)
#             end

#             def self.text
#               data.to_json
#             end
#           end

#           def self.example(id=nil, i: nil, type: nil)
#             id ||= ::Controls::ID.get i, sample: false
#             type ||= 'SomeType'

#             event_data = EventStore::Client::HTTP::EventData::Write.build

#             event_data.id = id

#             event_data.type = type

#             event_data.data = {
#               :some_attribute => 'some value'
#             }

#             event_data.metadata = EventData::Metadata.data

#             event_data
#           end
#         end
#       end
#     end
#   end
# end
