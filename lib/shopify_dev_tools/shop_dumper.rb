module ShopifyDevTools

  class ShopDumper

    def initialize options
      @options = options
    end

    def download_data types
      data = {}
      types.each do |type|
        if type == :Shop
          data[type] = ShopifyAPI::Shop.current
        else
          data[type] = ShopifyDevTools.get_type(type).find(:all)
        end
      end
      data
    end

    def download_metafields_for_item item, type, data
      item.metafields
    end

    def download_metafields_for_type type, data
      type_metafields = {}

      if data[type].kind_of? ActiveResource::Collection
        data[type].each do |item|
          item_metafields = self.download_metafields_for_item item, type, data
          type_metafields[item.id] = item_metafields
        end
      else
        item = data[type]
        item_metafields = self.download_metafields_for_item item, type, data
        type_metafields[item.id] = item_metafields
      end

      type_metafields
    end

    def download_product_image_metafields data
      image_metafields = {}
      data[:Product].each do |product|
        product.images.each do |image|
          image_metafields[image.id] = ShopifyAPI::Metafield.find(:all,
            :params => {
                :metafield => {
                  :owner_id => image.id,
                  :owner_resource => 'product_image'
                }
              })
        end
      end
      image_metafields
    end

    def download_metafields types, data
      all_metafields = {}
      types.each do |type|
        all_metafields[type] = self.download_metafields_for_type type, data
        if type == :Product
          all_metafields[:Image] = self.download_product_image_metafields data
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
      dump_types = [:Shop, :Page, :Product]
      data = self.download_data dump_types
      data[:Metafield] = self.download_metafields dump_types, data
      self.write_data data, @options.file
    end

  end

end
