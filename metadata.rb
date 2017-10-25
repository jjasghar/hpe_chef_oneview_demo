name 'hpe_oneview_chef_demo'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'All Rights Reserved'
description 'Installs/configures hpe_chef_oneview_demo'
long_description 'Installs/configures hpe_chef_oneview_demo'
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)
depends 'oneview', '~> 3.0.0'
