require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Insert Event Data" do
  stream_name = controls::StreamName.example

  type = controls::EventData.type
  data = controls::EventData::JSON.text
  metadata = controls::EventData::Metadata::JSON.text

  write = EventStream::Postgres::Write.new(stream_name, type, data, metadata, expected_version: nil)
  write.configure

  stream_version = write.()

  __logger.focus stream_version

  test "Result is stream version" do
    refute(stream_version.nil?)
  end
end
