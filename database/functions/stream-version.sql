CREATE OR REPLACE FUNCTION stream_version(
  stream_name varchar
)
RETURNS int
AS $$
DECLARE
  stream_version int;
BEGIN
  select max(stream_position) into stream_version from events where stream = stream_name;
  if stream_version IS NULL then
    stream_version := -1;
  end if;

  return stream_version;
END;
$$ LANGUAGE plpgsql;
