# Warning to my picky self: order of requires matters because they define new tasks and
# affect order of task operation.
#$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"
set :rvm_ruby_string, "ruby-1.9.3-p362@sportspoo"
set :use_sudo, false

set :stages, %w(production)
set :default_stage, 'production'
require 'capistrano/ext/multistage'
default_run_options[:pty]   = true # must be set for the password prompt from git to work

set :keep_releases, 2

set :application, "sportspoo"
#set :repository,  "git@bitbucket.org:desmondy/sportspoo.git"
set :repository,  "git@github.com:netpenthe/sportspoo.git"

set :user, "deployguy"
default_run_options[:pty] = true
set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
set :branch, "master"
set :deploy_via, :remote_cache

set :deploy_to, "/var/www/sportspoo"
set :ruby_path, "/home/deployguy/.rvm/rubies/ruby-1.9.3-p362/bin/"
set :rvm_gemset_path, 'sportspoo'

require "rvm/capistrano"
require "bundler/capistrano"

role :web, "107.21.110.17"                          # Your HTTP server, Apache/etc
role :app, "107.21.110.17"                          # This may be the same as your `Web` server
role :db,  "107.21.110.17", :primary => true # This is where Rails migrations will run

after "deploy:update_code", "deploy:update_shared_symlinks"
require "bundler/capistrano"
after "bundle:install", "deploy:make_symlinks", "deploy:migrate", "deploy:assets"
namespace :deploy do
  task :start do ; end
  task :stop  do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "rm -rf #{current_path}/public/country/*"
    run "touch #{File.join(current_path, "tmp/restart.txt")}"
  end
  task :update_shared_symlinks do
    %w(config/database.yml).each do |path|
      run "rm -rf #{File.join(release_path, path)}"
      run "ln -s #{File.join(deploy_to, "shared", path)} #{File.join(release_path, path)}"
    end
  end
  task :make_symlinks do
      invoke_command "ln -sf #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
      invoke_command "ln -sf #{deploy_to}/shared/config/facebook.yml #{release_path}/config/facebook.yml"
      invoke_command "ln -sf #{deploy_to}/shared/config/twitter.yml #{release_path}/config/twitter.yml"
      invoke_command "ln -sf #{deploy_to}/shared/config/betfair.yml #{release_path}/config/betfair.yml"
      invoke_command "ln -sf #{deploy_to}/shared/config/keys #{release_path}/config/keys"
  end
end
namespace :deploy do
  task :assets do
    run "cd #{release_path} && bundle exec rake assets:precompile RAILS_ENV=#{rails_env}"
  end
end

# config/deploy/testing.rb
  set :deploy_to, "/home/user/rails/test/app-name"
  set :rails_env, :development
# config/deploy/staging.rb
  set :deploy_to, "/home/user/rails/staging/app-name"
  set :rails_env, :production
# config/deploy/production.rb
  set :deploy_to, "/home/user/rails/production/app-name"
  set :rails_env, :production
