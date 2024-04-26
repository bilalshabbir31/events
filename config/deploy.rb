# frozen_string_literal: true

require 'mina/rails'
require 'mina/git'
require 'mina/rvm'

set :application_name, 'event'
set :domain, '54.235.223.50'
set :deploy_to, '/home/ubuntu/event.com'
set :repository, 'git@github.com:bilalshabbir31/events.git'
set :branch, 'task/Deploy-App'

# Optional settings:
set :user, 'ubuntu' # Username in the server to SSH to.
set :port, '22' # SSH port number.
set :forward_agent, true # SSH forward_agent.

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

task :remote_environment do
  invoke :'rvm:use', 'ruby-3.3.0@default'
  invoke 'nvm:load'
end

desc 'Deploys the current version to the server.'
task :deploy do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        invoke :'rvm:use', 'ruby-3.3.0@default'
        command %(echo "-----> Restarting event Application...")
        command %(sudo systemctl restart event)
        # command %(#{fetch(:bundle_prefix)} pumactl start)
      end
    end
  end
end
