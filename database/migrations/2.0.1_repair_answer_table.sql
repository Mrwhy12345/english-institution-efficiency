-- Cyana minimal foundation 2.0.1
-- 修复MySQL 8.4中answer标识符未加反引号导致的缺表问题。
-- 使用root账号在inst_cyana中执行。

USE `inst_cyana`;

-- SOURCE遇错会继续执行，先清理可能由失败执行留下的版本记录。
DELETE FROM schema_version WHERE version_no = '2.0.1';

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

GRANT INSERT, UPDATE, DELETE ON `inst_cyana`.`answer`
  TO 'cyana_writer'@'localhost';

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

INSERT INTO schema_version (version_no, description)
SELECT '2.0.1', 'Repair quoted answer table and submission score view'
WHERE EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'inst_cyana'
      AND table_name = 'answer'
      AND table_type = 'BASE TABLE'
)
AND EXISTS (
    SELECT 1 FROM information_schema.views
    WHERE table_schema = 'inst_cyana'
      AND table_name = 'v_submission_score_check'
);
