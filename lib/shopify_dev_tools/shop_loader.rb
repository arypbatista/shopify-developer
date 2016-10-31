module ShopifyDevTools

  class ShopLoader

    def initialize
      @shop = ShopifyAPI::Shop.current
      @id_replacements = {}

    end

    def load_metafields item, type, old_id, data
      if data[:Metafield][type].key? old_id
        metafields = data[:Metafield][type][old_id]

        metafields.each do |metafield|
          new_metafield = ShopifyAPI::Metafield.new
          new_metafield.namespace = metafield.namespace
          new_metafield.key = metafield.key
          new_metafield.value = metafield.value
          new_metafield.value_type = metafield.value_type
          begin
            item.add_metafield(new_metafield)
          rescue => e
            puts "Error to save object metafield #{type} with id #{metafield.id} (object: #{old_id})."
            puts e.backtrace
          end
        end
      end
    end

    def load_item item, type, data
      if type == :Shop
        @id_replacements[item.id] = @shop.id
      else
        old_id = item.id
        item.id = nil

        begin
          item.save
          @id_replacements[old_id] = item.id
          self.load_metafields item, type, old_id, data
        rescue => e
          puts "Error to save object #{type} with id #{old_id}."
          puts e.backtrace
        end
      end
    end

    def load_data data

      load_order = [:Shop, :Page, :Product]
        .select { |x| data.key? x }

      load_order.each do |type|

        if data[type].kind_of? ActiveResource::Collection
          data[type].each do |item|
            self.load_item item, type, data
          end
        else
          self.load_item data[type], type, data
        end

      end

    end

  end

end
