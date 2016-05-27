require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Select Statement" do
  context "Category Query" do
    category = 'some_category'
    stream = controls::Stream::Category.example category: category

    select_statement = Get::SelectStatement.build stream

    context "Where Clause" do
      test "Filters on category"
    end
  end
end
