require_relative 'bench_init'

controls = EventStream::Postgres::Controls

context "Write Event Data" do
  stream_name = controls::StreamName.example

  write_event = controls::EventData::Write.example
  written_stream_position = Write.(stream_name, write_event)

  read_event = Get.(stream_name, written_stream_position)[0]

  context "Result is stream version" do
    test "Stream position" do
      assert(read_event.stream_position == written_stream_position)
    end
  end
end
