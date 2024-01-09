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

      def get_trade_info(body = "",url_params = "")
        url = "/api/v2/trade" + url_params
        rest_api(url, body, "get")
      end

      def trade_history(body)
        url = "/api/v2/tradehistory"
        rest_api(url, body, "post")
      end

      def create_trade(body)
        url = "/api/v2/trade"
        rest_api(url, body, "post")
      end

      def cancel_trade(id)
        url = "/api/v2/trade?trade.type=Cancel&trade.id=#{id}"
        rest_api(url, nil, "delete")
      end

      def assets
        url = "/api/v2/asset"
        rest_api(url, nil, "get")
      end

      def depth(symbol, depth)
        url = "/api/v2/level2/#{symbol.upcase}?depth=#{depth}"
        rest_api(url, nil, "get")
      end

      def quote_history(body = "", url_params = "", symbol, periodicity, type)
        url = "/api/v2/quotehistory/#{symbol.upcase}/#{periodicity}/bars/#{type}" + url_params
        rest_api(url, body, "get")
      end

      def get_http_hmac_header(req_type, url, body, timestamp)
        signature = timestamp + @web_api_id + @web_api_key + req_type.upcase + url + body
        digest = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), @web_api_secret, signature)
        hash_value = Base64.encode64(digest).chomp
        auth_value = "HMAC #{@web_api_id}:#{@web_api_key}:#{timestamp}:#{hash_value}"
        auth_value
      end

      def rest_api(url, body, req_type = 'post')
        timestamp = (Time.now.to_i * 1000).to_s
        body = body.present? ? JSON.generate(body) : ""
        full_url = @rest_api_url + url

        response = HTTParty.send(req_type.downcase.to_sym, full_url, headers: {
          'Accept' => 'application/json',
          'Content-type' => 'application/json',
          'Authorization' => get_http_hmac_header(req_type, full_url, body, timestamp )
        },body: body)

      rescue HTTParty::Error => _e
        puts "----Error----------Body:----#{response.inspect}"
        response
      rescue StandardError => e
        raise Error, e
      end

    end
  end
end
