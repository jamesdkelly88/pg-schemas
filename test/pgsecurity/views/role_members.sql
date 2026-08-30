--
-- Name: role_members; Type: VIEW; Schema: -; Owner: -
--

CREATE OR REPLACE VIEW role_members AS
  SELECT 
    m.rolname AS member_name,
    r.rolname AS role_name,
    am.admin_option AS with_admin,
    am.inherit_option AS with_inherit,
    am.set_option AS with_set,
    g.rolname AS grantor
  FROM pg_catalog.pg_auth_members am
    INNER JOIN pg_catalog.pg_roles r ON am.roleid = r.oid
    INNER JOIN pg_catalog.pg_roles m ON am.member = m.oid
    INNER JOIN pg_catalog.pg_roles g ON am.grantor = g.oid
  UNION
  SELECT
    r.rolname,
    'pg_database_owner',
    false,
    true,
    false,
    NULL
	FROM pg_catalog.pg_database d
	  INNER JOIN pg_catalog.pg_roles r ON d.datdba = r.oid
	WHERE d.datname = current_database();