# MySQL最小数据基座

## 规划原则

- 一个机构一个数据库。
- 每个机构库执行同一份 `schema.sql`。
- 库内不保存 `institution_id`。
- 10张业务表加1张结构治理表。
- 核心关系、状态、时间、顺序和分值使用普通字段。
- 联系方式、选项、量规和低频属性使用JSON。
- 没有真实业务触发条件就不拆表。

## 表结构

业务表：

1. `person`
2. `person_relation`
3. `learning_group`
4. `group_member`
5. `content_item`
6. `activity`
7. `activity_item`
8. `submission`
9. `answer`
10. `feedback`

治理表：`schema_version`。

另外提供3个只读验证视图，不计入表数量。

## 本机手动建库

```bash
/usr/local/mysql/bin/mysql -u root -p
```

进入MySQL后执行：

```sql
CREATE DATABASE IF NOT EXISTS inst_cyana
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE inst_cyana;

SOURCE /Users/xingzhikabi/Documents/英语机构工作提效/database/schema.sql;
SOURCE /Users/xingzhikabi/Documents/英语机构工作提效/database/verify_schema.sql;
```

验证结果应为：11张基础表、10张业务表、3个视图、当前结构版本 `2.0.1`。

## Cyana数据库账号

为 `inst_cyana` 配置两个最小权限账号：

1. `cyana_reader`：仅允许查询表和视图。
2. `cyana_writer`：允许查询、新增、修改和删除业务数据，但不允许修改表结构或管理账号。

复制账号模板后，在副本中填写两个不同的强密码，再由root账号执行。不要在模板原文件或Git中保存真实密码。

```bash
cp database/create_cyana_accounts.sql.template /private/tmp/create_cyana_accounts.sql
/usr/local/mysql/bin/mysql -u root -p < /private/tmp/create_cyana_accounts.sql
```

模板文件：`database/create_cyana_accounts.sql.template`。

账号变更完成后，使用root账号执行验证文件：

```sql
SOURCE /Users/xingzhikabi/Documents/英语机构工作提效/database/verify_cyana_accounts.sql;
```

## 新增机构

当前首个机构暂定名称为 `cyana`，对应数据库为 `inst_cyana`。

后续新增机构时，使用新的机构数据库名称，再执行相同的 `schema.sql`。数据库名建议使用：

```text
inst_<机构英文简称>
```

不要把root密码或机构应用密码提交到Git。

## 数据内容操作

建库、建表、迁移和授权必须由root账号执行，并由用户亲自 `SOURCE`。

数据库内容的查询、新增、修改和删除必须使用SQL文件，并通过统一执行器留下本机操作日志：

```bash
./tools/run_mysql_script.sh <read|write> <client.cnf> <script.sql>
```

完整规范和模板见：`database/operations/README.md`。
