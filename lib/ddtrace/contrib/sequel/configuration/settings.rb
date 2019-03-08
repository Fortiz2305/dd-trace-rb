require 'ddtrace/contrib/configuration/settings'
require 'ddtrace/contrib/sequel/ext'

module Datadog
  module Contrib
    module Sequel
      module Configuration
        # Custom settings for the Sequel integration
        class Settings < Contrib::Configuration::Settings
          option  :analytics_enabled,
                  default: -> { env_to_bool(Ext::ENV_ANALYTICS_ENALBED, false) },
                  lazy: true

          option  :analytics_sample_rate,
                  default: -> { env_to_float(Ext::ENV_ANALYTICS_SAMPLE_RATE, 1.0) },
                  lazy: true
        end
      end
    end
  end
end
