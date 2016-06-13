require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Put" do
  context "No Stream" do
    context "For a stream that already exists" do
      stream_name = controls::StreamName.example
      write_event = controls::EventData::Write.example

      Put.(stream_name, write_event)

      erroneous = proc { Put.(stream_name, write_event, expected_version: NoStream.name ) }

      test "Is an error" do
        assert erroneous do
          raises_error? Write::ExpectedVersionError
        end
      end
    end
  end
end
