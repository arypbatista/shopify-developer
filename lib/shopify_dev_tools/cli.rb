#!/usr/bin/env ruby

require 'shopify_dev_tools'
require 'shopify_dev_tools/version'
require 'rubygems'
require 'commander/import'


module ShopifyDevTools
  class Cli
    include Commander::Methods

    def self.run
      self.new.run
    end

    def run
      program :name, 'shopify_dev_tools'
      program :version, ShopifyDevTools::VERSION
      program :description, 'Developer tools for Shopify developers'

      command :dump do |c|
        c.syntax = 'shopify_dev_tools dump [options]'
        c.summary = 'Dump site structure to configuration file'
        c.option '--file STRING', String, 'YAML file with site data'
        c.description = 'Dump site structure to configuration file'
        c.action do |args, options|
          ShopifyDevTools.dump options
        end
      end

      command :load do |c|
        c.syntax = 'shopify_dev_tools load [options]'
        c.summary = 'Load site from configuration file'
        c.description = 'Load site from configuration file'
        c.option '--file STRING', String, 'YAML file with site data'
        c.action do |args, options|
          options.default :file => 'site.yml'
          ShopifyDevTools.load options
        end
      end

      command :clear do |c|
        c.syntax = 'shopify_dev_tools load [options]'
        c.summary = 'Load site from configuration file'
        c.description = 'Load site from configuration file'
        c.action do |args, options|
          def ask_continue
            ask('This will delete all shop data. Are you sure? (y/n): ').strip
          end

          answer = ask_continue()
          while !['y', 'n', 'Y', 'N'].include? answer
            answer = ask_continue()
          end

          if ['y', 'Y'].include? answer
            ShopifyDevTools.clear_shop options
          end

        end
      end
    end
  end
end
