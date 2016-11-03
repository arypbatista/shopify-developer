module ShopifyDevTools

  class ShopLoader

    def initialize options
      @shop = ShopifyAPI::Shop.current
      @id_replacements = {}
      @options = options
      @old_data = {}
      @stats = {}
    end

    def load_metafields item, type, old_id, data
      if data.key? :Metafield
        if data[:Metafield].key? type and
           data[:Metafield][type].key? old_id

          new_metafields = data[:Metafield][type][old_id]

          old_metafields = item.metafields

          old_metafields_hash = old_metafields
            .map { |m| ["#{m.namespace}:#{m.key}", m] }
            .to_h

          new_metafields.each do |new_metafield|
            new_created = false
            metafield = old_metafields_hash.fetch new_metafield.full_name, false
            if !metafield
              metafield = ShopifyAPI::Metafield.new
              new_created = true
            end

            if !new_created and @options.create_only
              puts "Metafield #{metafield.full_name} was ignored since flag " +
                   "--create-only was set."
            else
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

        if type == :Product and data[:Metafield].key? :Image
          changed = self.set_product_image_metafields item, data[:Metafield][:Image]
          item.save if changed
        end
      end
    end

    def get_old_data type, item
      if @old_data_hashed.key? type and item.attributes.key? :handle
        #ShopifyDevTools::get_type(type).find(:all, :params => { :handle => item.handle }).first
        @old_data_hashed[type].fetch item.handle, false
      else
        false
      end
    end

    def set_product_image_metafields item, image_metafields
      changed = false
      if image_metafields.key? item.handle
        item.images.each do |image|
          if image_metafields[item.handle].key? image.text_id
            final_metafields = []
            new_metafields = image_metafields[item.handle][image.text_id]
            old_metafields = image.metafields or []
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

              final_metafields << metafield
            end

            image.metafields = final_metafields
            changed = true
          end
        end
      end
      changed
    end

    def set_product_variant_images item, old_variant_images_ids
      # Update variant images since they have changed on first save
      if old_variant_images_ids.size > 1 # If only one variant, do nothing
        for i in 0...old_variant_images_ids.size
          old_id = old_variant_images_ids[i]
          if @id_replacements.key? old_id
            new_id = @id_replacements[old_id]
            item.variants[i].image_id = new_id
          end
        end
        true
      else
        false
      end
    end

    def load_item data_item, type, data
      if type == :Shop
        @id_replacements[data_item.id] = @shop.id
        self.load_metafields @shop, type, data_item.id, data
      else

        old_id = data_item.id

        if type == :Product
          old_images_ids = data_item.images.map { |img| img.id }
          old_variant_images = data_item.variants.map { |v| v.image_id }
        end

        item = get_old_data type, data_item
        if !item and !@options.update_only
          item = ShopifyDevTools::get_type(type).new
        end

        if item
          item.copy_from data_item

          begin
            if !@options.metafields_only

              item.save

              puts "#{type} Saved #{old_id} => #{item.id}!"
              @id_replacements[old_id] = item.id

              if type == :Product
                begin
                  if old_images_ids.size > item.images.size
                    raise "Images count seems to defer. Online product " +
                          "images are fewer than the uploaded count. " +
                          "Maybe some images are invalid?"
                  else
                    puts "READING IDS"
                    for i in 0...old_images_ids.size
                      old_id = old_images_ids[i]
                      new_id = item.images[i].id
                      puts "\t#{old_id} => #{new_id}"
                      @id_replacements[old_id] = new_id
                    end
                    changes = self.set_product_variant_images item, old_variant_images
                    item.save if changes
                  end
                rescue => e
                  puts "Error to save variants for #{type} with id #{old_id}.\nError: #{e.message}"
                  puts e.backtrace
                end

              end
            end
            self.load_metafields item, type, old_id, data

          rescue => e
            puts "Error to save object #{type} with id #{old_id}.\nError: #{e.message}"
            puts e.backtrace
          end
        end
      end
    end

    def download_old_data
      dumper = ShopDumper.new @options
      @old_data = dumper.download_data
      @old_data_hashed = {}
      @old_data.each do |type, items|
        @old_data_hashed[type] = {}
        if items.kind_of? ActiveResource::Collection
          items.each do |item|
            @old_data_hashed[type][item.handle] = item
          end
        end
      end

    end

    def load_data data
      self.download_old_data

      load_order = [:Shop, :Page, :Product]
        .select { |type| data.key? type and @options.types.include? type }

      @stats[:Metafield] = { :modified => 0, :created => 0, :processed => 0 }
      load_order.each do |type|
        @stats[type] = { :modified => 0, :created => 0, :processed => 0, :unprocessed => 0}

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
