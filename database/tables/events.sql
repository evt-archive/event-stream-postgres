CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

-- ----------------------------
--  Table structure for events
-- ----------------------------
DROP TABLE IF EXISTS "public"."events";
CREATE TABLE "public"."events" (
  "id" uuid DEFAULT gen_random_uuid() NOT NULL,
  "type" varchar NOT NULL COLLATE "default",
  "stream" varchar NOT NULL COLLATE "default",
  "stream_position" int4 NOT NULL,
  "category" varchar NOT NULL COLLATE "default",
  "global_position" bigserial NOT NULL ,
  "data" jsonb NOT NULL,
  "metadata" jsonb,
  "created_time" TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'utc') NOT NULL
)
WITH (OIDS=FALSE);

-- ----------------------------
--  Primary key structure for table events
-- ----------------------------
ALTER TABLE "public"."events" ADD PRIMARY KEY ("global_position") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Indexes structure for table events
-- ----------------------------
CREATE INDEX CONCURRENTLY  "events_category_global_position_idx" ON "public"."events" USING btree(category COLLATE "default" "pg_catalog"."text_ops" ASC NULLS LAST, "global_position" "pg_catalog"."int8_ops" ASC NULLS LAST);
CREATE INDEX CONCURRENTLY "events_category_idx" ON "public"."events" USING btree(category COLLATE "default" "pg_catalog"."text_ops" ASC NULLS LAST);
CREATE UNIQUE INDEX CONCURRENTLY "events_event_id_uniq_idx" ON "public"."events" USING btree(id "pg_catalog"."uuid_ops" ASC NULLS LAST);
CREATE UNIQUE INDEX CONCURRENTLY "events_stream_stream_position_uniq_idx" ON "public"."events" USING btree(stream COLLATE "default" "pg_catalog"."text_ops" ASC NULLS LAST, "stream_position" "pg_catalog"."int4_ops" ASC NULLS LAST);
