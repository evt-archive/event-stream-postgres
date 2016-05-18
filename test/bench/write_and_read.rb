require_relative 'bench_init'

controls = EventStream::Postgres::Controls

context "Write Event Data" do
  stream_name = controls::StreamName.example

  write_event = controls::EventData::Write.example
  written_stream_position = Write.(stream_name, write_event)

  read_event = Read.(stream_name, written_stream_position)

  context "Result is stream version" do
    test "Stream position" do
      __logger.focus write_event.inspect
      __logger.focus written_stream_position.inspect
      __logger.focus read_event.inspect

      assert(read_event.stream_position == written_stream_position)
    end
  end
end