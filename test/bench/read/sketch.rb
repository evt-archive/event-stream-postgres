require_relative '../../test_init'

conn = PG::Connection.open(:dbname => 'eventstream')
conn.type_map_for_results = PG::BasicTypeMapForResults.new(conn)

sql = <<-SQL
  SELECT
    stream_name::varchar,
    stream_position::int,
    type::varchar,
    category::varchar,
    global_position::bigint,
    data::varchar,
    metadata::varchar,
    created_time::timestamp
  FROM
    events
  WHERE
    stream_name = $1;
SQL

args = [
  'SomeStream-123'
]

res = conn.exec_params(sql, args)

res = res[0]

# t = res['created_time']
# u = Clock::UTC.coerce t
# puts "run through clock utc: #{u}"

p res
