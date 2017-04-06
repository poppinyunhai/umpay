require 'openssl'
require 'base64'
require 'open-uri'
require 'erb'
require 'faraday'


module Umpay
  class Utils
    class << self
      def rsa_sign(data, key)
        data = params_to_sorted_string(data)
        rkey = OpenSSL::PKey::RSA.new key
        sign = rkey.sign('sha1',data.force_encoding("utf-8"))
        signature = Base64.encode64(sign)
        signature.gsub!("\n",'')
      end
      
      def rsa_encrypt(data, key) 
        key = OpenSSL::X509::Certificate.new key
        rkey = OpenSSL::PKey::RSA.new(key.public_key)
        result = Base64.encode64(rkey.public_encrypt data.encode('gbk'))
        result.gsub!("\n",'')
      end

      def params_to_sorted_string(params)
        params.sort.map { |key, value| %Q(#{key}=#{value.to_s}) }.join('&')
      end      
      
      def generate_url(url, params)
        url + params_to_sorted_string(params)
      end
    end
  end
end