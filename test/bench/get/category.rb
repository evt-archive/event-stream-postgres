require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Get" do
  context "Category" do
    category = 'some_category'

    stream_name_1 = controls::StreamName.example randomize_category: false, category: category
    controls::Put.(stream_name: stream_name_1)

    stream_name_2 = controls::StreamName.example randomize_category: false, category: category
    controls::Put.(stream_name: stream_name_2)

    events = Get.(category: category)

    # test "Number of events retrieved is the number written to the category" do
    #   number_of_events = events.length
    #   assert(number_of_events == 2)
    # end

    test "Number of events retrieved is the number written to the category"
  end
end
