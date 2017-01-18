require 'shopify_api'
require 'shopify_dev_tools/config'
require 'shopify_dev_tools/extend_api'
require 'shopify_dev_tools/item_types'
require 'shopify_dev_tools/shop_loader'
require 'shopify_dev_tools/shop_dumper'
require 'yaml'

module ShopifyDevTools

  @@log = Logger.new(STDOUT)
  @@env = nil
  @@config_format = nil
  @@config_path = nil

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
    if self.debug?
      puts "Config file set to '#{@@config_path}'."
    end

    @config ||= if File.exist? @@config_path
      config = Config.new @@config_path, @@config_format, @@env
    else
      puts "Configuration file '#{@@config_path}' does not exist!" unless test?
      {}
    end
  end

  def self.config=(config)
    @config = config
  end

  def self.prepare options
    @@config_format = options.config_format
    @@config_path = options.config
    @@env = options.env
    self.config
    self.connect_shopify

    if options.verbose
      require 'activeresource'
      ActiveResource::Base.logger = Logger.new(STDERR)
    end

    if self.debug?
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
    if @config.readonly
      raise 'Environment is readonly. Loading action aborted.'
    else
      loader = ShopLoader.new options
      loader.load_data YAML.load(File.read(options.file))
    end
  end

  def self.dump options
    dumper = ShopDumper.new options
    dumper.dump
  end

end
