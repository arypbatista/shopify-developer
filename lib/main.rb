#!/usr/bin/env ruby

require './lib/shopify_dev_tools.rb'
require './lib/shopify_dev_tools/version'
require 'rubygems'
require 'commander/import'

program :name, 'shopify_dev_tools'
program :version, ShopifyDevTools::VERSION
program :description, 'Developer tools for Shopify developers'

command :dump do |c|
  c.syntax = 'shopify_dev_tools dump, [options]'
  c.summary = 'Dump site structure to configuration file'
  c.description = 'Dump site structure to configuration file'
  c.action do |args, options|
    ShopifyDevTools.dump
  end
end

command :load do |c|
  c.syntax = 'shopify_dev_tools load'
  c.summary = 'Load site from configuration file'
  c.description = 'Load site from configuration file'
  c.action do |args, options|
    ShopifyDevTools.load
  end
end
