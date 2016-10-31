module ShopifyDevTools
  class Config

    def initialize filepath, config_format, env
      @data = YAML.load(File.read(filepath))

      if config_format == :themekit
        data = @data[env.to_s]
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

    end

    def auth_url
      "https://#{@api_key}:#{@password}@#{@store}/admin"
    end
  end
end
