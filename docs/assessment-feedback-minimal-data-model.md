# 测评与反馈最小数据模型

## 一、设计目标

本设计服务于“教学交付 → 测评诊断 → 家长反馈 → 教学改进”的最小闭环。在复用学员、家长、员工、课程、班级和能力点等主数据的前提下，仅新增能够支撑测评、诊断、反馈和核心统计的业务表。

设计采用四类互相验证的交付物：

| 序号 | 交付物 | 作用 |
| ---: | --- | --- |
| 1 | 业务闭环图 | 说明数据为什么产生以及流向哪里 |
| 2 | ER 关系图 | 说明实体、主外键和关系基数 |
| 3 | 字段数据字典 | 说明字段含义、类型、约束和来源 |
| 4 | 指标血缘矩阵 | 验证数据能否支持实际统计 |

树状图适合表达业务分类，但不能表达主外键、关系基数、数据粒度和指标计算路径，因此仅作为辅助视图，不作为数据库设计的核心论证工具。

## 二、最小化建表原则

一个业务对象原则上只有同时满足以下条件时才独立建表：

| 序号 | 判断条件 | 说明 |
| ---: | --- | --- |
| 1 | 具有独立业务含义 | 例如“测评”和“学员参加测评”是不同事实 |
| 2 | 具有独立生命周期 | 可以被单独创建、修改、关闭或归档 |
| 3 | 会被多个对象引用 | 例如一道题可以被多套测评使用 |
| 4 | 单行数据粒度明确 | 能清楚表述“一行代表什么” |
| 5 | 不拆分会产生重复 | 例如答题时不应重复保存题干和标准答案 |
| 6 | 对业务统计具有必要性 | 能支撑至少一项已确认的业务指标或追溯需求 |

第一阶段做以下合并和约束：

- 测评方案、试卷和考试场次合并为 `assessment`。
- 学情报告、反馈任务和家长沟通合并为 `feedback`。
- 错因诊断字段放入 `student_answer`。
- 能力掌握结果从答题明细计算，不预先建立结果表。
- 一道题只关联一个主要能力点；出现明确的多能力点统计需求后，再建立题目与能力点关系表。
- 一名学员对一次测评默认只有一次正式作答；出现补考需求后，再增加作答次数。

## 三、模型边界

### 3.1 复用的主数据

| 序号 | 主数据 | 主键 | 本模型中的用途 |
| ---: | --- | --- | --- |
| 1 | 学员 `student` | `student_id` | 测评参与者 |
| 2 | 家长 `guardian` | `guardian_id` | 反馈接收人 |
| 3 | 员工 `staff` | `staff_id` | 创建、评分和反馈负责人 |
| 4 | 课程 `course` | `course_id` | 测评所属课程 |
| 5 | 班级 `class` | `class_id` | 测评适用班级 |
| 6 | 能力点 `skill_point` | `skill_id` | 题目考查目标和能力统计维度 |

### 3.2 新增业务表

| 序号 | 表名 | 一行代表什么 | 建表原因 |
| ---: | --- | --- | --- |
| 1 | `assessment` | 一次可发布的测评 | 定义测评规则和适用范围 |
| 2 | `question` | 一道可复用的标准题目 | 支撑题目复用和质量分析 |
| 3 | `assessment_question` | 某道题在某套测评中的使用 | 解决测评与题目的多对多关系 |
| 4 | `assessment_attempt` | 一名学员参加一次测评 | 记录参与、提交和评分状态 |
| 5 | `student_answer` | 学员对一道测评题目的最终作答 | 保存最细粒度的原始测评事实 |
| 6 | `feedback` | 针对一次测评结果的一次反馈 | 记录报告、沟通和后续行动 |

## 四、ER 关系图

```mermaid
erDiagram
    STUDENT ||--o{ ASSESSMENT_ATTEMPT : "参加"
    CLASS ||--o{ ASSESSMENT : "使用"
    COURSE ||--o{ ASSESSMENT : "归属"
    STAFF ||--o{ ASSESSMENT : "创建"

    ASSESSMENT ||--|{ ASSESSMENT_QUESTION : "包含"
    QUESTION ||--o{ ASSESSMENT_QUESTION : "被引用"
    SKILL_POINT ||--o{ QUESTION : "主要考查"

    ASSESSMENT ||--o{ ASSESSMENT_ATTEMPT : "产生"
    ASSESSMENT_ATTEMPT ||--|{ STUDENT_ANSWER : "包含"
    ASSESSMENT_QUESTION ||--o{ STUDENT_ANSWER : "对应"

    ASSESSMENT_ATTEMPT ||--o{ FEEDBACK : "形成"
    STAFF ||--o{ FEEDBACK : "负责"
    GUARDIAN ||--o{ FEEDBACK : "接收"
```

### 4.1 关系基数

| 序号 | 关系 | 基数 | 设计依据 |
| ---: | --- | --- | --- |
| 1 | 测评 → 测评题目 | 1:N | 一套测评包含多道题 |
| 2 | 题目 → 测评题目 | 1:N | 一道题可以被多套测评使用 |
| 3 | 测评 → 学员测评 | 1:N | 多名学员可以参加同一测评 |
| 4 | 学员 → 学员测评 | 1:N | 一名学员会参加多次测评 |
| 5 | 学员测评 → 学员答题 | 1:N | 一次测评包含多条答题记录 |
| 6 | 测评题目 → 学员答题 | 1:N | 多名学员会回答同一道测评题目 |
| 7 | 能力点 → 题目 | 1:N | 一个能力点可以由多道题测量 |
| 8 | 学员测评 → 反馈 | 1:N | 一次测评结果可能发生多次反馈 |

## 五、字段数据字典

### 5.1 测评表 `assessment`

数据粒度：一行代表一次可发布、可供学员参加的测评。

| 序号 | 字段 | 类型示例 | 约束 | 说明 |
| ---: | --- | --- | --- | --- |
| 1 | `assessment_id` | VARCHAR(32) | PK | 测评唯一编号 |
| 2 | `assessment_name` | VARCHAR(100) | NOT NULL | 测评名称 |
| 3 | `assessment_type` | VARCHAR(20) | NOT NULL | 入学、单元、月度、期末或复测 |
| 4 | `course_id` | VARCHAR(32) | FK | 所属课程 |
| 5 | `class_id` | VARCHAR(32) | FK，可空 | 适用班级；通用测评可以为空 |
| 6 | `total_score` | DECIMAL(6,2) | NOT NULL | 测评总分 |
| 7 | `start_time` | DATETIME | 可空 | 开始时间 |
| 8 | `end_time` | DATETIME | 可空 | 结束时间 |
| 9 | `status` | VARCHAR(20) | NOT NULL | 草稿、已发布、已结束、已归档 |
| 10 | `created_by` | VARCHAR(32) | FK | 创建人员 |
| 11 | `created_at` | DATETIME | NOT NULL | 创建时间 |

### 5.2 题目表 `question`

数据粒度：一行代表一道可以被重复使用的标准题目。

| 序号 | 字段 | 类型示例 | 约束 | 说明 |
| ---: | --- | --- | --- | --- |
| 1 | `question_id` | VARCHAR(32) | PK | 题目唯一编号 |
| 2 | `question_type` | VARCHAR(20) | NOT NULL | 单选、填空、口语、写作等 |
| 3 | `question_content` | TEXT | NOT NULL | 题干或资源地址 |
| 4 | `standard_answer` | TEXT/JSON | 可空 | 标准答案 |
| 5 | `skill_id` | VARCHAR(32) | FK | 主要能力点 |
| 6 | `difficulty` | SMALLINT | NOT NULL | 建议使用 1～5 级 |
| 7 | `explanation` | TEXT | 可空 | 答案解析 |
| 8 | `status` | VARCHAR(20) | NOT NULL | 启用或停用 |
| 9 | `created_at` | DATETIME | NOT NULL | 创建时间 |

### 5.3 测评题目表 `assessment_question`

数据粒度：一行代表一道题在一套测评中的使用。

| 序号 | 字段 | 类型示例 | 约束 | 说明 |
| ---: | --- | --- | --- | --- |
| 1 | `assessment_question_id` | VARCHAR(32) | PK | 测评题目编号 |
| 2 | `assessment_id` | VARCHAR(32) | FK、NOT NULL | 所属测评 |
| 3 | `question_id` | VARCHAR(32) | FK、NOT NULL | 对应标准题目 |
| 4 | `question_order` | INT | NOT NULL | 题目顺序 |
| 5 | `score` | DECIMAL(6,2) | NOT NULL | 本次测评中的分值 |
| 6 | `is_required` | BOOLEAN | NOT NULL | 是否必答 |

唯一约束：`UNIQUE(assessment_id, question_id)`。

### 5.4 学员测评表 `assessment_attempt`

数据粒度：一行代表一名学员参加一次测评。

| 序号 | 字段 | 类型示例 | 约束 | 说明 |
| ---: | --- | --- | --- | --- |
| 1 | `attempt_id` | VARCHAR(32) | PK | 学员测评编号 |
| 2 | `assessment_id` | VARCHAR(32) | FK、NOT NULL | 测评编号 |
| 3 | `student_id` | VARCHAR(32) | FK、NOT NULL | 学员编号 |
| 4 | `started_at` | DATETIME | 可空 | 开始作答时间 |
| 5 | `submitted_at` | DATETIME | 可空 | 提交时间 |
| 6 | `status` | VARCHAR(20) | NOT NULL | 未开始、作答中、已提交、已评分 |
| 7 | `final_score` | DECIMAL(6,2) | 可空 | 最终得分；应与答题明细汇总一致 |
| 8 | `graded_by` | VARCHAR(32) | FK，可空 | 人工评分教师 |
| 9 | `graded_at` | DATETIME | 可空 | 评分完成时间 |

唯一约束：`UNIQUE(assessment_id, student_id)`。

### 5.5 学员答题表 `student_answer`

数据粒度：一行代表学员对测评中一道题的最终作答。

| 序号 | 字段 | 类型示例 | 约束 | 说明 |
| ---: | --- | --- | --- | --- |
| 1 | `answer_id` | VARCHAR(32) | PK | 答题编号 |
| 2 | `attempt_id` | VARCHAR(32) | FK、NOT NULL | 学员测评编号 |
| 3 | `assessment_question_id` | VARCHAR(32) | FK、NOT NULL | 测评题目编号 |
| 4 | `student_answer` | TEXT/JSON | 可空 | 学员答案 |
| 5 | `is_correct` | BOOLEAN | 可空 | 是否正确；主观题评分前可以为空 |
| 6 | `score_awarded` | DECIMAL(6,2) | NOT NULL | 实际得分 |
| 7 | `error_reason` | VARCHAR(30) | 可空 | 知识、审题、粗心、表达等 |
| 8 | `teacher_comment` | TEXT | 可空 | 教师诊断 |
| 9 | `answered_at` | DATETIME | 可空 | 作答时间 |

唯一约束：`UNIQUE(attempt_id, assessment_question_id)`。

### 5.6 反馈记录表 `feedback`

数据粒度：一行代表针对一次学员测评的一次反馈行为。

| 序号 | 字段 | 类型示例 | 约束 | 说明 |
| ---: | --- | --- | --- | --- |
| 1 | `feedback_id` | VARCHAR(32) | PK | 反馈编号 |
| 2 | `attempt_id` | VARCHAR(32) | FK、NOT NULL | 对应学员测评 |
| 3 | `guardian_id` | VARCHAR(32) | FK，可空 | 接收家长 |
| 4 | `feedback_type` | VARCHAR(20) | NOT NULL | 学情报告、电话、面谈或微信 |
| 5 | `summary` | TEXT | NOT NULL | 学习表现摘要 |
| 6 | `strengths` | TEXT/JSON | 可空 | 优势能力 |
| 7 | `weaknesses` | TEXT/JSON | 可空 | 薄弱能力 |
| 8 | `action_plan` | TEXT/JSON | 可空 | 改进目标和行动 |
| 9 | `guardian_response` | TEXT | 可空 | 家长反馈 |
| 10 | `risk_level` | VARCHAR(10) | 可空 | 低、中或高 |
| 11 | `renewal_intention` | VARCHAR(10) | 可空 | 低、中或高 |
| 12 | `owner_id` | VARCHAR(32) | FK、NOT NULL | 反馈负责人 |
| 13 | `feedback_at` | DATETIME | 可空 | 实际反馈时间 |
| 14 | `follow_up_at` | DATETIME | 可空 | 下次跟进时间 |
| 15 | `status` | VARCHAR(20) | NOT NULL | 待反馈、已反馈、待跟进或已关闭 |

## 六、指标血缘验证

| 序号 | 指标 | 原始字段与计算路径 | 验证结果 |
| ---: | --- | --- | --- |
| 1 | 学员测评得分 | 汇总 `student_answer.score_awarded` | 可计算 |
| 2 | 测评完成率 | 按 `assessment_attempt.status` 统计 | 可计算 |
| 3 | 题目正确率 | 汇总 `student_answer.is_correct` | 可计算 |
| 4 | 能力点掌握度 | 答题 → 测评题目 → 题目 → 能力点，按实得分除以应得分 | 可计算 |
| 5 | 学员进步趋势 | 比较同一学员历次 `assessment_attempt.final_score` | 可计算 |
| 6 | 高频错因 | 按 `student_answer.error_reason` 分组统计 | 可计算 |
| 7 | 薄弱能力点 | 识别掌握度低于业务阈值的能力点 | 可计算 |
| 8 | 反馈及时率 | 比较 `assessment_attempt.submitted_at` 与 `feedback.feedback_at` | 可计算 |
| 9 | 家长续费意向 | 汇总 `feedback.renewal_intention` | 可计算 |
| 10 | 风险学员数量 | 按 `feedback.risk_level` 统计去重学员 | 可计算 |

## 七、一致性规则

| 序号 | 规则 | 校验方式 |
| ---: | --- | --- |
| 1 | 测评总分等于测评题目分值之和 | `assessment.total_score = SUM(assessment_question.score)` |
| 2 | 学员最终得分等于答题得分之和 | `assessment_attempt.final_score = SUM(student_answer.score_awarded)` |
| 3 | 单题得分不能超过题目分值 | `score_awarded <= assessment_question.score` |
| 4 | 测评结束时间不能早于开始时间 | `end_time >= start_time` |
| 5 | 反馈必须关联有效的学员测评 | `feedback.attempt_id` 外键校验 |
| 6 | 已评分记录必须有评分完成时间 | `status = 已评分` 时 `graded_at` 非空 |

## 八、延迟拆表条件

仅在出现明确业务需求时扩展模型：

| 序号 | 触发条件 | 建议新增表或字段 |
| ---: | --- | --- |
| 1 | 一道题需要同时统计多个能力点 | 新增 `question_skill` |
| 2 | 学员允许补考或多次尝试 | `assessment_attempt` 增加 `attempt_no` 并调整唯一约束 |
| 3 | 改进任务需要单独分配、提醒和验收 | 新增 `improvement_action` |
| 4 | 反馈报告需要版本管理和审批 | 拆分 `learning_report` 与 `feedback_communication` |
| 5 | 能力结果计算量过大且需要历史快照 | 新增 `student_skill_snapshot` |
| 6 | 不同场次需要独立时间、地点和监考安排 | 新增 `assessment_session` |

## 九、结论

当前阶段采用“6 类既有主数据 + 6 张新增业务表”即可形成测评与反馈的最小闭环。该模型符合以下要求：

- 每张表只有一个明确的数据粒度。
- 原始答题事实可追溯，不依赖预先生成的汇总表。
- 多对多关系通过 `assessment_question` 明确解决。
- 核心业务指标均可由原始字段推导。
- 暂未证实的复杂需求通过延迟拆表处理。

因此，树状图可以用于业务导航；正式的数据设计应以 ER 图、字段数据字典和指标血缘矩阵作为主要论证依据。
