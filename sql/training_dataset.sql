WITH service_features AS (
    SELECT 
        customer_id,
        MAX(CASE WHEN service_type = 'internet' THEN service_status END) AS internet,
        MAX(CASE WHEN service_type = 'online_security' THEN service_status END) AS online_security,
        MAX(CASE WHEN service_type = 'tech_support' THEN service_status END) AS tech_support,
        MAX(CASE WHEN service_type = 'online_backup' THEN service_status END) AS online_backup,
        MAX(CASE WHEN service_type = 'device_protection' THEN service_status END) AS device_protection,
        MAX(CASE WHEN service_type = 'streaming_movies' THEN service_status END) AS streaming_movies,
        MAX(CASE WHEN service_type = 'streaming_tv' THEN service_status END) AS streaming_tv,
        MAX(CASE WHEN service_type = 'multiple_lines' THEN service_status END) AS multiple_lines,
        MAX(CASE WHEN service_type = 'phone' THEN service_status END) AS phone
    FROM services JOIN splits USING(customer_id)
    WHERE splits.split = 'train'
    GROUP BY customer_id
),
base AS (
    SELECT * FROM customers AS c
        JOIN contracts AS co USING(customer_id)
        JOIN charges AS ch USING(customer_id)
        JOIN churn_labels AS cl USING(customer_id)
        JOIN splits AS s USING(customer_id)
    WHERE s.split = 'train' AND co.tenure != 0
)
SELECT 
    b.customer_id,
    b.gender,
    b.senior_citizen,
    b.partner,
    b.dependents,
    b.tenure,
    b.contract,
    b.paperless_billing,
    b.payment_method,
    b.monthly_charges,
    b.total_charges,
    s.internet,
    s.online_security,
    s.tech_support,
    s.online_backup,
    s.device_protection,
    s.streaming_movies,
    s.streaming_tv,
    s.multiple_lines,
    s.phone,
    b.churned
FROM base AS b JOIN service_features AS s ON s.customer_id = b.customer_id;
  