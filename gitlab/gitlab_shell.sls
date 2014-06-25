include:
  - gitlab.users

clone-gitlab-shell:
  cmd.run:
    - name: git clone https://gitlab.com/gitlab-org/gitlab-shell.git -b v1.8.0
    - unless: test -d /home/git/gitlab-shell
    - cwd: /home/git
    - user: git
    - require:
      - sls: gitlab.users

gitlab-shell-config:
  file.managed:
    - name: /home/git/gitlab-shell/config.yml
    - source: salt://gitlab/files/gitlab_shell_config.yml
    - template: jinja
    - user: git
    - require:
      - cmd: clone-gitlab-shell

setup-gitlab-shell:
  cmd.run:
    - name: ./bin/install
    - cwd: /home/git/gitlab-shell
    - unless: test -d /home/git/repositories # TODO: Can we do better?
    - user: git
    - require:
      - file: gitlab-shell-config
