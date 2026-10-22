" Keep vimdiff windows equally sized after a terminal resize.
augroup wezterm_vimdiff_resize
  autocmd!
  autocmd VimResized * wincmd =
augroup END

" Show the absolute number for the current line and relative numbers elsewhere.
set number
set relativenumber

" Diff colors: unique lines green, missing-line filler red, edits muted.
highlight DiffAdd    cterm=NONE ctermfg=NONE ctermbg=22 gui=NONE guifg=NONE guibg=#203b28
highlight DiffDelete cterm=NONE ctermfg=167 ctermbg=52 gui=NONE guifg=#d16969 guibg=#482526
highlight DiffChange cterm=NONE ctermfg=NONE ctermbg=238 gui=NONE guifg=NONE guibg=#303030
highlight DiffText   cterm=bold ctermfg=NONE ctermbg=24 gui=bold guifg=NONE guibg=#264f78

" Keep comments readable on both normal and diff backgrounds.
highlight Comment ctermfg=250 guifg=#bcbcbc

" Keep whitespace invisible, but make indentation and trailing whitespace
" easy to distinguish by background color.
set nolist
if has('termguicolors')
  set termguicolors
endif

highlight WhitespaceBg       cterm=NONE ctermbg=235 gui=NONE guibg=#252525
highlight TrailingWhitespace cterm=NONE ctermbg=88  gui=NONE guibg=#803030

function! HighlightWhitespace() abort
  " WinEnter/BufWinEnter can run repeatedly for the same window. Remove
  " the previous matches first so they do not accumulate.
  if exists('w:whitespace_match_ids')
    for id in w:whitespace_match_ids
      silent! call matchdelete(id)
    endfor
  endif

  let w:whitespace_match_ids = []
  " Lower priority: leading indentation on each non-empty whitespace run.
  call add(w:whitespace_match_ids, matchadd('WhitespaceBg', '^\s\+', 10))
  " Higher priority: trailing whitespace, including lines containing only spaces.
  call add(w:whitespace_match_ids, matchadd('TrailingWhitespace', '\s\+$', 20))
endfunction

augroup WhitespaceHighlight
  autocmd!
  autocmd VimEnter,WinEnter,BufWinEnter * call HighlightWhitespace()
augroup END
