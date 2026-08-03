-- Level D / Look Out! / 三名虚拟学生工作流模拟
-- 使用cyana_writer执行，可重复运行；仅清理SIM_前缀的本模拟数据。

USE `inst_cyana`;
SET NAMES utf8mb4;
START TRANSACTION;

DELETE FROM feedback WHERE feedback_id LIKE 'SIM_FB_%';
DELETE FROM `answer` WHERE answer_id LIKE 'SIM_ANS_%';
DELETE FROM submission WHERE submission_id LIKE 'SIM_SUB_%';
DELETE FROM activity_item WHERE activity_item_id LIKE 'SIM_AI_%';
DELETE FROM activity WHERE activity_id = 'SIM_ACT_LOOK_OUT';
DELETE FROM content_item WHERE item_id LIKE 'SIM_Q_LOOK_%';
DELETE FROM content_item WHERE item_id = 'SIM_PASS_LOOK_OUT';
DELETE FROM content_item WHERE item_id = 'SIM_RES_LEVEL_D';
DELETE FROM group_member WHERE group_member_id LIKE 'SIM_GM_%';
DELETE FROM learning_group WHERE group_id = 'SIM_GRP_LEVEL_D';
DELETE FROM person WHERE person_id LIKE 'SIM_STU_%' OR person_id = 'SIM_TEA_001';

INSERT INTO person
    (person_id, person_type, person_name, contact_json, profile_json, status)
VALUES
    ('SIM_TEA_001', 'staff', '陈老师（模拟）', NULL,
     JSON_OBJECT('role', 'teacher', 'simulation', TRUE), 'active'),
    ('SIM_STU_ANAN', 'student', '安安（模拟）', NULL,
     JSON_OBJECT('level', 'D', 'simulation', TRUE), 'active'),
    ('SIM_STU_BEIBEI', 'student', '贝贝（模拟）', NULL,
     JSON_OBJECT('level', 'D', 'simulation', TRUE), 'active'),
    ('SIM_STU_CHENCHEN', 'student', '辰辰（模拟）', NULL,
     JSON_OBJECT('level', 'D', 'simulation', TRUE), 'active');

INSERT INTO learning_group
    (group_id, parent_group_id, group_type, group_name, level_value,
     owner_person_id, config_json, status)
VALUES
    ('SIM_GRP_LEVEL_D', NULL, 'class', 'Cyana Level D 模拟班', 'D',
     'SIM_TEA_001', JSON_OBJECT('simulation', TRUE), 'active');

INSERT INTO group_member
    (group_member_id, group_id, person_id, member_role, joined_at, status)
VALUES
    ('SIM_GM_TEA', 'SIM_GRP_LEVEL_D', 'SIM_TEA_001', 'teacher', '2026-08-03', 'active'),
    ('SIM_GM_ANAN', 'SIM_GRP_LEVEL_D', 'SIM_STU_ANAN', 'student', '2026-08-03', 'active'),
    ('SIM_GM_BEIBEI', 'SIM_GRP_LEVEL_D', 'SIM_STU_BEIBEI', 'student', '2026-08-03', 'active'),
    ('SIM_GM_CHENCHEN', 'SIM_GRP_LEVEL_D', 'SIM_STU_CHENCHEN', 'student', '2026-08-03', 'active');

INSERT INTO content_item
    (item_id, parent_item_id, item_type, title, body_text, payload_json,
     source_locator, version_label, status)
VALUES
    ('SIM_RES_LEVEL_D', NULL, 'resource',
     'Guided Reading Comprehension Passages & Questions - Level D', NULL,
     JSON_OBJECT('format', 'pdf', 'pages', 59, 'simulation', TRUE),
     '03 - Guided Reading Comprehension Passages & Questions_ Guided Reading Level D.pdf',
     '1.0', 'active'),
    ('SIM_PASS_LOOK_OUT', 'SIM_RES_LEVEL_D', 'passage', 'Look Out!',
     'The dog can see the cat. Look out, cat! The cat can see the bird. Look out, bird! The bird can see the bee. Look out, bee! The bee can see the dog. Look out, dog!',
     JSON_OBJECT('guided_reading_level', 'D', 'simulation', TRUE),
     'PDF page 2', '1.0', 'active'),
    ('SIM_Q_LOOK_01', 'SIM_PASS_LOOK_OUT', 'question',
     'Look Out! Q1', 'The cat can see the _____.',
     JSON_OBJECT('question_type', 'single_choice',
                 'options', JSON_ARRAY('pig', 'bird', 'bee'),
                 'correct_option', 'B', 'skill', 'explicit_detail'),
     'PDF page 3, question 1', '1.0', 'active'),
    ('SIM_Q_LOOK_02', 'SIM_PASS_LOOK_OUT', 'question',
     'Look Out! Q2', 'The dog can see the _____.',
     JSON_OBJECT('question_type', 'single_choice',
                 'options', JSON_ARRAY('cat', 'bird', 'pig'),
                 'correct_option', 'A', 'skill', 'explicit_detail'),
     'PDF page 3, question 2', '1.0', 'active'),
    ('SIM_Q_LOOK_03', 'SIM_PASS_LOOK_OUT', 'question',
     'Look Out! Q3', 'The bird can see the _____.',
     JSON_OBJECT('question_type', 'single_choice',
                 'options', JSON_ARRAY('dog', 'bee', 'bus'),
                 'correct_option', 'B', 'skill', 'explicit_detail'),
     'PDF page 3, question 3', '1.0', 'active'),
    ('SIM_Q_LOOK_04', 'SIM_PASS_LOOK_OUT', 'question',
     'Look Out! Q4', 'The bee can see the _____.',
     JSON_OBJECT('question_type', 'single_choice',
                 'options', JSON_ARRAY('dog', 'cat', 'pig'),
                 'correct_option', 'A', 'skill', 'explicit_detail'),
     'PDF page 3, question 4', '1.0', 'active');

INSERT INTO activity
    (activity_id, group_id, activity_name, activity_type, purpose,
     assigned_by, assigned_at, due_at, delivery_mode, scoring_rule,
     config_json, status)
VALUES
    ('SIM_ACT_LOOK_OUT', 'SIM_GRP_LEVEL_D', 'Level D - Look Out! 阅读理解',
     'assessment', '验证材料登记、评分与反馈闭环', 'SIM_TEA_001',
     '2026-08-03 09:00:00.000', '2026-08-03 18:00:00.000',
     'pdf', 'score', JSON_OBJECT('simulation', TRUE, 'total_score', 100),
     'closed');

INSERT INTO activity_item
    (activity_item_id, activity_id, content_item_id, item_order, score, is_required)
VALUES
    ('SIM_AI_LOOK_01', 'SIM_ACT_LOOK_OUT', 'SIM_Q_LOOK_01', 1, 25, TRUE),
    ('SIM_AI_LOOK_02', 'SIM_ACT_LOOK_OUT', 'SIM_Q_LOOK_02', 2, 25, TRUE),
    ('SIM_AI_LOOK_03', 'SIM_ACT_LOOK_OUT', 'SIM_Q_LOOK_03', 3, 25, TRUE),
    ('SIM_AI_LOOK_04', 'SIM_ACT_LOOK_OUT', 'SIM_Q_LOOK_04', 4, 25, TRUE);

INSERT INTO submission
    (submission_id, activity_id, student_id, status, submitted_at,
     final_score, graded_by, graded_at, metadata_json)
VALUES
    ('SIM_SUB_ANAN', 'SIM_ACT_LOOK_OUT', 'SIM_STU_ANAN', 'graded',
     '2026-08-03 10:05:00.000', 100, 'SIM_TEA_001', '2026-08-03 11:00:00.000',
     JSON_OBJECT('source', 'uploaded_file', 'simulation', TRUE)),
    ('SIM_SUB_BEIBEI', 'SIM_ACT_LOOK_OUT', 'SIM_STU_BEIBEI', 'graded',
     '2026-08-03 10:10:00.000', 75, 'SIM_TEA_001', '2026-08-03 11:05:00.000',
     JSON_OBJECT('source', 'uploaded_file', 'simulation', TRUE)),
    ('SIM_SUB_CHENCHEN', 'SIM_ACT_LOOK_OUT', 'SIM_STU_CHENCHEN', 'graded',
     '2026-08-03 10:15:00.000', 25, 'SIM_TEA_001', '2026-08-03 11:10:00.000',
     JSON_OBJECT('source', 'uploaded_file', 'simulation', TRUE));

INSERT INTO `answer`
    (answer_id, submission_id, activity_item_id, response_json,
     grading_status, score, is_correct, error_code, comment_json,
     graded_by, graded_at)
VALUES
    ('SIM_ANS_ANAN_01', 'SIM_SUB_ANAN', 'SIM_AI_LOOK_01', JSON_OBJECT('selected_option', 'B'), 'graded', 25, TRUE, NULL, JSON_OBJECT('note', '定位正确'), 'SIM_TEA_001', '2026-08-03 11:00:00.000'),
    ('SIM_ANS_ANAN_02', 'SIM_SUB_ANAN', 'SIM_AI_LOOK_02', JSON_OBJECT('selected_option', 'A'), 'graded', 25, TRUE, NULL, JSON_OBJECT('note', '定位正确'), 'SIM_TEA_001', '2026-08-03 11:00:00.000'),
    ('SIM_ANS_ANAN_03', 'SIM_SUB_ANAN', 'SIM_AI_LOOK_03', JSON_OBJECT('selected_option', 'B'), 'graded', 25, TRUE, NULL, JSON_OBJECT('note', '定位正确'), 'SIM_TEA_001', '2026-08-03 11:00:00.000'),
    ('SIM_ANS_ANAN_04', 'SIM_SUB_ANAN', 'SIM_AI_LOOK_04', JSON_OBJECT('selected_option', 'A'), 'graded', 25, TRUE, NULL, JSON_OBJECT('note', '定位正确'), 'SIM_TEA_001', '2026-08-03 11:00:00.000'),

    ('SIM_ANS_BEIBEI_01', 'SIM_SUB_BEIBEI', 'SIM_AI_LOOK_01', JSON_OBJECT('selected_option', 'B'), 'graded', 25, TRUE, NULL, JSON_OBJECT('note', '定位正确'), 'SIM_TEA_001', '2026-08-03 11:05:00.000'),
    ('SIM_ANS_BEIBEI_02', 'SIM_SUB_BEIBEI', 'SIM_AI_LOOK_02', JSON_OBJECT('selected_option', 'C'), 'graded', 0, FALSE, 'explicit_detail_mismatch', JSON_OBJECT('note', '未对应dog所在句'), 'SIM_TEA_001', '2026-08-03 11:05:00.000'),
    ('SIM_ANS_BEIBEI_03', 'SIM_SUB_BEIBEI', 'SIM_AI_LOOK_03', JSON_OBJECT('selected_option', 'B'), 'graded', 25, TRUE, NULL, JSON_OBJECT('note', '定位正确'), 'SIM_TEA_001', '2026-08-03 11:05:00.000'),
    ('SIM_ANS_BEIBEI_04', 'SIM_SUB_BEIBEI', 'SIM_AI_LOOK_04', JSON_OBJECT('selected_option', 'A'), 'graded', 25, TRUE, NULL, JSON_OBJECT('note', '定位正确'), 'SIM_TEA_001', '2026-08-03 11:05:00.000'),

    ('SIM_ANS_CHEN_01', 'SIM_SUB_CHENCHEN', 'SIM_AI_LOOK_01', JSON_OBJECT('selected_option', 'A'), 'graded', 0, FALSE, 'subject_object_confusion', JSON_OBJECT('note', '未稳定区分观察者和对象'), 'SIM_TEA_001', '2026-08-03 11:10:00.000'),
    ('SIM_ANS_CHEN_02', 'SIM_SUB_CHENCHEN', 'SIM_AI_LOOK_02', JSON_OBJECT('selected_option', 'C'), 'graded', 0, FALSE, 'explicit_detail_mismatch', JSON_OBJECT('note', '未回到对应原句'), 'SIM_TEA_001', '2026-08-03 11:10:00.000'),
    ('SIM_ANS_CHEN_03', 'SIM_SUB_CHENCHEN', 'SIM_AI_LOOK_03', JSON_OBJECT('selected_option', 'C'), 'graded', 0, FALSE, 'explicit_detail_mismatch', JSON_OBJECT('note', '选择了文中未出现的对象'), 'SIM_TEA_001', '2026-08-03 11:10:00.000'),
    ('SIM_ANS_CHEN_04', 'SIM_SUB_CHENCHEN', 'SIM_AI_LOOK_04', JSON_OBJECT('selected_option', 'A'), 'graded', 25, TRUE, NULL, JSON_OBJECT('note', '定位正确'), 'SIM_TEA_001', '2026-08-03 11:10:00.000');

INSERT INTO feedback
    (feedback_id, submission_id, recipient_person_id, owner_person_id,
     feedback_type, summary, detail_json, status, feedback_at, follow_up_at)
VALUES
    ('SIM_FB_ANAN', 'SIM_SUB_ANAN', 'SIM_STU_ANAN', 'SIM_TEA_001', 'report',
     '4题全对，能准确对应每个动物看到的对象。',
     JSON_OBJECT('strength', '显性信息定位准确，人物关系链清楚',
                 'issue', '本次未发现明显错误',
                 'action', '下一步尝试遮住图片复述dog-cat-bird-bee关系链',
                 'follow_up', '安排同级别无图片提示阅读1篇'),
     'completed', '2026-08-03 11:20:00.000', '2026-08-10 09:00:00.000'),
    ('SIM_FB_BEIBEI', 'SIM_SUB_BEIBEI', 'SIM_STU_BEIBEI', 'SIM_TEA_001', 'report',
     '答对3/4题；第2题未回到dog所在原句。',
     JSON_OBJECT('strength', '大部分显性细节能正确定位',
                 'issue', '遇到相似动物选项时会凭印象作答',
                 'action', '先圈出题目主语dog，再在原文找到同一主语并划出宾语cat',
                 'follow_up', '补做2组主语-宾语配对题'),
     'completed', '2026-08-03 11:25:00.000', '2026-08-06 09:00:00.000'),
    ('SIM_FB_CHEN', 'SIM_SUB_CHENCHEN', 'SIM_STU_CHENCHEN', 'SIM_TEA_001', 'report',
     '答对1/4题；需要加强主语与观察对象的逐句对应。',
     JSON_OBJECT('strength', '第4题能正确找到bee看到dog',
                 'issue', '前三题出现主客体混淆及脱离原文选择',
                 'action', '每读一句用箭头记录dog→cat、cat→bird，再逐题匹配',
                 'follow_up', '教师带读原文1次并完成4道同结构口头题'),
     'completed', '2026-08-03 11:30:00.000', '2026-08-05 09:00:00.000');

COMMIT;
