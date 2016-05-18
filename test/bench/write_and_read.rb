require_relative 'bench_init'

controls = EventStream::Postgres::Controls

context "Write Event Data" do
  stream_name = controls::StreamName.example

  write_event = controls::EventData::Write.example
  Write.(stream_name, write_event)

  # read_event =


  test "Result is stream version" do
    # refute(stream_version.nil?)
  end
end
