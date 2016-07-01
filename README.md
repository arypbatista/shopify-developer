# shopify-developer
Set of tools for Shopify developers.

## Features

With

## Usage

### Dumping site structure

```
$ shopify dump <shopify-config-file>
```

### Setting up site structure

```
$ shopify install <shopify-config-file>
```

## Shopify Config File

Shopify Config file is a yaml file as in example:

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
