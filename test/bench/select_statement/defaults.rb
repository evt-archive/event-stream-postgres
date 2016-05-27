require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Select Statement" do
  context "Defaults" do
    stream = controls::Stream.example

    get = Get::SelectStatement.build stream

    context "Stream Position" do
      default_stream_position = Get::SelectStatement::Defaults.stream_position
      test "#{default_stream_position}" do
        assert(get.stream_position == default_stream_position)
      end
    end

    context "Batch Size" do
      default_batch_size = Get::SelectStatement::Defaults.batch_size
      test "#{default_batch_size}" do
        assert(get.batch_size == default_batch_size)
      end
    end

    context "Precedence" do
      default_precedence = Get::SelectStatement::Defaults.precedence
      test "#{default_precedence}" do
        assert(get.precedence == default_precedence)
      end
    end
  end
end
