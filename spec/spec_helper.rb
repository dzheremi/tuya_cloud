require "bundler/setup"
require "tuya_cloud"
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)
RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Stubbed remote API endpoints
  config.before(:each) do
    # Good Login
    stub_request(:post, /auth.do/)
      .with(body: /test.local/)
      .to_return(status: 200, body: {
        access_token: 'XXXXXXXXXXXXXXX',
        refresh_token: 'XXXXXXXXXXXXXXX',
        expires_in: (60 * 60)
      }.to_json)
    # Bad Login
    stub_request(:post, /auth.do/)
      .with(body: /bad.local/)
      .to_return(status: 401)
    # Valid Token Refresh
    stub_request(:get, /refresh_token=XXXXXXXXXXXXXXX/)
      .to_return(status: 200, body: {
        access_token: 'ZZZZZZZZZZZZZZ',
        refresh_token: 'ZZZZZZZZZZZZZZ',
        expires_in: (60 * 60)
      }.to_json)
    # Invalid Token Refresh
    stub_request(:get, /refresh_token=ZZZZZZZZZZZZZZ/)
      .to_return(status: 401)
    # Device Discover
    stub_request(:post, /skill/)
      .with(body: /discovery/)
      .to_return(status: 200, body: {
        header: { code: 'SUCCESS' },
        payload: {
          devices: [
            { id: '123456789',
              name: 'Test Light',
              dev_type: 'light',
              data: {
                state: true,
                online: true,
                brightness: 255
              }
            }
          ]
        }
      }.to_json)
    # Turn Off and On
    stub_request(:post, /skill/)
      .with(body: /turnOnOff/)
      .to_return(status: 200, body: { header: { code: 'SUCCESS' } }.to_json)
    # Set Brightness
    stub_request(:post, /skill/)
      .with(body: /brightnessSet/)
      .to_return(status: 200, body: { header: { code: 'SUCCESS' } }.to_json)
    # Set Color
    stub_request(:post, /skill/)
      .with(body: /colorSet/)
      .to_return(status: 200, body: { header: { code: 'SUCCESS' } }.to_json)
  end
end
