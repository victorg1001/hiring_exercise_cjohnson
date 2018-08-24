#
# Cookbook:: hiring-engineers
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

### Set Variables

# Datadog variables
node.default['datadog']['api_key'] = ''
node.default['datadog']['application_key'] = ''
node.default['datadog']['min_collection_interval'] = 45

# Mysql variables
# This is lazy secrets management. Don't be like me when you grow up.
# You just know someone's going to put this into prod without reading the code.
# This is set as a standard ruby variable so nobody accidentally saves it back to the node object.
dd_insecure_root_db_password = 'deeply_insecure'

### Main Loop
# 1. Install the datadog agent
# 2. Install mysql
# 3. Configure mysql
# 4. Setup DataDog to collect metrics from this mysql instance

# Install datadog agent & various supporting libraries
include_recipe 'datadog::dd-agent'
include_recipe 'datadog::dd-handler'

# Get the DataDog API client installed
package 'python-pip'
python_package 'datadog'
python_package 'flask'
python_package 'ddtrace'
python_package 'blinker'

# install mysql
mysql_service 'test_db' do
  port '3306'
  version '5.7'
  initial_root_password dd_insecure_root_db_password
  action [:create, :start]
end

# Setup Datadog agent to monitor mysql
node.default['datadog']['mysql']['instances'] = [
  {
    'server' => 'localhost',
    'port' => 3306,
    'user' => 'root',
    'pass' => dd_insecure_root_db_password,
    'sock' => '/var/run/mysql-test_db/mysqld.sock',
    'tags' => ['prod'],
    'options' => [
      'replication: 0',
      'galera_cluster: 1'
    ],
    'queries' => [
      {
        'type' => 'gauge',
        'field' => 'users_count',
        'metric' => 'my_app.my_users.count',
        'query' => 'SELECT COUNT(1) AS users_count FROM users',
      },
    ]
  }
]

datadog_monitor 'mysql' do
  instances node['datadog']['mysql']['instances']
  logs node['datadog']['mysql']['logs']
end

# Set up custom agent check
template '/etc/dd-agent/conf.d/my_metric.yaml' do
  source 'my_metric.yaml.erb'
  owner 'dd-agent'
  group 'dd-agent'
  mode '0644'
  action :create
  notifies :restart, 'service[datadog-agent]'
end

cookbook_file '/etc/dd-agent/checks.d/my_metric.py' do
  source 'my_metric.py'
  owner 'dd-agent'
  group 'dd-agent'
  mode '0644'
  action :create
  notifies :restart, 'service[datadog-agent]'
end

service 'datadog-agent' do
  action :nothing
end

# Set up the flask app
directory '/opt/flask_app' do
  owner 'dd-agent'
  group 'dd-agent'
  mode '0755'
  action :create
end

cookbook_file '/opt/flask_app/apm_flask.py' do
  source 'apm_flask.py'
  owner 'dd-agent'
  group 'dd-agent'
  mode '0755'
  action :create
end
