required-packages:
  pkg.installed:
    - pkgs:
      - git-core
      - build-essential
      - zlib1g-dev
      - libyaml-dev
      - libssl-dev
      - libgdbm-dev
      - libreadline-dev
      - libncurses5-dev
      - libffi-dev
      - curl
      - openssh-server
      - checkinstall
      - libxml2-dev
      - libxslt1-dev
      - libcurl4-openssl-dev
      - libicu-dev
      - logrotate
      - postgresql-server-dev-9.3
      - postgresql-client-9.3
      - redis-tools
      - python-pip
    - refresh: True

docutils:
  pip.installed:
    - require:
      - pkg: required-packages
