require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Insert Event Data" do
  stream_name = controls::StreamName.example

  type = controls::EventData.type
  data = controls::EventData.data
  metadata = controls::EventData::Metadata.data

  write = EventStream::Postgres::Write.new(stream_name, type, data, metadata)

  test do
    stream_version = write.insert
  end
end
