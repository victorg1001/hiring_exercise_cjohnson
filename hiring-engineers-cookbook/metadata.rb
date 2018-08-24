name 'hiring-engineers'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'All Rights Reserved'
description 'Installs/Configures hiring-engineers'
long_description 'Installs/Configures hiring-engineers'
version '0.1.0'
chef_version '>= 12.14' if respond_to?(:chef_version)

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/hiring-engineers/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/hiring-engineers'

depends 'datadog'
depends 'mysql', '~> 8.0'
depends 'mysql2_chef_gem'
depends 'database', '~> 6.1.1'
depends 'poise-python', '~> 1.7.0'

