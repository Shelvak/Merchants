# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "merchants"
set :repo_url,  "https://github.com/Shelvak/Merchants"
set :deploy_to, '/var/rails/merchants'
set :deploy_via, :remote_cache
set :branch, 'master'

set :ssh_options, {
  forward_agent: true,
  # verbose: :debug
}

set :log_level, :debug

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
