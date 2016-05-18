require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Write Event Data" do
  stream_name = controls::StreamName.example

  write_event = controls::EventData::Write.example
  __logger.focus write_event.inspect


  stream_version = EventStream::Postgres::Write.(stream_name, write_event)

  __logger.focus stream_version

  test "Result is stream version" do
    refute(stream_version.nil?)
  end
end
