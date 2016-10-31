module ShopifyDevTools

  ITEM_TYPES = [:Page, :Product, :Shop, :Metafield]

  def self.get_type(type)
    eval("ShopifyAPI::#{type}")
  end

  def self.check_types types
    invalid = types.reject { |t| ITEM_TYPES.include? t }
    if !invalid.empty?
      invalid_types = invalid.map { |t| t.to_s }.join(', ')
      valid_types = "\t- "+ ITEM_TYPES.map { |t| t.to_s }.join("\n\t- ")
      raise "Supplied types are invalid: " + invalid_types +
            "\nValid types are:\n" + valid_types
    end
  end

end
