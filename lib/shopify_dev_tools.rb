require 'shopify_api'
require 'yaml'

module ShopifyDevTools

  def self.test?
    ENV['test']
  end

  def self.debug?
    ENV['debug']
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
    "https://#{@config[:api_key]}:#{@config[:password]}@#{@config[:store]}/admin"
  end

  def self.prepare
    self.config
    self.connect_shopify

    if self.debug?
      puts 'Config:', self.config.to_yaml
      puts 'Auth URL: ' + self.shop_auth_url
    end
  end

  def self.connect_shopify
    shop_url = self.shop_auth_url
    ShopifyAPI::Base.site = shop_url
    ShopifyAPI
  end

  def self.load options
    data = YAML.load(File.read(options.file))
    data.each do |type, objects|
      objects.first.save
      #objects.each { |o| o.save }
    end

  end

  def self.dump options
    data = {
      :Page => ShopifyAPI::Page.find(:all)
    }

    if options.file
      File.write options.file, data.to_yaml
    else
      puts data.to_yaml
    end
  end

  prepare
end
