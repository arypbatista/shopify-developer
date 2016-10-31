require 'shopify_api'

module ShopifyAPI
  class Base

    def copy_from(object, excluded_attributes=['id'])
      object.attributes.each do |attr_name, attr_value|
        if !excluded_attributes.include? attr_name
          puts 'Should copy ' + attr_name.to_s
        end
      end
      self
    end

  end

  class Metafield

    def full_name
      "#{@namespace}:#{@key}"
    end

  end
end
