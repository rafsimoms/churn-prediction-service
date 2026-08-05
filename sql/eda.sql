SELECT COUNT(*) FROM customers; -- count 7043
SELECT COUNT(*) FROM contracts; -- count 7043
SELECT COUNT(*) FROM services; -- count 7043 * 9 = 63387
SELECT COUNT(*) FROM charges; -- count 7043
SELECT COUNT(*) FROM churn_labels; -- count 7043

SELECT AVG(churned::int) FROM churn_labels; -- avg 0.26536987079369586824 - доля таргета

SELECT COUNT(*) 
FROM charges 
    JOIN contracts ON charges.customer_id = contracts.customer_id 
WHERE contracts.tenure = 0; """ count 11 - строки где tenure = 0, у которых total_charges = ' ', 
которое я при создании бд решил заменить на 0 """

SELECT COUNT(*) 
FROM charges 
    JOIN contracts ON charges.customer_id = contracts.customer_id 
WHERE contracts.tenure = 0 AND charges.total_charges = 0; -- соответственно предыдущему запросу возвращает 11

SELECT c.gender, AVG(churned::int) AS churn_rate, COUNT(*) AS n_groups 
FROM customers AS c 
    JOIN churn_labels ON c.customer_id = churn_labels.customer_id 
GROUP BY c.gender 
ORDER BY churn_rate DESC; -- запросы на долю таргета в группах для категориальных признаков, для остальных групп все в 01_eda.ipynb

SELECT s.service_type, s.service_status, AVG(churned::int) as churn_rate, COUNT(*) AS n_customers, COUNT(*)::numeric /
(SELECT COUNT(*) FROM customers) 
AS group_shape
FROM services AS s JOIN churn_labels ON s.customer_id = churn_labels.customer_id
GROUP BY s.service_type, s.service_status
ORDER BY churn_rate DESC; -- один запрос сразу показывает распределение для всех услуг

SELECT l.churned, COUNT(*) AS n, 
MIN(c.tenure) AS min, 
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY c.tenure) AS q25,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY c.tenure) AS med, 
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY c.tenure) AS q75,
MAX(c.tenure) AS max, 
AVG(tenure) AS mean 
FROM churn_labels as l 
    JOIN contracts AS c ON l.customer_id = c.customer_id
GROUP BY l.churned ORDER BY l.churned DESC; -- заросы на описательную статистику для числовых признаков