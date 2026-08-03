-- 验证2.0.1修复结果
USE `inst_cyana`;

SELECT COUNT(*) AS business_table_count
FROM information_schema.tables
WHERE table_schema = 'inst_cyana'
  AND table_type = 'BASE TABLE'
  AND table_name <> 'schema_version';

SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'inst_cyana'
  AND table_name IN ('answer', 'v_submission_score_check')
ORDER BY table_name;

SELECT version_no, description, applied_at
FROM schema_version
WHERE version_no = '2.0.1';

SELECT grantee, table_name, privilege_type
FROM information_schema.table_privileges
WHERE table_schema = 'inst_cyana'
  AND table_name = 'answer'
  AND grantee = "'cyana_writer'@'localhost'"
ORDER BY privilege_type;
