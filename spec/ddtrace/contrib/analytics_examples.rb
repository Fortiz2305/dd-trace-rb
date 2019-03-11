require 'ddtrace/ext/analytics'

RSpec.shared_examples_for 'analytics for integration' do
  # Most integrations ignore the global flag by default,
  # because they aren't considered "key" integrations.
  # Key integrations will set this expectation to false.
  let(:ignore_global_flag) { true }

  context 'when not configured' do
    context 'and the global flag is not set' do
      it 'is not included in the tags' do
        expect(span.get_metric(Datadog::Ext::Analytics::TAG_SAMPLE_RATE)).to be nil
      end
    end

    context 'and the global flag is enabled' do
      around do |example|
        ClimateControl.modify(Datadog::Configuration::ENV_TRACE_ANALYTICS_ENABLED => 'true') do
          example.run
        end
      end

      it 'conditionally is included in the tags' do
        if ignore_global_flag
          expect(span.get_metric(Datadog::Ext::Analytics::TAG_SAMPLE_RATE)).to be nil
        else
          expect(span.get_metric(Datadog::Ext::Analytics::TAG_SAMPLE_RATE)).to eq(1.0)
        end
      end
    end

    context 'and the global flag is disabled' do
      around do |example|
        ClimateControl.modify(Datadog::Configuration::ENV_TRACE_ANALYTICS_ENABLED => 'false') do
          example.run
        end
      end

      it 'is not included in the tags' do
        expect(span.get_metric(Datadog::Ext::Analytics::TAG_SAMPLE_RATE)).to be nil
      end
    end
  end

  context 'when configured by environment variable' do
    context 'and explicitly enabled' do
      around do |example|
        ClimateControl.modify(analytics_enabled_var => 'true') do
          example.run
        end
      end

      shared_examples_for 'sample rate value' do
        context 'isn\'t set' do
          it { expect(span.get_metric(Datadog::Ext::Analytics::TAG_SAMPLE_RATE)).to eq(1.0) }
        end

        context 'is set' do
          let(:analytics_sample_rate) { 0.5 }
          around do |example|
            ClimateControl.modify(analytics_sample_rate_var => analytics_sample_rate.to_s) do
              example.run
            end
          end

          it { expect(span.get_metric(Datadog::Ext::Analytics::TAG_SAMPLE_RATE)).to eq(analytics_sample_rate) }
        end
      end

      context 'and global flag' do
        context 'is not set' do
          it_behaves_like 'sample rate value'
        end

        context 'is explicitly enabled' do
          around do |example|
            ClimateControl.modify(Datadog::Configuration::ENV_TRACE_ANALYTICS_ENABLED => 'true') do
              example.run
            end
          end

          it_behaves_like 'sample rate value'
        end

        context 'is explicitly disabled' do
          around do |example|
            ClimateControl.modify(Datadog::Configuration::ENV_TRACE_ANALYTICS_ENABLED => 'false') do
              example.run
            end
          end

          it_behaves_like 'sample rate value'
        end
      end
    end

    context 'and explicitly disabled' do
      around do |example|
        ClimateControl.modify(analytics_enabled_var => 'false') do
          example.run
        end
      end

      shared_examples_for 'sample rate value' do
        context 'isn\'t set' do
          it { expect(span.get_metric(Datadog::Ext::Analytics::TAG_SAMPLE_RATE)).to be nil }
        end

        context 'is set' do
          let(:analytics_sample_rate) { 0.5 }
          around do |example|
            ClimateControl.modify(analytics_sample_rate_var => analytics_sample_rate.to_s) do
              example.run
            end
          end

          it { expect(span.get_metric(Datadog::Ext::Analytics::TAG_SAMPLE_RATE)).to be nil }
        end
      end

      context 'and global flag' do
        context 'is not set' do
          it_behaves_like 'sample rate value'
        end

        context 'is explicitly enabled' do
          around do |example|
            ClimateControl.modify(Datadog::Configuration::ENV_TRACE_ANALYTICS_ENABLED => 'true') do
              example.run
            end
          end

          it_behaves_like 'sample rate value'
        end

        context 'is explicitly disabled' do
          around do |example|
            ClimateControl.modify(Datadog::Configuration::ENV_TRACE_ANALYTICS_ENABLED => 'false') do
              example.run
            end
          end

          it_behaves_like 'sample rate value'
        end
      end
    end
  end

  context 'when configured by configuration options' do
    context 'and explicitly enabled' do
      let(:configuration_options) { super().merge(analytics_enabled: true) }

      shared_examples_for 'sample rate value' do
        context 'isn\'t set' do
          it { expect(span.get_metric(Datadog::Ext::Analytics::TAG_SAMPLE_RATE)).to eq(1.0) }
        end

        context 'is set' do
          let(:configuration_options) { super().merge(analytics_sample_rate: analytics_sample_rate) }
          let(:analytics_sample_rate) { 0.5 }
          it { expect(span.get_metric(Datadog::Ext::Analytics::TAG_SAMPLE_RATE)).to eq(analytics_sample_rate) }
        end
      end

      context 'and global flag' do
        context 'is not set' do
          it_behaves_like 'sample rate value'
        end

        context 'is explicitly enabled' do
          around do |example|
            Datadog.configuration.analytics_enabled = Datadog.configuration.analytics_enabled.tap do
              Datadog.configuration.analytics_enabled = true
              example.run
            end
          end

          it_behaves_like 'sample rate value'
        end

        context 'is explicitly disabled' do
          around do |example|
            Datadog.configuration.analytics_enabled = Datadog.configuration.analytics_enabled.tap do
              Datadog.configuration.analytics_enabled = false
              example.run
            end
          end

          it_behaves_like 'sample rate value'
        end
      end
    end

    context 'and explicitly disabled' do
      let(:configuration_options) { super().merge(analytics_enabled: false) }

      shared_examples_for 'sample rate value' do
        context 'isn\'t set' do
          it { expect(span.get_metric(Datadog::Ext::Analytics::TAG_SAMPLE_RATE)).to be nil }
        end

        context 'is set' do
          let(:configuration_options) { super().merge(analytics_sample_rate: analytics_sample_rate) }
          let(:analytics_sample_rate) { 0.5 }
          it { expect(span.get_metric(Datadog::Ext::Analytics::TAG_SAMPLE_RATE)).to be nil }
        end
      end

      context 'and global flag' do
        context 'is not set' do
          it_behaves_like 'sample rate value'
        end

        context 'is explicitly enabled' do
          around do |example|
            Datadog.configuration.analytics_enabled = Datadog.configuration.analytics_enabled.tap do
              Datadog.configuration.analytics_enabled = true
              example.run
            end
          end

          it_behaves_like 'sample rate value'
        end

        context 'is explicitly disabled' do
          around do |example|
            Datadog.configuration.analytics_enabled = Datadog.configuration.analytics_enabled.tap do
              Datadog.configuration.analytics_enabled = false
              example.run
            end
          end

          it_behaves_like 'sample rate value'
        end
      end
    end
  end
end
