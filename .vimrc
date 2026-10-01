" Keep vimdiff windows equally sized after a terminal resize.
augroup wezterm_vimdiff_resize
  autocmd!
  autocmd VimResized * wincmd =
augroup END
