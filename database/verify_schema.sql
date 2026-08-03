SELECT VERSION() AS mysql_version;
SELECT DATABASE() AS institution_database;

SELECT COUNT(*) AS base_table_count
FROM information_schema.tables
WHERE table_schema = DATABASE()
  AND table_type = 'BASE TABLE';

SELECT COUNT(*) AS business_table_count
FROM information_schema.tables
WHERE table_schema = DATABASE()
  AND table_type = 'BASE TABLE'
  AND table_name <> 'schema_version';

SELECT COUNT(*) AS view_count
FROM information_schema.views
WHERE table_schema = DATABASE();

SELECT COUNT(*) AS foreign_key_count
FROM information_schema.referential_constraints
WHERE constraint_schema = DATABASE();

SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = DATABASE()
ORDER BY table_type, table_name;

SELECT * FROM schema_version ORDER BY applied_at;
