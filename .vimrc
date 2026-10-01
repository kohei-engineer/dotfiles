" Keep vimdiff windows equally sized after a terminal resize.
augroup wezterm_vimdiff_resize
  autocmd!
  autocmd VimResized * wincmd =
augroup END

" Show the absolute number for the current line and relative numbers elsewhere.
set number
set relativenumber
