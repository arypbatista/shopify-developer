module ShopifyDevTools

  class ShopLoader

    def initialize options
      @shop = ShopifyAPI::Shop.current
      @id_replacements = {}
      @options = options

    end

    def load_metafields item, type, old_id, data
      if data.key? :Metafield and
         data[:Metafield].key? type and
         data[:Metafield][type].key? old_id

        new_metafields = data[:Metafield][type][old_id]

        old_metafields = item.metafields

        old_metafields_hash = old_metafields
          .map { |m| ["#{m.namespace}:#{m.key}", m] }
          .to_h

        new_metafields.each do |new_metafield|

          metafield = old_metafields_hash.fetch new_metafield.full_name, false
          if !metafield
            metafield = ShopifyAPI::Metafield.new
          end

          metafield.namespace = new_metafield.namespace
          metafield.key = new_metafield.key
          metafield.value = new_metafield.value
          metafield.value_type = new_metafield.value_type
          begin
            item.add_metafield(metafield)
          rescue => e
            puts "Error to save object metafield #{type} with id #{new_metafield.id} (object: #{old_id})."
            puts e.backtrace
          end
        end

      end
    end

    def load_item data_item, type, data
      if type == :Shop
        @id_replacements[data_item.id] = @shop.id
        self.load_metafields @shop, type, data_item.id, data
      else

        old_id = data_item.id

        item = ShopifyDevTools::get_type(type).find(:all, :params => { :handle => data_item.handle }).first
        if !item and !@options.update_only
          item = ShopifyDevTools::get_type(type).new
        end

        if item
          data_item.attributes.each do |attr_name, attr_value|
            if ![:id].include? attr_name.to_sym
              item.send("#{attr_name}=", attr_value)
            end
          end

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
    end

    def load_data data

      load_order = [:Shop, :Page, :Product]
        .select { |type| data.key? type and @options.types.include? type }

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
