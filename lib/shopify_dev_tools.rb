require 'shopify_api'
require 'shopify_dev_tools/config'
require 'shopify_dev_tools/extend_api'
require 'shopify_dev_tools/item_types'
require 'shopify_dev_tools/shop_loader'
require 'yaml'

module ShopifyDevTools

  @@log = Logger.new(STDOUT)
  @@env = :development
  @@config_format = :themekit

  def self.debug message
    if self.debug?
      @@log.debug message
    end
  end

  def self.test?
    ENV['test']
  end

  def self.debug?
    ENV['debug']
  end

  def self.config
    @config ||= if File.exist? 'config.yml'
      config = Config.new 'config.yml', @@config_format, @@env
    else
      puts "config.yml does not exist!" unless test?
      {}
    end
  end

  def self.config=(config)
    @config = config
  end

  def self.prepare options
    @@config_format = options.config_format
    @@env = options.env
    self.config
    self.connect_shopify

    if self.debug?
      require 'activeresource'
      ActiveResource::Base.logger = Logger.new(STDERR)
      puts 'Config:', self.config.to_yaml
      puts 'Auth URL: ' + @config.auth_url
    end
  end

  def self.connect_shopify
    ShopifyAPI::Base.site = @config.auth_url
    ShopifyAPI
  end

  def self.clear_shop options
    delete_order = [ShopifyAPI::Metafield, ShopifyAPI::Page, ShopifyAPI::Product]

    delete_order.each do |collection|
      collection.find(:all).each do |item|
        collection.delete item.id
      end
    end
  end

  def self.load options
    loader = ShopLoader.new options
    loader.load_data YAML.load(File.read(options.file))
  end

  def self.dump options

    data = {
      :Shop => ShopifyAPI::Shop.current,
      :Page => ShopifyAPI::Page.find(:all),
      :Product => ShopifyAPI::Product.find(:all),
      :Metafield => {}
    }

    [:Shop, :Page, :Product].each do |type|
      data[:Metafield][type] = {}

      metafields = data[:Metafield][type]

      if data[type].kind_of? ActiveResource::Collection
        data[type].each do |item|
          metafields[item.id] = item.metafields
        end
      else
        item = data[type]
        metafields[item.id] = item.metafields
      end
    end

    if options.file
      File.write options.file, data.to_yaml
    else
      puts data.to_yaml
    end
  end

end
