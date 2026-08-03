-- 验证 Cyana 本机读写账号
-- 请使用root账号执行。

SELECT '1. account_exists' AS verification_item;
SELECT user, host, account_locked
FROM mysql.user
WHERE user IN ('cyana_reader', 'cyana_writer')
  AND host = 'localhost'
ORDER BY user;

SELECT '2. database_privileges' AS verification_item;
SELECT grantee, privilege_type, is_grantable
FROM information_schema.schema_privileges
WHERE table_schema = 'inst_cyana'
  AND grantee IN (
    "'cyana_reader'@'localhost'",
    "'cyana_writer'@'localhost'"
  )
ORDER BY grantee, privilege_type;

SELECT '3. writer_table_privileges' AS verification_item;
SELECT grantee, table_name, privilege_type
FROM information_schema.table_privileges
WHERE table_schema = 'inst_cyana'
  AND grantee = "'cyana_writer'@'localhost'"
ORDER BY table_name, privilege_type;

SELECT '4. grants' AS verification_item;
SHOW GRANTS FOR 'cyana_reader'@'localhost';
SHOW GRANTS FOR 'cyana_writer'@'localhost';
