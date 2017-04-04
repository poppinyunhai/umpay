require 'nokogiri'

module Umpay
  class Service
    def initialize(options={})
      @private_key = File.read(options[:private_key])
      @public_key  = File.read(options[:public_key])
      @url = "http://pay.soopay.net/spay/pay/payservice.do?"
    end
    
    def get_balance(params)
      params = {
                 charset: "UTF-8",
                 res_format: "HTML",
                 service: 'query_account_balance',
                 version: '4.0',
                 sign_type: 'RSA'
               }.merge(params)
      sign_and_request(params)
    end
    
    def create_by_payment(params)
      params[:recv_account] = Umpay::Utils.rsa_encrypt(params[:recv_account], @public_key)
      params[:recv_user_name] = Umpay::Utils.rsa_encrypt(params[:recv_user_name], @public_key)
      # params[:notify_url] = ERB::Util.url_encode(params[:notify_url])
      # params[:purpose] = ERB::Util.url_encode(params[:purpose])
      # params[:bank_brhname] = ERB::Util.url_encode(params[:bank_brhname])
      params[:service] = 'transfer_direct_req'
      params.merge!(default_params)
      sign_and_request(params)
    end
    
    def order_query(params)
      params[:service] = 'transfer_query'
      params.merge!(default_params)
      sign_and_request(params)
    end
    
    def sign_and_request(params)
      sorted_params = Umpay::Utils.params_to_sorted_string(params)
      signature = Umpay::Utils.rsa_sign(params, @private_key)
      url_params = sorted_params + "&sign=#{ERB::Util.url_encode(signature)}"
      doc = Nokogiri::HTML(Faraday.get("#{@url + url_params}").body)
      item_to_hash(doc.at('meta').attributes["content"].value)
    end
    
    def item_to_hash(item)
      hash = Hash.new
      
      item.split("&").each do |e|
        key = e.match("^[^=]*(?==)").to_s
        value = e.match("(?<==)[^;]*").to_s
        hash[key] = value
      end
      return hash
    end
    
    def default_params
      { charset: "UTF-8", res_format: "HTML", version: '4.0', sign_type: 'RSA' }
    end
  end
end