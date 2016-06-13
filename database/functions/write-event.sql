CREATE OR REPLACE FUNCTION write_event(
  _stream_name varchar,
  _type varchar,
  _data jsonb,
  _metadata jsonb DEFAULT NULL,
  _expected_version int DEFAULT NULL
)
RETURNS int
AS $$
DECLARE
  stream_version int;
  next_version int;
  category varchar;
BEGIN
  stream_version := stream_version(_stream_name);

  if stream_version is null then
    stream_version := -1;
  end if;

  if _expected_version is not null then
    if _expected_version != stream_version then
      raise exception 'Wrong expected version: % (Stream: %, Stream Version: %)', _expected_version, _stream_name, stream_version;
    end if;
  end if;

  next_version := stream_version + 1;

  insert into "events"
    (
      "stream_name",
      "stream_position",
      "type",
      "data",
      "metadata"
    )
  values
    (
      _stream_name,
      next_version,
      _type,
      _data,
      _metadata
    )
  ;

  return next_version;
END;
$$ LANGUAGE plpgsql;
