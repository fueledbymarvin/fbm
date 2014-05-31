set :stage, :production
set :branch, "master"

# This is used in the Nginx VirtualHost to specify which domains
# the app should appear on. If you don't yet have DNS setup, you'll
# need to create entries in your local Hosts file for testing.
set :server_name, "www.fueledbymarv.in fueledbymarv.in"

keys = []
if File.exist?('config/deploy_id_rsa')
  keys << 'config/deploy_id_rsa'
end

server '107.170.182.106', user: 'deploy', roles: %w{web app db}, primary: true, ssh_options: { keys: keys }

set :deploy_to, "/home/#{fetch(:user)}/apps/#{fetch(:application)}"

# dont try and infer something as important as environment from
# stage name.
set :rails_env, :production

# number of puma workers, this will be reflected in
# the puma.rb and the monit configs
set :puma_worker_count, 2

# whether we're using ssl or not, used for building nginx
# config file
set :enable_ssl, false
