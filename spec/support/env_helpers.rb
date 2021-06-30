module EnvHelpers
  def with_modified_env(options, &block)
    ClimateControl.modify(options, &block)
  end
end

RSpec.configure { |config| config.include(EnvHelpers) }
