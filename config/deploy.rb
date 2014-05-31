set :application, 'fbm'
set :user, 'deploy'

# setup repo details
set :scm, :git
set :repo_url, 'git://github.com/fueledbymarvin/fbm.git'

# setup rvm.
set :rvm1_ruby_version, 'ruby-2.1.1'

# how many old releases do we want to keep, not much
set :keep_releases, 5

# files we want symlinking to specific entries in shared
set :linked_files, %w{config/database.yml config/application.yml}

# dirs we want symlinking to shared
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# what specs should be run before deployment is allowed to
# continue, see lib/capistrano/tasks/run_tests.cap
set :tests, []

# which config files should be copied by deploy:setup_config
# see documentation in lib/capistrano/tasks/setup_config.cap
# for details of operations
set(:config_files, %w(
  nginx.conf
  database.yml
  application.yml
  puma_init.sh
  puma.rb
  monit
))

# which config files should be made executable after copying
# by deploy:setup_config
set(:executable_config_files, %w(
  puma_init.sh
))


# files which need to be symlinked to other parts of the
# filesystem. For example nginx virtualhosts, log rotation
# init scripts etc. 
set(:symlinks, [
  {
    source: "nginx.conf",
    link: "/etc/nginx/sites-enabled/#{fetch(:application)}"
  },
  {
    source: "puma_init.sh",
    link: "/etc/init.d/puma_#{fetch(:application)}"
  },
  {
    source: "monit",
    link: "/etc/monit/conf.d/#{fetch(:application)}.conf"
  }
])

# this:
# http://www.capistranorb.com/documentation/getting-started/flow/
# is worth reading for a quick overview of what tasks are called
# and when for `cap stage deploy`

namespace :deploy do
  # make sure we're deploying what we think we're deploying
  before :deploy, 'deploy:check_revision'

  # only allow a deploy with passing tests to deployed
  # before :deploy, 'deploy:run_tests'

  # remove the default nginx configuration as it will tend
  # to conflict with our configs.
  after 'deploy:check_revision', 'deploy:setup_config'
  before 'deploy:setup_config', 'nginx:remove_default_vhost'
  # reload nginx to it will pick up any modified vhosts from
  # setup_config
  after 'deploy:setup_config', 'nginx:reload'
  # Restart monit so it will pick up any monit configurations
  # we've added
  after 'deploy:setup_config', 'monit:restart'

  # As of Capistrano 3.1, the `deploy:restart` task is not called
  # automatically.
  after 'deploy:publishing', 'deploy:restart'

  after :finishing, 'deploy:cleanup'
end
