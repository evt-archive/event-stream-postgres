require_relative '../bench_init'

controls = EventStream::Postgres::Controls

context "Select Statement" do
  context "Category Query" do
    stream = controls::Stream::Category.example

    select_statement = Get::SelectStatement.build stream

    sql = select_statement.sql
    sql.gsub!(/\s+/, ' ')

    __logger.focus sql

    context "Where Clause" do
      test "Filters on stream name" do
        assert(sql.include? 'WHERE category(stream_name) =')
      end
    end
  end
end
