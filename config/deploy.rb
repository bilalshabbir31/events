# frozen_string_literal: true

require 'mina/rails'
require 'mina/git'
require 'mina/rvm'    # for rvm support. (https://rvm.io)
# require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)
set :application_name, 'event'
set :domain, '54.235.223.50'
set :deploy_to, '/home/ubuntu/event.com'
set :repository, 'git@github.com:bilalshabbir31/events.git'
set :branch, 'task/Deploy-App'

# Optional settings:
set :user, 'ubuntu' # Username in the server to SSH to.
set :port, '22' # SSH port number.
set :forward_agent, true # SSH forward_agent.

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
set :shared_dirs, fetch(:shared_dirs, []).push('tmp/pids', 'tmp/sockets', 'tmp/pdfs', 'node_modules')
set :shared_files, fetch(:shared_files, []).push('.env', 'config/database.yml')

namespace :nvm do
  task :load do
    comment 'Loading nvm...'
    command %(
      source ~/.nvm/nvm.sh
    )
    comment 'Now using nvm v.`nvm --version`'
  end
end

namespace :yarn do
  task :install do
    comment 'Installing node packages with yarn...'
    command %(yarn install --check-files)
  end

  task :compile_release do
    command %(npm run release)
  end
end

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use', 'ruby-3.3.0@default'
  invoke 'nvm:load'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
# task :setup do
#   # command %{rbenv install 2.5.3 --skip-existing}
#   # command %{rvm install ruby-2.5.3}
#   # command %{gem install bundler}
# end

desc 'Deploys the current version to the server.'
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %(mkdir -p tmp/)
        command %(touch tmp/restart.txt)
        invoke :'rvm:use', 'ruby-3.3.0@default'
        command %(echo "-----> Restarting event Application...")
        command %(sudo systemctl restart event)
        # command %(#{fetch(:bundle_prefix)} pumactl start)
      end
    end
  end

  # you can use `run :local` to run tasks on local machine before or after the deploy scripts
  # run(:local){ say 'done' }
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
