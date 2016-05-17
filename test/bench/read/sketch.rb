require_relative '../../test_init'

conn = PG::Connection.open(:dbname => 'eventide')
conn.type_map_for_results = PG::BasicTypeMapForResults.new(conn)

sql = <<-SQL
  SELECT
    id::varchar,
    type::varchar,
    stream::varchar,
    stream_position::int,
    category::varchar,
    global_position::bigint,
    data::varchar,
    metadata::varchar,
    created_time::timestamp
  FROM
    events
  WHERE
    stream = $1;
SQL

args = [
  'SomeStream-123'
]

res = conn.exec_params(sql, args)

res = res[0]

t = res['created_time']

puts "raw from db: #{t}"
# puts "utc: #{t.utc?}"

# offset = t.gmt_offset
# puts "offset seconds: #{offset}"

# u = t.getutc
# puts "t.getutc: #{u}"

# u = u + offset
# puts "offset negated: #{u}"

# puts "run through clock utc: #{u}"

u = Clock::UTC.coerce t
puts "run through clock utc: #{u}"
