DROP TABLE IF EXISTS customers, contracts, services, charges, churn_labels, splits, prod_stream;

CREATE TABLE customers (
    customer_id TEXT PRIMARY KEY,
    gender TEXT NOT NULL CHECK(gender IN ('Male', 'Female')),
    senior_citizen BOOLEAN NOT NULL,
    partner BOOLEAN NOT NULL,
    dependents BOOLEAN NOT NULL
);

CREATE TABLE contracts (
    customer_id TEXT PRIMARY KEY REFERENCES customers(customer_id),
    tenure INT NOT NULL CHECK(tenure >= 0),
    contract TEXT NOT NULL,
    paperless_billing BOOLEAN NOT NULL,
    payment_method TEXT NOT NULL
);

CREATE TABLE services(
    customer_id TEXT NOT NULL REFERENCES customers(customer_id),
    service_type TEXT NOT NULL,
    service_status TEXT NOT NULL,
    PRIMARY KEY (customer_id, service_type)
);

CREATE TABLE charges(
    customer_id TEXT PRIMARY KEY REFERENCES customers(customer_id),
    monthly_charges NUMERIC NOT NULL,
    total_charges NUMERIC NOT NULL
);

CREATE TABLE churn_labels(
    customer_id TEXT PRIMARY KEY REFERENCES customers(customer_id),
    churned BOOLEAN NOT NULL
);

CREATE TABLE splits(
    customer_id TEXT PRIMARY KEY REFERENCES customers(customer_id),
    split TEXT NOT NULL CHECK(split IN ('train', 'test', 'prod_stream'))
);

CREATE TABLE prod_stream(
    customer_id TEXT PRIMARY KEY REFERENCES customers(customer_id),
    batch_stream INT NOT NULL CHECK(batch_stream IN (1, 2))
);