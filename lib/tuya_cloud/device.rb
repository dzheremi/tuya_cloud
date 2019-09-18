# frozen_string_literal: true

module TuyaCloud
  class Device
    attr_accessor :id,
                  :name,
                  :type,
                  :controls

    def initialize(json, auth_context)
      self.id   = json['id']
      self.name = json['name']
      self.type = json['dev_type']
      case type
      when 'light'
        self.controls = if json['data'] && json['data']['color_mode']
                          ColorLight.new(json, auth_context)
                        else
                          Light.new(json, auth_context)
                        end
      when 'switch'
        self.controls = Switch.new(json, auth_context)
      when 'scene'
        self.controls = Scene.new(json, auth_context)
      else
        raise ArgumentError, 'unknown device type'

      end
    end

    class Control
      attr_accessor :id,
                    :auth_context

      def initialize(json, auth_context)
        self.id = json['id']
        self.auth_context = auth_context
      end

      def process_request(name, payload: {})
        auth_context.process_request(name, 'control',
                                     device_id: id,
                                     payload: payload)
      end
    end

    class Switchable < Control
      attr_accessor :online,
                    :state

      def initialize(json, auth_context)
        super(json, auth_context)
        self.online = json['data']['online'].to_s == 'true'
        self.state  = json['data']['state'].to_s == 'true'
      end

      def toggle
        process_request('turnOnOff', payload: { value: state ? 0 : 1 })
        self.state = !state
      end

      def turn_off
        process_request('turnOnOff', payload: { value: 0 })
        self.state = false
      end

      def turn_on
        process_request('turnOnOff', payload: { value: 1 })
        self.state = true
      end
    end

    class Light < Switchable
      attr_accessor :brightness

      def initialize(json, auth_context)
        super(json, auth_context)
        self.brightness = json['data']['brightness'].to_i
      end

      def set_brightness(value)
        raise ArgumentError unless value.is_a?(Integer)
        raise ArgumentError if value.negative? || value > 255

        process_request('brightnessSet', payload: { value: value })
        self.brightness = value
      end
    end

    class ColorLight < Light
      attr_accessor :color_mode,
                    :color

      def initialize(json, auth_context)
        super(json, auth_context)
        self.color_mode = json['data']['color_mode']
        self.color      = ColorSetting.new(json['data']['color'])
      end

      def set_white
        self.color_mode  = 'white'
        color.hue        = 0
        color.saturation = 0
        color.brightness = 100
        process_request('colorSet', payload: { color: color.to_h })
        color.to_h
      end

      def set_color(red, green, blue)
        raise ArgumentError unless red.is_a?(Integer) &&
                                   green.is_a?(Integer) &&
                                   blue.is_a?(Integer)
        raise ArgumentError if (red.negative? || red > 255) ||
                               (green.negative? || green > 255) ||
                               (blue.negative? || blue > 255)

        self.color_mode = 'colour'
        color.from_rgb(red, green, blue)
        process_request('colorSet', payload: { color: color.to_h })
        color.to_h
      end

      class ColorSetting
        attr_accessor :saturation,
                      :brightness,
                      :hue

        def initialize(json)
          self.saturation = json['saturation']
          self.brightness = json['brightness']
          self.hue        = json['hue']
        end

        def from_rgb(r, g, b)
          r /= 255.0
          g /= 255.0
          b /= 255.0
          max = [r, g, b].max
          min = [r, g, b].min
          delta = max - min
          v = max * 255
          s = 0.0
          s = delta / max * 255 if max != 0.0
          if s == 0.0
            h = 0.0
          else
            if r == max
              h = (g - b) / delta
            elsif g == max
              h = 2 + (b - r) / delta
            elsif b == max
              h = 4 + (r - g) / delta
            end
            h *= 60.0
            h += 360.0 if h.negative?
          end
          self.hue = h.round
          self.saturation = s.round
          self.brightness = v.round
        end

        def to_h
          { hue: hue,
            saturation: saturation,
            brightness: brightness }
        end
      end
    end

    class Switch < Switchable
    end

    class Scene < Control
      def activate
        process_request('turnOnOff', payload: { value: 1 })
        true
      end
    end
  end
end
