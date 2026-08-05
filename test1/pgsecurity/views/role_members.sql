--
-- Name: role_members; Type: VIEW; Schema: -; Owner: -
--

CREATE OR REPLACE VIEW role_members AS
 SELECT m.rolname AS member_name,
    r.rolname AS role_name,
    am.admin_option AS with_admin,
    am.inherit_option AS with_inherit,
    am.set_option AS with_set,
    g.rolname AS grantor
   FROM pg_auth_members am
     JOIN pg_roles r ON am.roleid = r.oid
     JOIN pg_roles m ON am.member = m.oid
     JOIN pg_roles g ON am.grantor = g.oid;
