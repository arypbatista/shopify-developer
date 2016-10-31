# shopify-developer
Set of tools for Shopify developers.

## Features

- Dump site structure to configuration file
- Install site from configuration file

## Usage

### Dumping site structure

```
$ shopify dump --file <site-config-file>
```

### Setting up site structure

```
$ shopify load --file <site-config-file>
```

### Other commands

Remove all shop data
```
$ shopify clear
```

### General command options

The following options are present in all commands:

- `--file <site_file>` - Path to `site.yml` file. This files contains the dump data from a shop.
- `--config-format <format>` - Your config.yml format. Two formats are accepted: `themekit` format or `shopify_theme` format. Default is `themekit`
- `--env <environment>` - Shop environment to work with. Default is `development`

### Command examples

Let's say you want to clone `shop-develop` into `shop-prod`. Both shops have already been created. `shop-develop` is populated with products, pages and metafields. The following example assumes that your `config.yml` files are in `themekit` format.

The commands to execute to perform migration are:

```
$ cd path/to/shop-develop
path/to/shop-develop$ shopify_dev_tools dump --file path/to/shop-prod/site.yml
path/to/shop-develop$ cd path/to/shop-prod
path/to/shop-prod$ shopify_dev_tools load
```

This is the basic example and use case for the tool. For more options see the [General Command Options](#general-command-options) section, dive into each specific command documentation on this readme or simply try `shopify_dev_tools --help`.
