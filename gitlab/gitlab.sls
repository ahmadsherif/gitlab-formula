clone-gitlab-repo:
  git.latest:
    - name: https://github.com/ahmadsherif/gitlabhq.git
    - rev: {{ salt['pillar.get']('gitlab:rev', '6-8-stable') }}
    - target: /home/git/gitlab
    - user: git

{% for config_file in ['config/gitlab.yml', 'config/unicorn.rb', 'config/initializers/rack_attack.rb'] %}
/home/git/gitlab/{{ config_file }}:
  file.managed:
    - source: salt://gitlab/files/{{ config_file.split('/')[-1] }}
    - template: jinja
    - user: git
    - require:
      - git: clone-gitlab-repo
{% endfor %}

{% for directory in ['log/', 'tmp/', 'tmp/pids/', 'tmp/sockets/', 'public/uploads'] %}
/home/git/gitlab/{{ directory }}:
  file.directory:
    - user: git
    - mode: 700
    - makedirs: True
    - recurse:
        - user
        - mode
    - require:
      - git: clone-gitlab-repo
{% endfor %}

mkdir gitlab-satellites:
  cmd.run:
    - cwd: /home/git/gitlab
    - user: git
    - unless: test -d gitlab-satellites
    - require:
      - git: clone-gitlab-repo

/home/git/gitlab/config/database.yml:
  file.managed:
    - source: salt://gitlab/files/database.yml
    - template: jinja
    - user: git
    - mode: 600
    - require:
      - git: clone-gitlab-repo

/home/git/gitlab/config/resque.yml:
  file.managed:
    - source: salt://gitlab/files/resque.yml
    - template: jinja
    - user: git
    - mode: 600
    - require:
      - git: clone-gitlab-repo

install-gems:
  cmd.run:
    - name: bundle install --deployment --without development test mysql aws
    - cwd: /home/git/gitlab
    - user: git
    - require:
      - git: clone-gitlab-repo

setup_gitlab:
  cmd.run:
    - name: bundle exec rake db:create && bundle exec rake db:migrate && bundle exec rake db:seed_fu
    - cwd: /home/git/gitlab
    - env:
      - RAILS_ENV: production
    - user: git
    - require:
      - cmd: install-gems

/etc/init.d/gitlab:
  file.managed:
    - source: salt://gitlab/files/gitlab_init
    - template: jinja
    - mode: 0755
    - require:
      - git: clone-gitlab-repo

enable_gitlab_service:
  service.running:
    - name: gitlab
    - enable: True
    - require:
      - file: /etc/init.d/gitlab

/etc/logrotate.d/gitlab:
  file.managed:
    - source: salt://gitlab/files/gitlab_logrotate
    - require:
      - git: clone-gitlab-repo

bundle exec rake assets:precompile RAILS_ENV=production:
  cmd.run:
    - cwd: /home/git/gitlab
    - user: git
    - require:
      - cmd: setup_gitlab
