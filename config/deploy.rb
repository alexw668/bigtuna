require "bundler/capistrano"

set :application, "bigtuna"
set :domain, "bigtuna.hsihealth.com"
set :repository, "git://github.com/alexw668/bigtuna.git"
set :use_sudo, false
set :deploy_to, "/var/www/#{application}"
set :scm, :git
set :user, "user_running_apps"

role :app, domain
role :web, domain
role :db, domain, :primary => true

namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  desc "Updates the symlink for config files to the just deployed release."
  task :symlink_configs do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/builds #{release_path}/builds"
    run "ln -nfs #{shared_path}/config/email.yml #{release_path}/config/email.yml"
    run "ln -nfs #{shared_path}/config/bigtuna.yml #{release_path}/config/bigtuna.yml"
  end

  task :bootstrap do
    run "cd #{release_path}; RAILS_ENV=production rake db:migrate"
    run "cd #{release_path}; RAILS_ENV=production ./script/delayed_job restart"
    # uncomment if you run BigTuna in BigTuna so that it gets build automatically
    # you will need to set up valid hook name in project config
    # run "curl --request POST --silent http://bigtuna.your.site/hooks/build/bigtuna"
  end
end

after "deploy:finalize_update", "deploy:symlink_configs"
before "deploy:restart", "deploy:bootstrap"
