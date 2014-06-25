gitlab-postgres-user:
  postgres_user.present:
    - name: git
    - password: {{ salt['pillar.get']('gitlab:db_password') }}
    - createdb: True
    - db_host: {{ salt['mine.get']('roles:db', 'network.ip_addrs', expr_form='grain').items()[0][1][0] }}
    - db_user: {{ salt['pillar.get']('postgres:user') }}
    - db_password: {{ salt['pillar.get']('postgres:pass') }}
    - db_port: {{ salt['pillar.get']('postgres:port') }}
