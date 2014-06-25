include:
  - nginx

/etc/nginx/sites-enabled/default:
  file.absent:
    - require_in:
      - service: nginx

nginx_conf:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://gitlab/files/nginx.conf
    - template: jinja
    - watch_in:
      - service: nginx

/etc/nginx/sites-available/gitlab:
  file.managed:
    - source: salt://gitlab/files/gitlab_nginx_conf
    - template: jinja
    - watch_in:
      - service: nginx

/etc/nginx/sites-enabled/gitlab:
  file.symlink:
    - target: /etc/nginx/sites-available/gitlab
    - require:
      - file: /etc/nginx/sites-available/gitlab
    - watch_in:
      - service: nginx
