-- 英语机构最小数据基座
-- MySQL 8.4 LTS
-- 10张业务表 + 1张结构治理表
-- 执行前请先 USE 目标机构数据库。

SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci;
SET time_zone = '+08:00';

CREATE TABLE IF NOT EXISTS schema_version (
    version_no         VARCHAR(20)  NOT NULL COMMENT '结构版本号',
    description        VARCHAR(200) NOT NULL COMMENT '版本说明',
    applied_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (version_no)
) ENGINE=InnoDB COMMENT='数据库结构版本';

CREATE TABLE IF NOT EXISTS person (
    person_id          VARCHAR(32)  NOT NULL COMMENT '人员唯一编号',
    person_type        VARCHAR(20)  NOT NULL COMMENT 'student/guardian/staff',
    person_name        VARCHAR(100) NOT NULL COMMENT '姓名',
    contact_json       JSON         NULL COMMENT '电话、邮箱、沟通偏好',
    profile_json       JSON         NULL COMMENT '年级、学校、岗位等低频属性',
    status             VARCHAR(20)  NOT NULL DEFAULT 'active',
    created_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
                                      ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (person_id),
    KEY idx_person_type_status (person_type, status),
    KEY idx_person_name (person_name),
    CONSTRAINT chk_person_type
        CHECK (person_type IN ('student', 'guardian', 'staff'))
) ENGINE=InnoDB COMMENT='统一人员：学员、家长、员工';

CREATE TABLE IF NOT EXISTS person_relation (
    relation_id        VARCHAR(32) NOT NULL COMMENT '关系唯一编号',
    from_person_id     VARCHAR(32) NOT NULL COMMENT '关系发起人员',
    to_person_id       VARCHAR(32) NOT NULL COMMENT '关系目标人员',
    relation_type      VARCHAR(30) NOT NULL COMMENT 'mother/father/guardian等',
    is_primary         BOOLEAN     NOT NULL DEFAULT FALSE COMMENT '是否主要联系人',
    permission_json    JSON        NULL COMMENT '接收反馈等权限',
    status             VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at         DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at         DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
                                     ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (relation_id),
    UNIQUE KEY uk_person_relation
        (from_person_id, to_person_id, relation_type),
    KEY idx_relation_to (to_person_id, relation_type),
    CONSTRAINT fk_relation_from
        FOREIGN KEY (from_person_id) REFERENCES person (person_id)
        ON UPDATE RESTRICT ON DELETE CASCADE,
    CONSTRAINT fk_relation_to
        FOREIGN KEY (to_person_id) REFERENCES person (person_id)
        ON UPDATE RESTRICT ON DELETE CASCADE,
    CONSTRAINT chk_relation_not_self
        CHECK (from_person_id <> to_person_id)
) ENGINE=InnoDB COMMENT='人员之间的家庭及业务关系';

CREATE TABLE IF NOT EXISTS learning_group (
    group_id           VARCHAR(32)  NOT NULL COMMENT '群组唯一编号',
    parent_group_id    VARCHAR(32)  NULL COMMENT '父级课程或组织',
    group_type         VARCHAR(20)  NOT NULL COMMENT 'course/class',
    group_name         VARCHAR(150) NOT NULL COMMENT '课程或班级名称',
    level_value        VARCHAR(30)  NULL COMMENT '级别',
    owner_person_id    VARCHAR(32)  NULL COMMENT '负责人',
    config_json        JSON         NULL COMMENT '校区、课时、年龄等扩展配置',
    status             VARCHAR(20)  NOT NULL DEFAULT 'active',
    created_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
                                      ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (group_id),
    KEY idx_group_parent (parent_group_id),
    KEY idx_group_owner (owner_person_id),
    KEY idx_group_type_status (group_type, status),
    CONSTRAINT fk_group_parent
        FOREIGN KEY (parent_group_id) REFERENCES learning_group (group_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_group_owner
        FOREIGN KEY (owner_person_id) REFERENCES person (person_id)
        ON UPDATE RESTRICT ON DELETE SET NULL,
    CONSTRAINT chk_group_type
        CHECK (group_type IN ('course', 'class')),
    CONSTRAINT chk_group_not_self
        CHECK (parent_group_id IS NULL OR parent_group_id <> group_id)
) ENGINE=InnoDB COMMENT='统一学习组织：课程与班级';

CREATE TABLE IF NOT EXISTS group_member (
    group_member_id    VARCHAR(32) NOT NULL COMMENT '成员关系编号',
    group_id           VARCHAR(32) NOT NULL,
    person_id          VARCHAR(32) NOT NULL,
    member_role        VARCHAR(20) NOT NULL COMMENT 'student/teacher/assistant',
    joined_at          DATE        NOT NULL COMMENT '加入日期',
    left_at            DATE        NULL COMMENT '退出日期',
    status             VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at         DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at         DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
                                     ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (group_member_id),
    UNIQUE KEY uk_group_member_period
        (group_id, person_id, member_role, joined_at),
    KEY idx_member_person_status (person_id, status),
    CONSTRAINT fk_member_group
        FOREIGN KEY (group_id) REFERENCES learning_group (group_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_member_person
        FOREIGN KEY (person_id) REFERENCES person (person_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT chk_member_dates
        CHECK (left_at IS NULL OR joined_at <= left_at)
) ENGINE=InnoDB COMMENT='人员加入课程或班级的历史';

CREATE TABLE IF NOT EXISTS content_item (
    item_id            VARCHAR(32)  NOT NULL COMMENT '内容唯一编号',
    parent_item_id     VARCHAR(32)  NULL COMMENT '父级资源或文章',
    item_type          VARCHAR(20)  NOT NULL
                                      COMMENT 'resource/passage/question/skill',
    title              VARCHAR(255) NOT NULL COMMENT '标题',
    body_text          LONGTEXT     NULL COMMENT '正文或题干',
    payload_json       JSON         NULL COMMENT '选项、答案、量规、版权等',
    source_locator     VARCHAR(255) NULL COMMENT '文件页码或外部位置',
    version_label      VARCHAR(30)  NOT NULL DEFAULT '1.0',
    status             VARCHAR(20)  NOT NULL DEFAULT 'active',
    created_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
                                      ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (item_id),
    KEY idx_content_parent (parent_item_id),
    KEY idx_content_type_status (item_type, status),
    CONSTRAINT fk_content_parent
        FOREIGN KEY (parent_item_id) REFERENCES content_item (item_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT chk_content_type
        CHECK (item_type IN ('resource', 'passage', 'question', 'skill')),
    CONSTRAINT chk_content_not_self
        CHECK (parent_item_id IS NULL OR parent_item_id <> item_id)
) ENGINE=InnoDB COMMENT='统一内容：资源、文章、题目、能力标签';

CREATE TABLE IF NOT EXISTS activity (
    activity_id        VARCHAR(32)  NOT NULL COMMENT '任务唯一编号',
    group_id           VARCHAR(32)  NOT NULL COMMENT '布置目标群组',
    activity_name      VARCHAR(150) NOT NULL,
    activity_type      VARCHAR(20)  NOT NULL COMMENT 'homework/assessment/classwork',
    purpose            VARCHAR(100) NULL COMMENT '预习、复习、诊断等',
    assigned_by        VARCHAR(32)  NOT NULL COMMENT '布置人',
    assigned_at        DATETIME(3)  NULL,
    due_at             DATETIME(3)  NULL,
    delivery_mode      VARCHAR(20)  NOT NULL COMMENT 'online/paper/pdf',
    scoring_rule       VARCHAR(20)  NOT NULL COMMENT 'score/accuracy/completion',
    config_json        JSON         NULL COMMENT '任务特殊配置',
    status             VARCHAR(20)  NOT NULL DEFAULT 'draft',
    created_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
                                      ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (activity_id),
    KEY idx_activity_group_status (group_id, status),
    KEY idx_activity_due (due_at),
    KEY idx_activity_assigner (assigned_by),
    CONSTRAINT fk_activity_group
        FOREIGN KEY (group_id) REFERENCES learning_group (group_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_activity_assigner
        FOREIGN KEY (assigned_by) REFERENCES person (person_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT chk_activity_dates
        CHECK (assigned_at IS NULL OR due_at IS NULL OR assigned_at <= due_at)
) ENGINE=InnoDB COMMENT='一次发布的作业、测评或课堂任务';

CREATE TABLE IF NOT EXISTS activity_item (
    activity_item_id   VARCHAR(32)  NOT NULL COMMENT '任务题目编号',
    activity_id        VARCHAR(32)  NOT NULL,
    content_item_id    VARCHAR(32)  NOT NULL COMMENT '通常引用question类型内容',
    item_order         INT          NOT NULL,
    score              DECIMAL(8,2) NOT NULL DEFAULT 0,
    is_required        BOOLEAN      NOT NULL DEFAULT TRUE,
    config_json        JSON         NULL COMMENT '本次使用的覆盖配置',
    created_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (activity_item_id),
    UNIQUE KEY uk_activity_content (activity_id, content_item_id),
    UNIQUE KEY uk_activity_order (activity_id, item_order),
    KEY idx_activity_item_content (content_item_id),
    CONSTRAINT fk_activity_item_activity
        FOREIGN KEY (activity_id) REFERENCES activity (activity_id)
        ON UPDATE RESTRICT ON DELETE CASCADE,
    CONSTRAINT fk_activity_item_content
        FOREIGN KEY (content_item_id) REFERENCES content_item (item_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT chk_activity_item_order CHECK (item_order > 0),
    CONSTRAINT chk_activity_item_score CHECK (score >= 0)
) ENGINE=InnoDB COMMENT='任务与题目的关系、顺序及本次分值';

CREATE TABLE IF NOT EXISTS submission (
    submission_id      VARCHAR(32)  NOT NULL COMMENT '提交唯一编号',
    activity_id        VARCHAR(32)  NOT NULL,
    student_id         VARCHAR(32)  NOT NULL COMMENT 'person中的student',
    status             VARCHAR(20)  NOT NULL DEFAULT 'not_started',
    submitted_at       DATETIME(3)  NULL,
    submission_uri     TEXT         NULL COMMENT '照片或文件地址',
    final_score        DECIMAL(8,2) NULL,
    graded_by          VARCHAR(32)  NULL COMMENT '评分人员',
    graded_at          DATETIME(3)  NULL,
    metadata_json      JSON         NULL COMMENT '设备、导入批次等扩展信息',
    created_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
                                      ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (submission_id),
    UNIQUE KEY uk_submission_activity_student (activity_id, student_id),
    KEY idx_submission_student_status (student_id, status),
    KEY idx_submission_grader (graded_by),
    CONSTRAINT fk_submission_activity
        FOREIGN KEY (activity_id) REFERENCES activity (activity_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_submission_student
        FOREIGN KEY (student_id) REFERENCES person (person_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_submission_grader
        FOREIGN KEY (graded_by) REFERENCES person (person_id)
        ON UPDATE RESTRICT ON DELETE SET NULL,
    CONSTRAINT chk_submission_score
        CHECK (final_score IS NULL OR final_score >= 0),
    CONSTRAINT chk_submission_graded
        CHECK (status <> 'graded' OR graded_at IS NOT NULL)
) ENGINE=InnoDB COMMENT='一名学员对一次任务的提交';

CREATE TABLE IF NOT EXISTS `answer` (
    answer_id          VARCHAR(32)  NOT NULL COMMENT '答案唯一编号',
    submission_id      VARCHAR(32)  NOT NULL,
    activity_item_id   VARCHAR(32)  NOT NULL,
    response_json      JSON         NULL COMMENT '文本、选项、图片等回答',
    grading_status     VARCHAR(20)  NOT NULL DEFAULT 'ungraded',
    score              DECIMAL(8,2) NULL,
    is_correct         BOOLEAN      NULL,
    error_code         VARCHAR(30)  NULL COMMENT '错因代码',
    comment_json       JSON         NULL COMMENT '教师点评及结构化诊断',
    graded_by          VARCHAR(32)  NULL,
    graded_at          DATETIME(3)  NULL,
    created_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
                                      ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (answer_id),
    UNIQUE KEY uk_answer_submission_item
        (submission_id, activity_item_id),
    KEY idx_answer_item (activity_item_id),
    KEY idx_answer_grading (grading_status, graded_by),
    CONSTRAINT fk_answer_submission
        FOREIGN KEY (submission_id) REFERENCES submission (submission_id)
        ON UPDATE RESTRICT ON DELETE CASCADE,
    CONSTRAINT fk_answer_activity_item
        FOREIGN KEY (activity_item_id) REFERENCES activity_item (activity_item_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_answer_grader
        FOREIGN KEY (graded_by) REFERENCES person (person_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT chk_answer_score CHECK (score IS NULL OR score >= 0),
    CONSTRAINT chk_answer_graded
        CHECK (
            grading_status <> 'graded'
            OR (graded_by IS NOT NULL AND graded_at IS NOT NULL AND score IS NOT NULL)
        )
) ENGINE=InnoDB COMMENT='一次提交中对一道任务题目的最终回答';

CREATE TABLE IF NOT EXISTS feedback (
    feedback_id        VARCHAR(32)  NOT NULL COMMENT '反馈唯一编号',
    submission_id      VARCHAR(32)  NOT NULL,
    recipient_person_id VARCHAR(32) NULL COMMENT '家长或学员',
    owner_person_id    VARCHAR(32)  NOT NULL COMMENT '反馈负责人',
    feedback_type      VARCHAR(20)  NOT NULL COMMENT 'report/call/meeting/message',
    summary            TEXT         NOT NULL,
    detail_json        JSON         NULL COMMENT '优势、薄弱点、行动计划、回应等',
    status             VARCHAR(20)  NOT NULL DEFAULT 'pending',
    feedback_at        DATETIME(3)  NULL,
    follow_up_at       DATETIME(3)  NULL,
    created_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
                                      ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (feedback_id),
    KEY idx_feedback_submission (submission_id),
    KEY idx_feedback_recipient (recipient_person_id),
    KEY idx_feedback_owner_status (owner_person_id, status),
    KEY idx_feedback_follow_up (follow_up_at),
    CONSTRAINT fk_feedback_submission
        FOREIGN KEY (submission_id) REFERENCES submission (submission_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_feedback_recipient
        FOREIGN KEY (recipient_person_id) REFERENCES person (person_id)
        ON UPDATE RESTRICT ON DELETE SET NULL,
    CONSTRAINT fk_feedback_owner
        FOREIGN KEY (owner_person_id) REFERENCES person (person_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB COMMENT='针对一次提交的报告、沟通或跟进';

CREATE OR REPLACE VIEW v_activity_score_check AS
SELECT
    a.activity_id,
    a.activity_name,
    COALESCE(SUM(ai.score), 0) AS activity_total_score
FROM activity a
LEFT JOIN activity_item ai ON ai.activity_id = a.activity_id
GROUP BY a.activity_id, a.activity_name;

CREATE OR REPLACE VIEW v_submission_score_check AS
SELECT
    s.submission_id,
    s.activity_id,
    s.student_id,
    s.final_score,
    COALESCE(SUM(ans.score), 0) AS calculated_score,
    s.final_score - COALESCE(SUM(ans.score), 0) AS score_difference
FROM submission s
LEFT JOIN `answer` ans ON ans.submission_id = s.submission_id
GROUP BY s.submission_id, s.activity_id, s.student_id, s.final_score;

CREATE OR REPLACE VIEW v_submission_overdue AS
SELECT
    s.submission_id,
    s.activity_id,
    s.student_id,
    a.due_at,
    s.submitted_at,
    CASE
        WHEN a.due_at IS NULL THEN NULL
        WHEN s.submitted_at IS NULL AND CURRENT_TIMESTAMP(3) > a.due_at THEN TRUE
        WHEN s.submitted_at > a.due_at THEN TRUE
        ELSE FALSE
    END AS is_late
FROM submission s
JOIN activity a ON a.activity_id = s.activity_id;

INSERT INTO schema_version (version_no, description)
VALUES ('2.0.1', 'Minimal data foundation with MySQL 8.4 answer-table repair')
ON DUPLICATE KEY UPDATE description = VALUES(description);
