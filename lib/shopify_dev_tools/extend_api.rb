require 'active_resource_throttle'
require 'shopify_api'
require 'shopify_api/metafields'

module ShopifyAPI
  class Base < ActiveResource::Base
    include ActiveResourceThrottle
    throttle(:interval => 1, :requests => 2)
  end

  class Metafield
    def full_name
      "#{@namespace}:#{@key}"
    end
  end

  class Image
    include Metafields
  end
end
