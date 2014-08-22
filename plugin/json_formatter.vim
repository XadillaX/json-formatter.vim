if exists("loaded_json_formatter")
  finish
endif

function! JsonFormatter()
    execute "%!jjson --vim-plugin-mode -i 4 -f %"
endfunction

nnoremap <C-j>f :call JsonFormatter()<cr>

