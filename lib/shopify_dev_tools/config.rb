module ShopifyDevTools
  class Config

    attr_accessor :store

    def initialize filepath, config_format, env
      @data = YAML.load(File.read(filepath))
      begin
        if config_format == :themekit
          data = @data[env.to_s]
          if !data
            raise "Not valid configuration found for #{env} environment."
          end
          @store = data['store']
          @password = data['password']
          @api_key = data['api_key']
          @theme_id = data['theme_id']
        elsif config_format == :shopify_theme
          if !@data[:store].end_with?('.myshopify.com')
            @data[:store] = @data[:store] + '.myshopify.com'
          end
          @store = @data[:store]
          @password = @data[:password]
          @api_key = @data[:api_key]
          @theme_id = @data[:theme_id]
        else
          raise "Invalid config format #{options.config_format}'"
        end
      rescue => e
        puts "Configuration failed to load from #{filepath}. Did you forget " +
             "to specify a different config format?"
        raise e
      end
    end

    def auth_url
      "https://#{@api_key}:#{@password}@#{@store}/admin"
    end
  end
end
