require 'shopify_api'
require 'yaml'

module ShopifyDevTools

  def self.test?
    ENV['test']
  end

  def self.config
    @config ||= if File.exist? 'config.yml'
      config = YAML.load(File.read('config.yml'))

      if !config[:store].end_with?('.myshopify.com')
        config[:store] = config[:store] + '.myshopify.com'
      end

      config
    else
      puts "config.yml does not exist!" unless test?
      {}
    end
  end

  def self.config=(config)
    @config = config
  end

  def self.shop_auth_url
    "https://#{@config[:api_key]}:#{@config[:password]}@#{:store}/admin"
  end

  def self.connect_shopify
    self.config
    shop_url = self.shop_auth_url
    ShopifyAPI::Base.site = shop_url
    ShopifyAPI
    puts "ShopifyAPI prepared"
  end

  def self.load
    self.connect_shopify
    puts "load"
    puts ShopifyAPI::Product.find(:all, :params => {:limit => 10})
  end

  def self.dump
    puts "dump"
  end

end
