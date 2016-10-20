# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "shopify_dev_tools/version"

Gem::Specification.new do |s|
  s.name        = 'shopify_dev_tools'
  s.version     = ShopifyDevTools::VERSION
  s.date        = '2016-10-18'
  s.summary     = "Shopify Developer Tools"
  s.description = "Tools to help developers"
  s.authors     = ["Ary Pablo Batista"]
  s.email       = 'arypbatista@gmail.com'
  s.files       = ["lib/shopify_dev_tools.rb"]
  s.homepage    =
    'http://rubygems.org/gems/shopify_dev_tools'
  s.license       = 'MIT'
end
