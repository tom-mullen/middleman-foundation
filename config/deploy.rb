set :application, 'my-wu-rewards'
set :use_sudo, false
set :build_dir, 'build'
set :build_archive, "#{fetch(:application)}.zip"
set :use_sudo, false
set :ssh_options, {
  forward_agent: true,
  port: 8000
}

set :deploy_to, "/var/www/apps/#{fetch(:application)}"

namespace :middleman do
  desc "Build and deploy middleman project"
  task :deploy do
    invoke 'middleman:build'
    invoke 'middleman:deploy_to_remote'
  end

  desc "Run build utility"
  task :build do
    run_locally do
     execute "middleman build"
     execute "zip -r #{fetch(:build_archive)} #{fetch(:build_dir)}"
    end
  end

  desc "Deploy to VPS"
  task :deploy_to_remote do
    on roles(:web) do
      upload! fetch(:build_archive), "#{fetch(:deploy_to)}"
      cmd = "cd #{fetch(:deploy_to)} && rm -fr current/*"
      cmd += " && unzip #{fetch(:build_archive)} && cp -fr #{fetch(:build_dir)}/* current/"
      execute cmd
    end
  end

  task :cleanup do
    on roles(:web) do
      execute "cd #{fetch(:deploy_to)} && rm -fr #{fetch(:build_dir)} && rm #{fetch(:build_archive)}"
    end
    run_locally do
      execute "rm #{fetch(:build_archive)}"
    end
  end
end

after 'middleman:deploy', 'middleman:cleanup'