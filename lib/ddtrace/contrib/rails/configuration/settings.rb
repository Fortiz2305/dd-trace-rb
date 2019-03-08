require 'ddtrace/contrib/configuration/settings'

module Datadog
  module Contrib
    module Rails
      module Configuration
        # Custom settings for the Rails integration
        class Settings < Contrib::Configuration::Settings
          option  :analytics_enabled,
                  default: -> { env_to_bool(Ext::ENV_ANALYTICS_ENALBED, false) },
                  lazy: true

          option  :analytics_sample_rate,
                  default: -> { env_to_float(Ext::ENV_ANALYTICS_SAMPLE_RATE, 1.0) },
                  lazy: true

          option :cache_service
          option :controller_service
          option :database_service, depends_on: [:service_name] do |value|
            value.tap do
              # Update ActiveRecord service name too
              Datadog.configuration[:active_record][:service_name] = value
            end
          end
          option :distributed_tracing, default: true
          option :exception_controller, default: nil
          option :middleware, default: true
          option :middleware_names, default: false
          option :template_base_path, default: 'views/'
        end
      end
    end
  end
end
