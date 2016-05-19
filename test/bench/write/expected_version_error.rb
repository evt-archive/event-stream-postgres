require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Expected Version" do
  context "Expected version does not match the stream version" do
    stream_name = controls::StreamName.example
    write_event = controls::EventData::Write.example

    stream_version = Write.(stream_name, write_event)

    incorrect_stream_version = stream_version + 1

    test "Is an error" do
      assert proc { Write.(stream_name, write_event, expected_version: incorrect_stream_version ) } do
        raises_error? Write::ExpectedVersionError
      end
    end
  end
end
