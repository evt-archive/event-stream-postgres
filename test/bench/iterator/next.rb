require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Iterator" do
  context "Next" do
    stream_name = controls::Put.(instances: 2)

    iterator = Iterator.build(stream_name: stream_name, batch_size: 1)

    batch = []

    2.times do
      event_data = iterator.next
      batch << event_data unless event_data.nil?
    end

    test "Gets each event" do
      assert(batch.length == 2)
    end
  end
end
