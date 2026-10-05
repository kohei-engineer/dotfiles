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
