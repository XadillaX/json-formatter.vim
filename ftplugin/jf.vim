function! JsonFormatter()
    execute "%!jjson --vim-plugin-mode -i 4 -f %"
endfunction

nnoremap <C-j>f :call JsonFormatter()<cr>

