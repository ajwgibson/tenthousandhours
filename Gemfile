source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.6'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Authentication with Devise
gem 'devise'

# Authorisation with CanCanCan
gem 'cancancan'

# Some stuff from the theme
gem 'bootstrap-sass'
gem 'font-awesome-rails'

# Pagination
gem 'kaminari'

# Soft deletes
gem 'acts_as_paranoid', :github => 'ActsAsParanoid/acts_as_paranoid'

# Spreadsheet handling
gem 'roo'

# bootstrap form helpers
gem 'bootstrap_form'

# Kramdown for markdown display
gem 'kramdown'


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # RSpec etc
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rails-controller-testing'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Run specs automatically on file changes
  gem 'guard-rspec', require: false
end

group :test do
  gem 'database_cleaner'
  gem "capybara"
  gem "rake"
end

group :production do
  gem 'puma'
  gem 'rails_12factor'
end
