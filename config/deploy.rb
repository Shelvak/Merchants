require 'bundler/capistrano'

set :application, "merchants"
set :repository,  "https://github.com/Shelvak/Merchants"
# set :deploy_to, '/home/rotsen/ruby/www/merchant/'
set :deploy_to, '/var/rails/merchants'
set :scm, :git
# set :port, 26
set :user, 'eltonel'
# set :user, 'rotsen'
set :deploy_via, :remote_cache
set :use_sudo, false

set :branch, 'master'
role :web, "190.15.212.171"                          # Your HTTP server, Apache/etc
role :app, "190.15.212.171"                          # This may be the same as your `Web` server
role :db,  "190.15.212.171", :primary => true
# role :web, "rotsenweb.no-ip.org"                          # Your HTTP server, Apache/etc
# role :app, "rotsenweb.no-ip.org"                          # This may be the same as your `Web` server
# role :db,  "rotsenweb.no-ip.org", :primary => true

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  # desc "reload the database with seed data"
	task :seed do
		run "cd #{current_path}; rake db:seed RAILS_ENV=#{rails_env}"
	end

end
