-- 使用cyana_reader验证三名虚拟学生工作流
USE `inst_cyana`;

SELECT '1. object_counts' AS verification_item;
SELECT
  (SELECT COUNT(*) FROM person WHERE person_id LIKE 'SIM_STU_%') AS students,
  (SELECT COUNT(*) FROM content_item WHERE item_id LIKE 'SIM_Q_LOOK_%') AS questions,
  (SELECT COUNT(*) FROM submission WHERE submission_id LIKE 'SIM_SUB_%') AS submissions,
  (SELECT COUNT(*) FROM `answer` WHERE answer_id LIKE 'SIM_ANS_%') AS answers,
  (SELECT COUNT(*) FROM feedback WHERE feedback_id LIKE 'SIM_FB_%') AS feedback_records;

SELECT '2. student_scores' AS verification_item;
SELECT p.person_name, s.final_score,
       SUM(ans.is_correct = TRUE) AS correct_count,
       COUNT(ans.answer_id) AS answer_count
FROM submission s
JOIN person p ON p.person_id = s.student_id
JOIN `answer` ans ON ans.submission_id = s.submission_id
WHERE s.submission_id LIKE 'SIM_SUB_%'
GROUP BY p.person_name, s.final_score
ORDER BY s.final_score DESC;

SELECT '3. score_consistency' AS verification_item;
SELECT submission_id, final_score, calculated_score, score_difference
FROM v_submission_score_check
WHERE submission_id LIKE 'SIM_SUB_%'
ORDER BY submission_id;

SELECT '4. targeted_feedback' AS verification_item;
SELECT p.person_name, f.summary,
       JSON_UNQUOTE(JSON_EXTRACT(f.detail_json, '$.issue')) AS issue,
       JSON_UNQUOTE(JSON_EXTRACT(f.detail_json, '$.action')) AS next_action
FROM feedback f
JOIN submission s ON s.submission_id = f.submission_id
JOIN person p ON p.person_id = s.student_id
WHERE f.feedback_id LIKE 'SIM_FB_%'
ORDER BY p.person_name;
