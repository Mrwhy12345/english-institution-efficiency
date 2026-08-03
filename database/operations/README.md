# 数据内容操作规范

## 硬性边界

1. 建库、建表、迁移和授权只能由root账号执行，Codex只准备执行文件与验证文件，由用户亲自 `SOURCE`。
2. 业务数据的查询、新增、修改和删除禁止在MySQL提示符中临时手敲。
3. 每次操作必须有独立SQL脚本；写操作必须有对应验证脚本。
4. 写操作使用 `cyana_writer`，查询和验证使用 `cyana_reader`。
5. 每次执行必须通过 `tools/run_mysql_script.sh`，生成本地操作日志。

## 文件命名

```text
database/operations/YYYYMMDD_<业务对象>_<动作>.sql
database/operations/YYYYMMDD_<业务对象>_<动作>_verify.sql
```

示例：

```text
database/operations/20260804_student_homework_import.sql
database/operations/20260804_student_homework_import_verify.sql
```

## 写操作模板

从模板复制：

```bash
cp database/operations/templates/write.sql.template \
  database/operations/20260804_student_homework_import.sql
```

每个写脚本必须：

- 写明目的、来源、影响范围和回滚方法；
- 明确 `USE inst_cyana`；
- 使用 `START TRANSACTION` 与 `COMMIT`；
- 只影响明确ID或范围，不使用无条件 `UPDATE` 或 `DELETE`；
- 可以重复执行，或明确禁止重复执行；
- 配套只读验证脚本。

## 执行方法

写入：

```bash
./tools/run_mysql_script.sh \
  write \
  /private/tmp/cyana_writer.cnf \
  database/operations/20260804_student_homework_import.sql
```

验证：

```bash
./tools/run_mysql_script.sh \
  read \
  /private/tmp/cyana_reader.cnf \
  database/operations/20260804_student_homework_import_verify.sql
```

查询：

```bash
./tools/run_mysql_script.sh \
  read \
  /private/tmp/cyana_reader.cnf \
  database/operations/20260804_student_learning_query.sql
```

## 操作痕迹

执行器会在以下目录生成日志：

```text
.local/mysql-operation-logs/
```

每份日志包含：

- 操作编号；
- 开始和完成时间；
- 读或写模式；
- 实际MySQL账号；
- SQL文件绝对路径；
- SQL文件SHA-256；
- 执行时Git提交号；
- MySQL完整输出；
- 退出状态。

日志可能包含学生信息，因此只保存在本机，权限为当前用户可读写，不上传GitHub。GitHub保存SQL脚本本身及其版本历史。

## 失败处理

1. 执行器返回非0状态时，不得宣布操作成功。
2. 检查日志中的首个MySQL错误。
3. 若写脚本在事务内失败，应确认事务已回滚。
4. 修正脚本后形成新的Git版本，再次执行。
5. 无论成功或失败，都向用户提供日志位置和验证命令。
