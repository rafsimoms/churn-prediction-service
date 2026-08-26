SELECT COUNT(*) FROM customers; -- count 7043
SELECT COUNT(*) FROM contracts; -- count 7043
SELECT COUNT(*) FROM services; -- count 7043 * 9 = 63387
SELECT COUNT(*) FROM charges; -- count 7043
SELECT COUNT(*) FROM churn_labels; -- count 7043
SELECT COUNT(*) FROM splits; -- count 7043
SELECT COUNT(*) FROM prod_stream; -- count 1057

SELECT split, COUNT(*) FROM splits GROUP BY split; -- train 4930 - test 1056 - prod_stream 1057


SELECT AVG(churned::int) FROM churn_labels; -- avg 0.26536987079369586824 - доля таргета

SELECT COUNT(*) 
FROM charges 
    JOIN contracts ON charges.customer_id = contracts.customer_id 
WHERE contracts.tenure = 0; /* count 11 - строки где tenure = 0, у которых total_charges = ' ', 
которое я при создании бд решил заменить на 0 */

SELECT COUNT(*) 
FROM charges 
    JOIN contracts ON charges.customer_id = contracts.customer_id 
WHERE contracts.tenure = 0 AND charges.total_charges = 0; -- соответственно предыдущему запросу возвращает 11

SELECT c.gender, AVG(churned::int) AS churn_rate, COUNT(*) AS n_customers, 
COUNT(*)::numeric / (SELECT COUNT(*) FROM customers JOIN splits USING(customer_id) WHERE split = 'train') AS group_share 
FROM customers AS c 
    JOIN churn_labels ON c.customer_id = churn_labels.customer_id
    JOIN splits AS s ON s.customer_id = c.customer_id
WHERE s.split = 'train'
GROUP BY c.gender 
ORDER BY churn_rate DESC; -- запросы на долю таргета в группах для категориальных признаков, для остальных групп все в 01_eda.ipynb

SELECT s.service_type, s.service_status, AVG(churned::int) as churn_rate, COUNT(*) AS n_customers, 
COUNT(*)::numeric / (SELECT COUNT(*) FROM customers JOIN splits USING(customer_id) WHERE split = 'train') AS group_shape
FROM services AS s 
    JOIN churn_labels ON s.customer_id = churn_labels.customer_id
    JOIN splits ON splits.customer_id = s.customer_id
WHERE splits.split = 'train'
GROUP BY s.service_type, s.service_status
ORDER BY churn_rate DESC; -- один запрос сразу показывает распределение для всех услуг

SELECT l.churned, COUNT(*) AS n, MIN(c.tenure) AS min, 
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY c.tenure) AS q25,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY c.tenure) AS med, 
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY c.tenure) AS q75,
MAX(c.tenure) AS max, AVG(tenure) AS mean 
FROM churn_labels as l 
    JOIN contracts AS c ON l.customer_id = c.customer_id
    JOIN splits AS s ON s.customer_id = c.customer_id
WHERE s.split = 'train'
GROUP BY l.churned ORDER BY l.churned DESC; -- заросы на описательную статистику для числовых признаков

SELECT CASE
WHEN tenure <= 6 THEN '0-6'
WHEN tenure <= 12 THEN '07-12'
WHEN tenure <= 18 THEN '13-18'
WHEN tenure <= 24 THEN '19-24'
ELSE '25+' END AS tenure_bucket,
co.contract, AVG(l.churned::int) AS churn_rate, COUNT(*) AS n
FROM contracts AS co 
    JOIN churn_labels AS l ON l.customer_id = co.customer_id
    JOIN splits AS s ON s.customer_id = co.customer_id
WHERE s.split = 'train'
GROUP BY 1, 2; -- пример запроса с бакетами для хитмапа между признаками

SELECT co.contract, co.paperless_billing, AVG(l.churned::int) as churn_rate, COUNT(*) AS n
FROM contracts AS co 
    JOIN churn_labels AS l ON co.customer_id = l.customer_id
    JOIN splits AS s ON s.customer_id = co.customer_id
WHERE s.split = 'train'
GROUP BY co.contract, co.paperless_billing; -- пример без бакетов