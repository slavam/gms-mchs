# source 'https://rubygems.org'
source 'http://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'
# gem 'rails', '4.2.6'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

gem "audited", "~> 4.5"

gem 'bootstrap-sass', '3.3.6'

gem 'will_paginate',           '3.1.0'
gem 'bootstrap-will_paginate', '0.0.10'

gem 'browserify-rails', '1.5.0'

gem 'descriptive_statistics', '~> 2.4.0', :require => 'descriptive_statistics/safe'

gem 'carrierwave',             '1.1.0'
gem 'mini_magick',             '4.7.0'
gem 'fog',                     '1.40.0'
gem 'rmagick'

# Use sqlite3 as the database for Active Record
# gem 'sqlite3'
gem 'haml'
gem 'mysql2', '~> 0.3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'react-rails', '~> 1.0'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', '~> 0.4.0', group: :doc

# gem 'chartjs-ror'

gem 'prawn-rails'
gem 'prawn-table', :git => 'https://github.com/straydogstudio/prawn-table.git', ref: '759a27b6'

# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

gem 'puma'

gem 'execjs'
gem 'therubyracer', :platforms => :ruby

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# source "http://rails-assets.org" do
source "https://rails-assets.org" do
  gem 'rails-assets-react-date-picker'
  gem "rails-assets-moment"
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  
  gem 'capistrano', '~> 3.7', '>= 3.7.1'
  gem 'capistrano-rails', '~> 1.2'
  # gem 'capistrano-passenger', '~> 0.2.0'
  gem 'capistrano3-puma'
  
  # Add this if you're using rbenv
  gem 'capistrano-rbenv', '~> 2.1'

end

