--
-- Name: books; Type: TABLE; Schema: -; Owner: -
--

CREATE TABLE IF NOT EXISTS books (
    id SERIAL,
    title varchar(255),
    attr hstore,
    CONSTRAINT books_pkey PRIMARY KEY (id)
);
