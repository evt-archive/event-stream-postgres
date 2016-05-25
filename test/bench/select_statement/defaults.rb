require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Select Statement" do
  context "Defaults" do
    # TODO Need contrl
    stream_name = controls::StreamName.example
    stream = Stream.build stream_name: stream_name

    get = Get::SelectStatement.build stream

    context "Stream position" do
      default_stream_position = Get::SelectStatement::Defaults.stream_position
      test "#{default_stream_position}" do
        assert(get.stream_position == default_stream_position)
      end
    end
  end
end
