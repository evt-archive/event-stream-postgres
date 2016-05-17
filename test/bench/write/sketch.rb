require_relative '../../test_init'

conn = PG::Connection.open(:dbname => 'eventide')
conn.type_map_for_results = PG::BasicTypeMapForResults.new(conn)

id = Identifier::UUID.random

args = [
  id,
  'SomeType',
  'SomeStream-123',
  '{"someField":"some value"}',
  '{"someMetadataField":"some metadata value"}',
  nil
]

sql = <<-SQL
  SELECT write_event($1::uuid, $2::varchar, $3::varchar, $4::jsonb, $5::jsonb, $6::int);
SQL

res = conn.exec_params(sql, args)

p res[0]
p res[0].values[0]

