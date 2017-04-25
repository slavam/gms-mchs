# config valid only for current version of Capistrano
lock "3.8.0"
set :repo_url, "https://github.com/slavam/gms-mchs.git"
set :application, "gms-mchs"
# set :repo_url, "git@github.com:slavam/gms-mchs.git"
set :user, 'proger'
# set :use_sudo, false
# set :location, "sysad-lin.com"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/proger/gms-mchs"
# set :ssh_options, {forward_agent: true, auth_methods: %w(publickey)}
set :ssh_options, {
  forward_agent: true
#  port: 3456
}

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"
append :linked_files, "config/database.yml", "config/secrets.yml"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "vendor/bundle", "public/system", "public/uploads"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5
set :rbenv_path, '/home/proger/.rbenv'