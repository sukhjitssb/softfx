# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'openssl'
require 'json'

module Peatio
  module Softfx
    class Client
      Error = Class.new(StandardError)

      class ConnectionError < Error; end

      class ResponseError < Error
        def initialize(code, msg)
          super "#{msg} (#{code})"
        end
      end

      extend Memoist

      def initialize(endpoint, creds, idle_timeout: 25)
        creds = creds.with_indifferent_access rescue {}
        @rest_api_url = endpoint
        @rest_api_endpoint = URI.parse(endpoint)
        @web_api_id = creds.dig("web_api_id")
        @web_api_key = creds.dig("web_api_key")
        @web_api_secret = creds.dig("web_api_secret")
        @idle_timeout = idle_timeout
      end

      def get_trade_info(body = "",url_params)
        url = "/api/v2/trade" + url_params
        method = "get"
        response = rest_api(url, body, method)
        response
      end

      def create_trade(body)
        url = "/api/v2/trade"
        method = "post"
        response = rest_api(url, body, method)
        response
      end

      def cancel_trade(id)
        url = "/api/v2/trade?trade.type=Cancel&trade.id=#{id}"
        method = "delete"
        response = rest_api(url, nil, method)
        response
      end

      def get_http_hmac_header(method, url, body, timestamp)
        signature = timestamp + @web_api_id + @web_api_key + method.upcase + url + body
        digest = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), @web_api_secret, signature)
        hash_value = Base64.encode64(digest).chomp
        auth_value = "HMAC #{@web_api_id}:#{@web_api_key}:#{timestamp}:#{hash_value}"
        auth_value
      end

      def rest_api(url, body, method = 'post')
        timestamp = (Time.now.to_i * 1000).to_s
        body = body.present? ? JSON.generate(body) : ""
        full_url = @rest_api_url + url

        response = connection.send(method.downcase) do |req|
          req.headers['Accept'] = 'application/json'
          req.headers['Content-type'] = 'application/json'
          req.headers['Authorization'] = get_http_hmac_header(method, full_url, body, timestamp )
          req.url full_url
          req.body = body if body.present?
        end
        response.assert_success!
        response
      rescue Faraday::Error => _e
        puts "----Response-----Client---------#{response.body.inspect}"
        # raise ConnectionError, response.body
        response
      rescue StandardError => e
        raise Error, e
      end

      private

      def connection
        @connection ||= Faraday.new(@rest_api_endpoint) do |f|
          f.adapter :net_http_persistent, pool_size: 5, idle_timeout: @idle_timeout
        end
      end
    end
  end
end
