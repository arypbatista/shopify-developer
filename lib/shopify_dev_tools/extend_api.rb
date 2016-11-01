require 'active_resource_throttle'
require 'shopify_api'

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
end
