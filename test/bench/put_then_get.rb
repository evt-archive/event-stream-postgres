require_relative 'bench_init'

controls = EventStream::Postgres::Controls

context "Put Then Get" do
  stream_name = controls::StreamName.example
  write_event = controls::EventData::Write.example

  written_stream_position = Put.(stream_name, write_event)

  read_event = Get.(stream_name: stream_name, stream_position: written_stream_position)[0]

  context "Get" do
    test "Result is stream version" do
      assert(read_event.stream_position == written_stream_position)
    end
  end
end
