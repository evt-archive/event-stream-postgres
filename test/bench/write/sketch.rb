require_relative '../../test_init'

conn = PG::Connection.open(:dbname => 'eventstream')
conn.type_map_for_results = PG::BasicTypeMapForResults.new(conn)

args = [
  'SomeStream-123',
  'SomeType',
  '{"someField":"some value"}',
  '{"someMetadataField":"some metadata value"}',
  nil
]

sql = <<-SQL
  SELECT write_event($1::varchar, $2::varchar, $3::jsonb, $4::jsonb, $5::int);
SQL

res = conn.exec_params(sql, args)

p res

p res[0]
p res[0].values[0]

