RSpec.describe TuyaCloud do
  describe TuyaCloud::API do
    let(:connection) {
      TuyaCloud::API.new(
        'test@test.local',
        'test',
        '61',
        'smart_life'
      )
    }
    let(:bad_user) {
      TuyaCloud::API.new(
        'test@bad.local',
        'test',
        '61',
        'smart_life'
      )
    }

    describe 'initialization' do
      it 'initializes and logs into the tuya cloud with valid user' do
        expect(connection.auth.access_token).to match /XXXXXXXXXXXXXXX/
      end
      it 'raises error with invalid user' do
        expect { bad_user }.to raise_error TuyaCloud::Error
      end
    end

    describe 'authorization' do
      it 'refreshes access token with the refresh token' do
        connection.auth.refresh_access_token
        expect(connection.auth.access_token).to match /ZZZZZZZZZZZZZZ/
      end
      it 'raises error if cannot refresh access token' do
        connection.auth.refresh_access_token
        expect { connection.auth.refresh_access_token }.to raise_error TuyaCloud::Error
      end
    end

    describe 'device discovery' do
      it 'discovers devices from the tuya cloud' do
        expect(connection.discover_devices.first).to be_a TuyaCloud::Device
      end
      it 'can find devices by a name' do
        expect(connection.find_device_by_name('Test Light')).to be_a TuyaCloud::Device
      end
      it 'can find devices by an id' do
        expect(connection.find_device_by_id('123456789')).to be_a TuyaCloud::Device
      end
    end
  end

  describe TuyaCloud::Device do
    let(:auth_context) {
      context = TuyaCloud::API::Auth.new(
        'test@test.local',
        'test',
        '61',
        'smart_life',
        'us'
      )
      context.access_token = 'XXXXXXXXXXXXXXXXXXX'
      context.refresh_token = 'XXXXXXXXXXXXXXXXXXX'
      context.expire_time = Time.now + (60 * 60)
      context
    }
    let(:light_device) {
      { 'id'       => '123456789',
        'name'     => 'Test Light',
        'dev_type' => 'light',
        'data'     => {
          'online'     => true,
          'state'      => true,
          'brightness' => 255
        }
      }
    }
    let(:color_light_device) {
      { 'id'       => '123456789',
        'name'     => 'Test Color Light',
        'dev_type' => 'light',
        'data' => {
          'online'     => true,
          'state'      => true,
          'brightness' => 255,
          'color_mode' => 'white',
          'color' => {
            'hue'        => 0,
            'saturation' => 0,
            'brightness' => 100
          }
        }
      }
    }
    let(:switch_device) {
      { 'id'       => '123456789',
        'name'     => 'Test Switch',
        'dev_type' => 'switch',
        'data' => {
          'online' => true,
          'state'  => true
        }
      }
    }
    let(:scene) {
      { 'id'       => '123456789',
        'name'     => 'Test Scene',
        'dev_type' => 'scene',
        'data' => {}
      }
    }
    let(:unknown) {
      { 'id'       => '123456789',
        'name'     => 'Unknown Device',
        'dev_type' => 'unknown',
        'data'     => {}
      }
    }
    let(:tuya_switch) { TuyaCloud::Device.new(switch_device, auth_context) }
    let(:tuya_light) { TuyaCloud::Device.new(light_device, auth_context) }
    let(:tuya_color_light) { TuyaCloud::Device.new(color_light_device, auth_context) }
    let(:tuya_scene) { TuyaCloud::Device.new(scene, auth_context) }

    describe 'initialization' do
      it 'initializes a light as a light' do
        device = TuyaCloud::Device.new(light_device, auth_context)
        expect(device.controls).to be_a TuyaCloud::Device::Light
      end
      it 'initializes a colored light as a colored light' do
        device = TuyaCloud::Device.new(color_light_device, auth_context)
        expect(device.controls).to be_a TuyaCloud::Device::ColorLight
      end
      it 'initializes a switch as a switch' do
        device = TuyaCloud::Device.new(switch_device, auth_context)
        expect(device.controls).to be_a TuyaCloud::Device::Switch
      end
      it 'initializes a scene as a scene' do
        device = TuyaCloud::Device.new(scene, auth_context)
        expect(device.controls).to be_a TuyaCloud::Device::Scene
      end
      it 'raises an error if the device type is unknown' do
        expect{ TuyaCloud::Device.new(unknown, auth_context) }.to raise_error ArgumentError
      end
    end

    describe 'controls' do
      describe 'switchables' do
        it 'can toggle devices on and off' do
          tuya_switch.controls.toggle
          expect(tuya_switch.controls.state).to be false
        end
        it 'can switch devices on' do
          tuya_switch.controls.toggle
          tuya_switch.controls.turn_on
          expect(tuya_switch.controls.state).to be true
        end
        it 'can switch devices off' do
          tuya_switch.controls.turn_off
          expect(tuya_switch.controls.state).to be false
        end
      end

      describe 'lights' do
        it 'can set the brightness of lights' do
          tuya_light.controls.set_brightness(25)
          expect(tuya_light.controls.brightness).to eq 25
        end
        it 'raises an argument error if the brightness value is too high' do
          expect { tuya_light.controls.set_brightness(256) }.to raise_error ArgumentError
        end
        it 'raises an argument error if the brightness value is negative' do
          expect { tuya_light.controls.set_brightness(-1) }.to raise_error ArgumentError
        end
      end

      describe 'color lights' do
        it 'can set the normal white mode' do
          tuya_color_light.controls.set_color(255, 0, 0)
          tuya_color_light.controls.set_white
          expect(tuya_color_light.controls.color.hue).to eq 0
          expect(tuya_color_light.controls.color.saturation).to eq 0
          expect(tuya_color_light.controls.color.brightness).to eq 100
        end
        it 'can set the color of a light using rgb values' do
          tuya_color_light.controls.set_color(255, 0, 0)
          expect(tuya_color_light.controls.color.hue).to eq 0
          expect(tuya_color_light.controls.color.saturation).to eq 255
          expect(tuya_color_light.controls.color.brightness).to eq 255
        end
        it 'raises an argument error with red value which is too high' do
          expect { tuya_color_light.controls.set_color(256, 0, 0) }.to raise_error(ArgumentError)
        end
        it 'raises an argument error with green value which is too high' do
          expect { tuya_color_light.controls.set_color(0, 256, 0) }.to raise_error(ArgumentError)
        end
        it 'raises an argument error with blue value which is too high' do
          expect { tuya_color_light.controls.set_color(0, 0, 256) }.to raise_error(ArgumentError)
        end
        it 'raises an argument error with red value which is negative' do
          expect { tuya_color_light.controls.set_color(-1, 0, 0) }.to raise_error(ArgumentError)
        end
        it 'raises an argument error with green value which is negative' do
          expect { tuya_color_light.controls.set_color(0, -1, 0) }.to raise_error(ArgumentError)
        end
        it 'raises an argument error with blue value which is negative' do
          expect { tuya_color_light.controls.set_color(0, 0, -1) }.to raise_error(ArgumentError)
        end
      end

      describe 'scenes' do
        it 'can activate a scene' do
          expect(tuya_scene.controls.activate).to be true
        end
      end
    end
  end
end
