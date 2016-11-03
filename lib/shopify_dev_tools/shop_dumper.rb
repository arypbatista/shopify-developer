module ShopifyDevTools

  class ShopDumper

    def initialize options
      @options = options
      @dump_types = [:Shop, :Page, :Product]
    end

    def download_data types=@dump_types
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
        image_metafields[product.handle] = {}
        product.images.each do |image|
          if image.text_id
            image_metafields[product.handle][image.text_id] = image.metafields
          else
            raise "Image could not calcualte text_id for image: #{image.to_yaml}"
          end
        end
      end
      image_metafields
    end

    def download_metafields data, types=@dump_types
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
      data = self.download_data
      data[:Metafield] = self.download_metafields data
      self.write_data data, @options.file
    end

  end

end
