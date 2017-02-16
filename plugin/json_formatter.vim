" json-formatter: A VIM plugin for formatting JSON 
"   Author:	  David Fishburn <dfishburn dot vim at gmail dot com>
"   Last Changed: 2017 Feb 15
"   Version:	  2.0.0
"   Script:	  http://www.vim.org/script.php?script_id=5010
"   License:      GPL (http://www.gnu.org/licenses/gpl.html)
"
"   Documentation:
"        :h json-formatter.txt 
"
if exists("g:loaded_json_formatter")
    finish
endif

let g:loaded_json_formatter = 2

let s:json_formatter_buffer_errors     = 0
let s:json_formatter_buffer_last       = 0
let s:json_formatter_buffer_last_winnr = 0

" Get the name of a temporary file for the system
let s:json_formatter_tempfile = fnamemodify(tempname(), ":h")
let s:json_formatter_tempfile = s:json_formatter_tempfile.(s:json_formatter_tempfile =~ '^/' ? '/' : '\').'json_formatter.json'

" define shell command
if !exists('g:json_formatter_command')
    let g:json_formatter_command = 'jjson'
endif

" Parameters to the shell command
if !exists('g:json_formatter_command_encoding')
    let g:json_formatter_command_encoding  = ''
endif
if !exists('g:json_formatter_command_indent')
    let g:json_formatter_command_indent  = ''
endif

" Error window position and size
if !exists('g:json_formatter_window_title')
    let g:json_formatter_window_title  = 'JSON Formatter Errors'
endif
if !exists('g:json_formatter_window_use_horiz')
    let g:json_formatter_window_use_horiz  = 1
endif
if !exists('g:json_formatter_window_use_bottom')
    let g:json_formatter_window_use_bottom = 1
endif
if !exists('g:json_formatter_window_use_right')
    let g:json_formatter_window_use_right  = 0
endif
if !exists('g:json_formatter_window_width')
    let g:json_formatter_window_width      = 80
endif
if !exists('g:json_formatter_window_increment')
    let g:json_formatter_window_increment  = 50
endif

function! s:JSONFormatter(...) range
    let default_register      = 'a'
    let default_register_type = 'V'
    let save_reg              = getreg(default_register)
    let save_reg_type         = getregtype(default_register)
    let linenum               = 1
    let colnum                = 1

    " Default command mode to normal mode 'n'
    let cmd_mode = 'n'
    if a:0 > 0
        " Change to visual mode, if command executed via a visual map
        let cmd_mode = ((a:1 == 'v') ? 'v' : 'n')
    endif

    if cmd_mode == 'v'
        " We are yanking either an entire line, or a range.
        " Reselect the visual range and yank the text
        " into our register.
        silent! exec 'normal! gv"' . default_register . 'y'
        let default_register_type = getregtype(default_register)
        let orig_linenum = line("'<")
        let orig_colnum  = colnum("'<")
        let end_linenum  = line("'>")
        let linenum      = line("'<")
        let colnum       = colnum("'<")
    else
        " In normal mode, always yank the complete line, since this
        " command is for a range.
        silent! exec a:firstline . ',' . a:lastline . 'yank '. default_register
        let orig_linenum = a:firstline
        let orig_colnum  = 1
        let end_linenum  = a:lastline
        let linenum      = a:firstline
        let colnum       = 1
    endif

    " Populate the temporary file with the yanked text
    let rc = writefile(split(getreg(default_register), "\n"), s:json_formatter_tempfile)
    if rc == -1
        echohl Warning
        echo 'JSONFormatter - Failed to write to temporary file[' . s:json_formatter_tempfile . ']'
        echohl None
        return
    endif

    " Store buffer information to return to for the error list
    let s:json_formatter_buffer_last       = bufnr('%')
    let s:json_formatter_buffer_last_winnr = winnr()

    let encoding = g:json_formatter_command_encoding
    if exists("b:json_formatter_command_encoding")
        let encoding = b:json_formatter_command_encoding
    endif

    let indent = g:json_formatter_command_indent
    if exists("b:json_formatter_command_indent")
        let indent = b:json_formatter_command_indent
    endif

    let json_cmd = g:json_formatter_command
    if exists("b:json_formatter_command")
        let json_cmd = b:json_formatter_command
    endif

    " Use nodejs to format the JSON
    let cmd = shellescape(json_cmd)
    if encoding != ''
        let cmd = cmd . " -e " . encoding 
    endif
    if indent != ''
        let cmd = cmd . " -i " . indent 
    endif
    let cmd = cmd . " -f " . s:json_formatter_tempfile

    let result = system( cmd )

    " echomsg result
    " If the formatting failed, the result always starts with "Error occurred"
    " so check for this text.
    if result =~ '^Error occurred while'
        " Handle strings like this:
        "     Error occurred while:
        "     D:\WINDOW~1\json_formatter.json,3,130,found: '}' - expected: 'STRING'
        let matches = matchlist(result, '^Error occurred while.\{-}file:\s\+\zs\([^,]\+\),\(\d\+\),\(\d\+\),\(.*\)', '', '')

        let MATCH_ALL      = 0
        let MATCH_FILENAME = 1
        let MATCH_LINENUM  = 2
        let MATCH_COLNUM   = 3
        let MATCH_ERROR    = 4

        " Open the quick fix window with an errorformat specified.
        setlocal errorformat=%E%f,%l,%c,%Z%m

        if len(matches) > 3 && matches[MATCH_COLNUM] != ''

            let linenum = linenum + matches[MATCH_LINENUM] - 1

            for line in getbufline('', orig_linenum, linenum)
                " Empty lines are not picked up by the JSON parser
                " so manually adjust the linenum.
                " Abort at the first non-empty line.
                if line =~ '^$'
                    let linenum = linenum + 1
                else
                    break
                endif
            endfor

            if 1 == matches[MATCH_LINENUM] && colnum != 1
                " A range of lines was selected so we need to correct the
                " offset to the errorline so the quickfix window will take 
                " us to the correct column.
                let colnum = colnum + matches[MATCH_COLNUM] - 1
            else
                let colnum = matches[MATCH_COLNUM]
            endif

            let rc = setqflist([
                        \{
                        \  'bufnr': ''
                        \, 'filename': bufname(s:json_formatter_buffer_last)
                        \, 'lnum': linenum
                        \, 'pattern': ''
                        \, 'col': colnum
                        \, 'vcol': 0
                        \, 'nr': 0
                        \, 'text': matches[MATCH_ERROR]
                        \, 'type': 'E'
                        \}
                        \,]
                        \)
        else
            let linenum = orig_linenum

            for line in getbufline('', orig_linenum, end_linenum)
                " Blank lines are not picked up by the JSON parser
                " so manually adjust the linenum.
                if line =~ '^\s*$'
                    let linenum = linenum + 1
                else
                    break
                endif
            endfor

            " Either JSONLint hasn't been installed or JSONLint passed
            " but JSON.parse() has failed.  So no line and column information
            " is provided.  Just show the error message.
            let rc = setqflist([
                        \{
                        \  'bufnr': ''
                        \, 'filename': bufname(s:json_formatter_buffer_last)
                        \, 'lnum': linenum
                        \, 'pattern': ''
                        \, 'col': colnum
                        \, 'vcol': 0
                        \, 'nr': -1
                        \, 'text': matchstr(result, '^Error occurred while.\{-}file: \zs.*', '', '')
                        \, 'type': 'E'
                        \}
                        \,]
                        \)
        endif

        copen
    else
        " Put the formatted JSON into our register.
        call setreg(default_register, result, default_register_type)

        " The formatting was successful, replace the selected text
        " with the formatted text.
        if cmd_mode == 'v'
            " Reselect the visual selection and paste the newly
            " formatted text
            silent! exec 'normal! gv"' . default_register . 'p'
        else
            " In normal mode, always yank the complete line, since this
            " command is for a range.
            silent! exec a:firstline . ',' . a:lastline . 'delete'
            " Replaced selected area with reformatted JSON from the default
            " register.
            " Subtract 1 from the firstline of the range since we just 
            " deleted those lines, so we need to put from the previous line.
            silent! exec (a:firstline - 1) . 'put ' . default_register
        endif
    endif

    call setreg(default_register, save_reg, save_reg_type)
endfunction


command! -nargs=? -range=% JSONFormatter  <line1>,<line2>call s:JSONFormatter(<q-args>)

"exec 'xnoremap <silent>'.g:yankring_v_key." :JSONFormatter 'v'<CR>"

"xmap <unique> <script> <Plug>JSONFormatter :JSONFormatter<CR>
" nnoremap <leader>json :call JsonFormatter()<cr>
