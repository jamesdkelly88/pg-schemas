--
-- Name: customers; Type: TABLE; Schema: -; Owner: -
--

CREATE TABLE IF NOT EXISTS customers (
    customer_id integer,
    customer_name varchar(100),
    country varchar(100),
    CONSTRAINT customers_pkey PRIMARY KEY (customer_id)
);
