# config valid only for current version of Capistrano
lock "3.8.0"

set :application, "magento2"
set :repo_url, "git@github.com:dhduc/magento2.shopui.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/magento2"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"
set :linked_files, [
  'app/etc/env.php',
  'pub/.htaccess',
  'auth.json'
]

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
set :linked_dirs, [
  'pub/media',
  'var/backups',
  'var/composer_home',
  'var/file_cache',
  'var/importexport',
  'var/import_history',
  'var/log',
  'var/report',
  'var/session',
  'var/tmp'
]

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :magento_deploy_setup_role, :main
set :magento_deploy_cache_shared, true
set :magento_deploy_languages, ['en_US']
set :magento_deploy_themes, []
set :magento_deploy_composer, true
set :magento_deploy_production, true
set :magento_deploy_maintenance, true
set :magento_deploy_confirm, []
set :magento_deploy_chmod_d, '0755'
set :magento_deploy_chmod_f, '0644'
set :magento_deploy_chmod_x, ['bin/magento']

set :file_permissions_roles, :all
set :file_permissions_paths, ["pub/static", "var"]
set :file_permissions_users, ["user"]
set :file_permissions_groups, ["group"]
set :file_permissions_chmod_mode, "0777"

# set :config_files, %w{app/etc/env.php pub/.htaccess auth.json}
set :config_files, %w{app/etc/env.php pub/.htaccess auth.json}

after 'deploy:symlink:linked_dirs', 'composer:global:install:prestissimo' do
  on release_roles :all do
    within release_path do
      execute :composer, :global, :config, 'http-basic.repo.magento.com', 'MAGENTO_USERNAME', 'MAGENTO_PASSWORD'
      execute :composer, :global, :require, 'hirak/prestissimo:^0.3'
    end
  end
end

before 'deploy:check:linked_files', 'config:push'
after 'magento:setup:static-content:deploy', 'magento2:add_adminer'
# before 'magento:deploy:verify', 'magento2:copy_config'
before "deploy:updated", "deploy:set_permissions:acl"
before 'magento:setup:permissions', 'magento2:copy_htaccess'
