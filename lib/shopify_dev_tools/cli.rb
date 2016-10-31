#!/usr/bin/env ruby

require 'shopify_dev_tools'
require 'shopify_dev_tools/item_types'
require 'shopify_dev_tools/version'
require 'rubygems'
require 'commander/import'


module ShopifyDevTools
  class Cli
    include Commander::Methods

    def self.run
      self.new.run
    end

    def ask_yes_or_no(question)
      answer = ask(question)
      while !['y', 'n', 'Y', 'N'].include? answer.strip
        answer = ask(question)
      end

      ['y', 'Y'].include? answer
    end

    def process_types options
      if options.types
        sym_types = options.types.map { |t| t.to_sym }
        ShopifyDevTools.check_types sym_types
        options.types = sym_types
      else
        options.types = ShopifyDevTools::ITEM_TYPES
      end
    end

    def process_options options
      process_types options

      if options.config_format
        sym_config_format = options.config_format.to_sym
        if [:themekit, :shopify_theme].include? sym_config_format
          options.config_format = sym_config_format
        else
          raise "Invalid config format '#{sym_config_format}'."
        end
      else
        options.config_format = :themekit
      end

      if options.env
        options.env = options.env.to_sym
      else
        options.env = :development
      end

      options
    end

    def common_options c
      c.option '--config-format STRING', String, 'Config file format. Options: themekit, shopify_theme. Default: themekit'
      c.option '--env STRING', String, 'Environment. Default is development.'
    end

    def run
      program :name, 'shopify_dev_tools'
      program :version, ShopifyDevTools::VERSION
      program :description, 'Developer tools for Shopify developers'

      command :test_cli do |c|
        common_options c

        c.syntax = 'shopify_dev_tools test_cli [options]'
        c.summary = 'Test cli usage'
        c.option '--update-only', 'Only update existing items. Items are searched by handle.'
        c.option '--metafields-only', 'Only update metafields. Items are searched by handle.'
        c.description = 'Test cli usage'
        c.action do |args, options|
          if options.metafields_only
            options.update_only = true
          end
        end
      end

      command :dump do |c|
        common_options c

        c.syntax = 'shopify_dev_tools dump [options]'
        c.summary = 'Dump site structure to configuration file'
        c.option '--file STRING', String, 'YAML file with site data'
        c.option '--types WORDS', Array, 'Item types to process. E.g.: Page, Product'
        c.description = 'Dump site structure to configuration file'
        c.action do |args, options|
          process_options options
          ShopifyDevTools.prepare options
          ShopifyDevTools.dump options
        end
      end

      command :load do |c|
        common_options c

        c.syntax = 'shopify_dev_tools load [options]'
        c.summary = 'Load site from configuration file'
        c.description = 'Load site from configuration file'
        c.option '--file STRING', String, 'YAML file with site data'
        c.option '--types WORDS', Array, 'Item types to process. E.g.: Page, Product'
        c.option '--update-only', 'Only update existing items. Items are searched by handle.'
        c.option '--metafields-only', 'Only update metafields. Items are searched by handle.'
        c.action do |args, options|
          process_options options

          if options.metafields_only
            options.update_only = true
          end

          options.default :file => 'site.yml'
          ShopifyDevTools.prepare options
          ShopifyDevTools.load options
        end
      end

      command :clear do |c|
        common_options c

        c.syntax = 'shopify_dev_tools load [options]'
        c.summary = 'Load site from configuration file'
        c.description = 'Load site from configuration file'
        c.option '--types WORDS', Array, 'Item types to process. E.g.: Page, Product'
        c.action do |args, options|

          if ask_yes_or_no("This will delete all shop data on #{ShopifyDevTools.config[:store]}. Are you sure? (y/n): ")
            process_options options
            ShopifyDevTools.prepare options
            ShopifyDevTools.clear_shop options
          end

        end
      end
    end
  end
end
