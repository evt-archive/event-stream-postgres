require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Put" do
  context "No Stream" do
    stream_name = controls::StreamName.example
    event = controls::EventData::Write.example

    put = Put.build(stream_name, event, expected_version: NoStream.name)

    test "Sets the expected version to -1" do
      assert(put.expected_version == NoStream.version)
    end
  end
end
