-- ----------------------------
--  Table structure for events
-- ----------------------------
DROP TABLE IF EXISTS "public"."events";
CREATE TABLE "public"."events" (
  "stream_name" varchar(255) NOT NULL COLLATE "default",
  "stream_position" int4 NOT NULL,
  "type" varchar(255) NOT NULL COLLATE "default",
  "category" varchar(255) NOT NULL COLLATE "default",
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
CREATE INDEX CONCURRENTLY "events_category_idx" ON "public"."events" USING btree(category(stream_name) COLLATE "default" "pg_catalog"."text_ops" ASC NULLS LAST);
CREATE INDEX CONCURRENTLY "events_stream_name_idx" ON "public"."events" USING btree(stream_name COLLATE "default" "pg_catalog"."text_ops" ASC NULLS LAST);
CREATE UNIQUE INDEX CONCURRENTLY "events_stream_name_stream_position_uniq_idx" ON "public"."events" USING btree(stream_name COLLATE "default" "pg_catalog"."text_ops" ASC NULLS LAST, "stream_position" "pg_catalog"."int4_ops" ASC NULLS LAST);
