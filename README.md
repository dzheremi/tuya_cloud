# TuyaCloud

TuyaCloud is a small Ruby gem to allow control of smart devices connected to the [Tuya Cloud](https://en.tuya.com/), without the need to flash custom firmware or discover device keys.

These devices are sold under many different brands internationally, and usually all have their own mobile apps (i.e. [Smart Life](https://play.google.com/store/apps/details?id=com.tuya.smartlife), [Tuya Smart](https://play.google.com/store/apps/details?id=com.tuya.smart) or [Genio](https://play.google.com/store/apps/details?id=com.mirabella.genio))

If you're app looks something like the images [here](https://iotrant.com/2019/06/07/smart-home-apps-volume-11-tuya-smart/), chances are this library will work for you.

This Ruby implementation was based on work by [PaulAnnekov](https://github.com/PaulAnnekov/tuyaha), using an endpoint specifically designed for [Home Assistant](https://www.home-assistant.io/).

The online devices which are supported at this stage are LED globes (white and colour) and mains switches, along with support for activating scenes you've created within the Tuya app.
  

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tuya_cloud'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tuya_cloud

## Usage

**Log into the Tuya Cloud:**
```ruby
api = TuyaCloud::API.new(username, password, country_code, brand)
``` 
`country_code` is the international dialing code for your country (i.e. 61 for Australia).<br>
`brand` is an underscored brand name of the app you're using (i.e. `smart_life` or `tuya`) - you may have to guess.

**Discover your devices:**
```ruby
api.find_device_by_name(name) # The name you've given your device in the Tuya app

api.find_device_by_id(id)     # The ID of the device available within the Tuya app

api.discover_devices          # Gets all of your devices
api.devices                   # An array of all of your devices

api.refresh_devices           # Refresh the states of all devices
```

**Device status:**
```ruby
light = api.find_device_by_name(name)

light.controls.state         # true / false for on or off
light.controls.online        # true / false

light.controls.brightness    # Current brightness setting (lights only)

light.controls.color_mode    # Current colour mode (RGB lights only)
light.controls.color         # Current colour setting (RGB lights only)
```

**Controlling lights and mains switches:**
```ruby
switch = api.find_device_by_name(name)

switch.controls.toggle       # Toggles on / off
switch.controls.turn_off     # Turns device off
switch.controls.turn_on      # Turns the device on
```

**Controlling light brightness:**
```ruby
light = api.find_device_by_name(name)

light.controls.set_brightness(25)  # Sets brightness to 25 - max value is 255
```

**Controlling colour lights:**
```ruby
rgb_light = api.find_device_by_name(name)

rgb_light.controls.set_white            # Sets the light to normal white mode
rgb_light.controls.set_color(r, g, b)   # Set the colour of the globe using RGB values
```

**Activating scenes:**
```ruby
scene = api.find_device_by_name(name)

scene.controls.activate
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dzheremi/tuya_cloud.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
