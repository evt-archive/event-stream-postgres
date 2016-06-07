require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Iterator" do
  context "Next" do
    stream_name = controls::Put.(instances: 2)

    iterator = Iterator.build(stream_name: stream_name, batch_size: 1)

    event_data_1 = iterator.next
    event_data_2 = iterator.next

    test "Gets individual events in order" do
      assert(event_data_2.stream_position == event_data_1.stream_position + 1)
    end
  end

  context "No more" do
    stream_name = controls::Put.(instances: 2)

    iterator = Iterator.build(stream_name: stream_name)

    2.times { iterator.next }

    last = iterator.next

    test "Results in nil" do
      assert(last.nil?)
    end
  end
end
