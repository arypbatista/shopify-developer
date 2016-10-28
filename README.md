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

## Shopify Config File

Shopify Config file is a yaml file, named after `site.yml` by default, as in example:

```yml
site:
  pages:
    - title    : About Us
      content  : We are a new company!
      handle   : about-us
      template : page.about
  menus:
    - name   : Main Menu
      handle : main-menu
      items  :
        - name : About Us
          link : pages:about-us
```
