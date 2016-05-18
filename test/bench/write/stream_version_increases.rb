require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Stream Version Increases with Subsequent Writes" do
  stream_name = controls::StreamName.example
  write_event = controls::EventData::Write.example

  stream_version_1 = EventStream::Postgres::Write.(stream_name, write_event)
  stream_version_2 = EventStream::Postgres::Write.(stream_name, write_event)

  test "First version is one less than the second version" do
    assert(stream_version_1 + 1 == stream_version_2)
  end
end
