# JSON Formatter Plugin for Vim

A Vim plugin for formatting saved JSON file.

## Installation

### Vundle

Add this repository to your Vundle configuration:

```viml
Plugin "XadillaX/json-formatter.vim"
```

Make sure you have [Node.js](https://nodejs.org/) installed and then install module below:

```shell
$ npm install -g jjson
```

### Vim-Plug

Add this repository to your Vim-Plugn configuration:

```viml
Plug "XadillaX/json-formatter.vim", { "do": "npm install -g jjson" }
```

### Dein

Add this repository to your Dein configuration:

```viml
call dein#add("XadillaX/json-formatter.vim", { "build": "npm install -g jjson" })
```

## Usage

The `JSONFormatter` command will either format the JSON supplied or open the quickfix window and show any errors reported by the tools. Clicking or hitting `<Enter>` on any of the lines reported in the quickfix window will take you directly to that location.

## Configuration

See https://github.com/XadillaX/json-formatter.vim/blob/c671c41/doc/json_formatter.txt#L78-L163

## Contribution

Issues and PRs are welcomed!
