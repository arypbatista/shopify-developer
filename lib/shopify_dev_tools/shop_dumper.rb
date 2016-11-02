module ShopifyDevTools

  class ShopDumper

    def initialize options
      @options = options
    end

    def download_data
      {
        :Shop => ShopifyAPI::Shop.current,
        :Page => ShopifyAPI::Page.find(:all),
        :Product => ShopifyAPI::Product.find(:all)
      }
    end

    def download_metafields data
      all_metafields = {}
      [:Shop, :Page, :Product].each do |type|
        all_metafields[type] = {}

        metafields = all_metafields[type]

        if data[type].kind_of? ActiveResource::Collection
          data[type].each do |item|
            metafields[item.id] = item.metafields
          end
        else
          item = data[type]
          metafields[item.id] = item.metafields
        end
      end
      all_metafields
    end

    def write_data data, filepath=nil
      if filepath
        File.write filepath, data.to_yaml
      else
        puts data.to_yaml
      end
    end

    def dump
      data = self.download_data
      data[:Metafield] = self.download_metafields data
      self.write_data data, @options.file
    end

  end

end
