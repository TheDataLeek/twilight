set :application, 'Twilight'
set :repo_url, 'https://github.com/willzfarmer/twilight.git'
set :deploy_to, '/var/www/twilight'
set :scm, :git
set :branch, "master"
set :user, "william"
set :use_sudo, false
set :rails_env, "production"
set :deploy_via, :copy
set :keep_releases, 5

set :format, :pretty
set :log_level, :debug
set :pty, true

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# set :deploy_to, '/var/www/my_app'
# set :scm, :git

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
        #run "touch #{ current_path }/tmp/restart.txt"
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
       # within release_path do
       #   execute :rake, 'cache:clear'
       # end
    end
  end

  after :finishing, "deploy:restart"
  after :finishing, 'deploy:cleanup'

end
