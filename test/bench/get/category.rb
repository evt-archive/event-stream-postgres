# require_relative '../bench_init'

# controls = EventStream::Postgres::Controls

# context "Get" do
#   context "Category" do
#     category = 'some_category'
#     stream_name = controls::StreamName.example randomize_category: false,

#     write_event = controls::EventData::Write.example
#     Put.(stream_name, write_event)
#     Put.(stream_name, write_event)
#     Put.(stream_name, write_event)

#     events = Get.(category: category_name)

#     number_of_events = events.length

#     test "Number of events retrieved is the specified batch size" do
#       assert(number_of_events == 2)
#     end
#   end
# end
