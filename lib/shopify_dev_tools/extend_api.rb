require 'active_resource_throttle'
require 'shopify_api'
require 'shopify_api/metafields'

module ShopifyAPI

  module Metafields
    def add_metafields metafields
      metafields.each { |m| self.add_metafield m }
    end
  end

  class Base < ActiveResource::Base
    include ActiveResourceThrottle
    throttle(:interval => 1, :requests => 2)

    def copy_to other, ignore_attributes=[:id]
      other.copy_from self, ignore_attributes
      self
    end

    def copy_from other, ignore_attributes=[:id]
      other.attributes.each do |attr_name, attr_value|
        if !ignore_attributes.include? attr_name.to_sym
          self.send("#{attr_name}=", attr_value)
        end
      end
      self
    end
  end

  class Metafield
    def full_name
      self.text_id
    end

    def text_id
      "#{@namespace}:#{@key}"
    end
  end

  class Image

    def text_id
      if self.src
        self.src.split('/').last.split('?').first
      else
        nil
      end
    end

    def metafields
      ShopifyAPI::Metafield.find(:all,
        :params => {
            :metafield => {
              :owner_id => self.id,
              :owner_resource => 'product_image'
            }
          })
    end

    def add_metafields metafields
      self.write_attribute(:metafields, metafields)
      self.save
    end

  end
end
