require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Batch Size" do
  stream_name = controls::StreamName.example

  write_event = controls::EventData::Write.example
  Put.(stream_name, write_event)
  Put.(stream_name, write_event)
  Put.(stream_name, write_event)

  events = Get.(stream_name, 0, 2)

  number_of_events = events.length

  context "Get" do
    test "Number of events retrieved is the specified batch size" do
      assert(number_of_events == 2)
    end
  end
end
