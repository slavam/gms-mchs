Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  # config.action_mailer.raise_delivery_errors = false
  # config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # config.action_mailer.perform_caching = false
  
  # mwm
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = {
  #   address:              '10.105.24.5',
  #   port:                 25,
  #   domain:               'localhost',
  #   user_name:            '<username>',
  #   password:             '<password>',
  #   authentication:       'plain',
  #   enable_starttls_auto: true  }  
  
  # ActionMailer Config
# config.action_mailer.default_url_options = { host: 'gmc-test-slavam1.c9users.io', protocol: 'https'  }
# config.action_mailer.default_url_options = { host: 'gidromet.mchs' } #, protocol: 'https'  }
# config.action_mailer.delivery_method = :sendmail
config.action_mailer.delivery_method = :smtp
# change to true to allow email to be sent during development
config.action_mailer.perform_deliveries = true # false # 
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default :charset => "utf-8"
  
  config.action_mailer.smtp_settings = {
    # address:              'gidromet.mchs',
    address:              'smtp.gmail.com',
    # address:              '10.105.0.7',
    port:                   587,
    # port:                 25, #2587,
    domain:               'localhost', #'gidromet.mchs', #
    # user_name:            ENV["GMAIL_USERNAME"],
    # password:             ENV["GMAIL_PASSWORD"],
    # user_name:            'morgachev@gidromet.mchs',
    # password:             'F,jhlf;82',
    user_name:            'mwm1955@gmail.com',
    password:             '',
    authentication:       'login',
    enable_starttls_auto: true  
  }
  

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
end
