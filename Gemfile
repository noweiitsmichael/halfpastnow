source 'http://rubygems.org'

gem 'rails', '3.2.3'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem 'thin'
gem 'newrelic_rpm'
gem 'friendly_id'
gem 'tire'
# gem 'thinking-sphinx', '2.0.11'
# gem 'flying-sphinx',   '0.6.4'

gem 'admin_data', '>= 1.1.16'
gem "geocoder"
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.5'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier', '>= 1.0.3'
  gem 'jquery-datatables-rails'
end

#fancy jquery stuff
gem 'jquery-rails'
gem 'client_side_validations'
gem 'jcrop-rails'
gem 'htmlentities'
gem 'nokogiri', '>= 1.4.4'
gem 'sanitize'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
gem 'unicorn'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

#roles and login
gem 'devise'
gem 'cancan'
gem 'rolify'
gem 'omniauth-facebook'
gem 'koala'
gem 'sinatra'

#file attachments and Amazon S3
gem 'carrierwave'
gem 'rmagick'  # Khoa add Aug 26
gem 'fog'

group :test do
  # Pretty printed test output
  gem 'turn', '~> 0.8.3', :require => false
end

  # Testing/BDD
  gem "rspec-rails",:group => [:development, :test]
  gem "factory_girl_rails",:group => [:development, :test]
  gem "email_spec",:group => :test
  gem "cucumber-rails", :group => :test, :require => false
  gem "capybara",:git => 'git://github.com/jnicklas/capybara.git',:group => [:development, :test]
  gem "launchy", :group => :test
  gem "database_cleaner",:group => [:development, :test]


gem "ruby-prof", "~> 0.11.2"

gem 'mobile-fu'

gem 'delayed_job_active_record'

gem 'therubyracer'
gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'oink' #memory logging
# gem "librato-metrics" #logging/error reporting to Liberato add-on

# Data caching
gem 'memcachier'
gem 'dalli'

# Email via mandrill
gem 'mandrill-api'

# gem 'eventfulapi'
# gem 'eventbrite-client'

## From Procfile:
# web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
