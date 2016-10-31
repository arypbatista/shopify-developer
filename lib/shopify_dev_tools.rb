require 'shopify_api'
require 'shopify_dev_tools/extend_api'
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
      require 'activeresource'
      ActiveResource::Base.logger = Logger.new(STDERR)
      puts 'Config:', self.config.to_yaml
      puts 'Auth URL: ' + self.shop_auth_url
    end
  end

  def self.connect_shopify
    shop_url = self.shop_auth_url
    ShopifyAPI::Base.site = shop_url
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
    shop = ShopifyAPI::Shop.current
    data = YAML.load(File.read(options.file))

    id_replaces = {}

    load_order = [:Shop, :Metafield, :Page, :Product].select { |x| data.key? x }

    load_order.each do |type|

      if type == :Shop
        old_shop = data[type]
        id_replaces[old_shop.id] = shop.id

      else
        collection = data[type]
        collection.each do |object|

          if object.has_attribute? :owner_id and id_replaces.key? object.owner_id
            object.owner_id = id_replaces[object.owner_id]
          end

          old_id = object.id
          object.id = nil

          if type == :Metafield
            new_object = object
            new_object.owner_id = nil
            new_object.id = nil
            new_object.owner_resource = nil
          else
            new_object = object
          end


          begin
            new_object.save
            id_replaces[old_id] = new_object.id
          rescue => e
            puts "Error to save object #{type} with id #{old_id}."
            puts e.backtrace
          end
        end
      end
    end

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

  prepare
end
