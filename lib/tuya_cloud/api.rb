# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'time'

module TuyaCloud
  class API
    CLOUD_URL = 'https://px1.tuya%.com'
    DEFAULT_REGION = 'us'
    attr_accessor :auth,
                  :devices

    def initialize(username, password, country_code, brand, region = DEFAULT_REGION)
      self.auth = Auth.new(username, password, country_code, brand, region)
      auth.login
      self.devices = []
    end

    def discover_devices
      request = auth.process_request('Discovery', 'discovery')
      return nil unless request &&
                        request['devices'] &&
                        request['devices'].is_a?(Array)

      self.devices = []
      request['devices'].each do |device|
        devices << Device.new(device, auth)
      end
      devices
    end

    def refresh_devices
      discover_devices
    end

    def find_device_by_id(id)
      discover_devices if devices.size.zero?
      devices.each { |device| return device if device.id == id }
      nil
    end

    def find_device_by_name(name)
      discover_devices if devices.size.zero?
      devices.each { |device| return device if device.name == name }
      nil
    end

    class Auth
      attr_accessor :username,
                    :password,
                    :country_code,
                    :brand,
                    :access_token,
                    :refresh_token,
                    :expire_time,
                    :region

      def initialize(username, password, country_code, brand, region)
        raise ArgumentError unless username.is_a?(String) &&
                                   password.is_a?(String) &&
                                   country_code.is_a?(String) &&
                                   brand.is_a?(String) &&
                                   region.is_a?(String)

        self.username     = username
        self.password     = password
        self.country_code = country_code
        self.brand        = brand
        self.region       = region
      end

      def cloud_url
        CLOUD_URL.gsub('%', region)
      end

      def login
        uri = URI.parse("#{cloud_url}/homeassistant/auth.do")
        response = Net::HTTP.post_form(uri,
                                       userName: username,
                                       password: password,
                                       countryCode: country_code,
                                       bizType: brand,
                                       from: 'tuya')
        unless response.is_a?(Net::HTTPOK)
          raise Error,
                'invalid HTTP response from Tuya Cloud whilst trying to '\
              'get access token'
        end

        json = JSON.parse(response.body)
        process_auth_response(json)
      end

      def refresh_access_token
        uri = URI.parse("#{cloud_url}/homeassistant/access.do?grant_type=refresh_token&"\
                    "refresh_token=#{refresh_token}")
        response = Net::HTTP.get uri
        unless response.is_a?(String) && !response.empty?
          raise Error, 'failed to refresh access token'
        end

        json = JSON.parse(response)
        process_auth_response(json)
      end

      def token_expired?
        Time.now > expire_time
      end

      def process_auth_response(json)
        unless json['access_token'] &&
               json['refresh_token'] &&
               json['expires_in']
          raise Error,
                'invalid JSON response from Tuya Cloud whilst trying to '\
              'get access token'
        end

        self.access_token = json['access_token']
        self.refresh_token = json['refresh_token']
        self.expire_time = Time.now + json['expires_in'].to_i
        true
      end

      def process_request(name, namespace, device_id: nil, payload: {})
        raise ArgumentError unless name.is_a?(String) &&
                                   namespace.is_a?(String)

        header = {
          name: name,
          namespace: namespace,
          payloadVersion: 1
        }
        payload[:accessToken] = access_token
        payload[:devId] = device_id unless namespace == 'discovery'
        data = {
          header: header,
          payload: payload
        }
        uri = URI.parse("#{cloud_url}/homeassistant/skill")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri,
                                      'Content-Type' => 'application/json')
        request.body = data.to_json
        response = http.request(request)
        unless response.is_a?(Net::HTTPOK)
          raise Error,
                'request was not processed by Tuya Cloud'
        end

        json = JSON.parse(response.body)
        unless json['header']['code'] == 'SUCCESS'
          raise Error,
                'request was not processed by Tuya Cloud'
        end

        json['payload']
      end
    end
  end
end
