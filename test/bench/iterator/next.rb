require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Iterator" do
  context "Next" do
    stream_name = controls::Put.(instances: 2)

    iterator = Iterator.build(stream_name: stream_name, batch_size: 1)

    # event_data_1 = iterator.next
    # event_data_2 = iterator.next

    batch = []

    2.times do
      event_data = iterator.next
      batch << event_data unless event_data.nil?
    end

    require 'pp'
    pp batch

    test "Gets each event" do
      assert(batch.length == 2)
    end
  end

  # context "No further event data" do
  #   stream_name = controls::Put.(instances: 2)

  #   iterator = Iterator.build(stream_name: stream_name)

  #   2.times { iterator.next }

  #   last = iterator.next

  #   test "Results in nil" do
  #     assert(last.nil?)
  #   end
  # end
end
