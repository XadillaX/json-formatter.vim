function! JsonFormatter()
    execute "%!jjson --vim-plugin-mode -i 4 -f %"
endfunction

nnoremap <leader>jf :call JsonFormatter()<cr>

