# JSON Formatter Plugin for VIM

A VIM plugin for formatting saved JSON file.

## Installation

Add this `repo` to your Vundle configuration:

```VIML
Bundle "XadillaX/json-formatter.vim"
```

Make sure you have `node.js` installed and then install module below:

```shell
$ npm install jjson -g
```

## Usage

Call this function below:

```VIML
:call JsonFormatter()
```

`json-formatter.vim` also has added an `nnoremap` for you:

```VIML
nnoremap <leader>jf ...
```

So if your `<leader>` is `-`, you can use keys `-json` in normal mode to format
your json file.

## Configuration

You can also DIY yor own keymap, just configure it as blow:

```VIML
nnoremap <YOUR KEYs> :call JsonFormatter()<cr>
```

## Contribution

You're welcome to fork and push requests!

