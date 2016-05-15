require_relative '../bench_init'

context "Category Stream Name" do
  test "Is the category name" do
    category_stream_name = EventStream::Postgres::StreamName.category_stream_name 'SomeCategory'
    __logger.focus category_stream_name
    assert(category_stream_name == 'SomeCategory')
  end
end
