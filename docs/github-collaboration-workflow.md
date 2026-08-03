# GitHub协作与发布规范

## 一、目的

本规范用于把每次本地工作稳定地登记到GitHub，确保任何后续协作者都能回答四个问题：

1. 改了什么？
2. 为什么改？
3. 如何验证？
4. 下一位协作者从哪里继续？

## 二、固定原则

| 序号 | 原则 | 要求 |
| ---: | --- | --- |
| 1 | 分支工作 | 不直接向 `main` 写入；使用 `codex/<主题>` 分支 |
| 2 | 范围明确 | 提交前检查工作区，只暂存本次任务文件，不默认使用 `git add -A` |
| 3 | 不上传秘密 | 密码、令牌、`.cnf`、真实账号配置和临时文件不得进入Git |
| 4 | 执行与验证成对 | 每个数据库变更同时提供执行SQL、验证SQL、预期结果和失败判断 |
| 5 | 长命令文件化 | 较长SQL或操作流程写成文件，用户使用 `SOURCE` 或脚本执行 |
| 6 | 证据先于结论 | 文档、数据库、PDF和模拟结论必须经过与风险相称的验证 |
| 7 | 小步提交 | 一个提交表达一个完整意图，提交信息简短、可追溯 |
| 8 | 草稿PR审阅 | 默认推送到草稿PR，说明变更、原因、影响、根因和验证证据 |
| 9 | 接力信息完整 | 阶段结束时更新工作小结、关键文件、当前状态和下一步 |

## 三、标准发布流程

### 1. 明确本次范围

```bash
git status -sb
git diff --stat
git diff --check
```

如存在与本次任务无关的改动，停止并确认归属，不静默混入提交。

### 2. 运行项目预检

```bash
./tools/github_preflight.sh
```

预检只读，不会暂存、提交或推送文件。它检查：

- GitHub CLI认证；
- 工作分支与远程仓库；
- Git格式错误；
- 已跟踪临时文件；
- 常见令牌和私钥；
- `.cnf`等本机凭据文件。

### 3. 完成任务专项验证

| 变更类型 | 最低验证要求 |
| --- | --- |
| SQL结构或迁移 | 执行文件 + 验证文件；确认表数、版本、权限或约束 |
| 模拟或真实数据 | 写账号事务录入 + 读账号独立复核；检查数量和指标一致性 |
| Markdown或HTML | 检查链接、结构、图示和 `git diff --check` |
| PDF | 重新生成、逐页渲染检查、页数和文本完整性检查 |
| Python脚本 | 语法编译，并执行与输出产物验证 |

### 4. 精确暂存

```bash
git add <本次文件1> <本次文件2> <本次文件3>
git status -sb
git diff --cached --stat
git diff --cached --check
```

只有确认整个工作区都属于同一任务时，才允许使用 `git add -A`。

### 5. 提交

```bash
git commit -m "<简短、明确的提交意图>"
```

推荐提交信息示例：

```text
document Cyana minimal data foundation pilot
add GitHub collaboration workflow
repair answer table migration
```

### 6. 推送当前分支

```bash
git push -u origin "$(git branch --show-current)"
```

### 7. 创建或更新草稿PR

先检查当前分支是否已有PR：

```bash
gh pr view --json number,title,url,state,isDraft,headRefName,baseRefName
```

没有PR时创建草稿：

```bash
gh pr create --draft --fill
```

PR说明必须包含：

1. `What changed`：改了什么；
2. `Why`：为什么需要；
3. `Impact`：对教师、负责人、系统或协作者的影响；
4. `Root cause`：如有修复，说明根因；
5. `Validation`：列出真实执行与验证证据。

### 8. 发布后复核

```bash
git status -sb
gh pr view --json number,title,url,state,isDraft,commits
```

完成标准：

- 当前分支已跟踪远程同名分支；
- 本次提交出现在PR中；
- 工作区没有遗漏的本次文件；
- PR仍为草稿，除非用户明确要求进入正式评审；
- 向用户返回分支、提交号、PR链接和验证结果。

## 四、数据库协作附加规范

每次数据库变更至少包含以下一组文件：

```text
database/migrations/<版本_变更>.sql
database/migrations/verify_<版本>.sql
```

执行顺序固定为：

```sql
SOURCE <变更文件>;
SOURCE <验证文件>;
```

日常数据写入固定为：

```text
材料识别 → 补齐关键信息 → 写账号事务录入 → 读账号独立验证 → 输出反馈
```

禁止事项：

- 不把root密码、读写密码或已填写密码的SQL上传Git；
- 不用root执行日常数据登记；
- 不在没有验证命令的情况下宣布数据库变更完成；
- 不因输出简洁而省略变更对象、验证结果或失败信息。

## 五、阶段性接力模板

阶段结束时至少记录：

```text
目标：本阶段解决什么问题
完成：已经落地的文件、结构和数据
验证：实际执行过的命令及关键结果
决策：采用了哪些原则，为什么
问题：发现并修复了什么，仍有什么风险
状态：分支、提交号、PR链接、数据库版本
下一步：下一位协作者可以直接执行什么
```

## 六、本项目当前发布状态

- 仓库：`Mrwhy12345/english-institution-efficiency`
- 默认分支：`main`
- 当前工作分支：`codex/assessment-feedback-minimal-model`
- 当前PR：`#1 Validate Cyana minimal teaching-feedback data foundation`
- 当前数据库结构版本：`2.0.1`

本规范本身也必须遵循上述流程完成预检、提交、推送和PR复核。
