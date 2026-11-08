" Glow preview lifecycle, save refresh, and approximate scroll following.
function! s:Dispose(preview, ...) abort
  if a:preview > 0 && bufexists(a:preview)
    call term_setkill(a:preview, 'kill')
    execute 'bwipeout! ' . a:preview
  endif
endfunction

function! s:Close(source) abort
  let preview = getwinvar(a:source, 'glow_preview', 0)
  call setwinvar(a:source, 'glow_preview', 0)
  call s:Dispose(preview)
endfunction

" Both opening and refreshing use the same terminal setup.
function! s:Render(source, window, file) abort
  let preview = term_start(['glow', '-p', a:file],
        \ {'hidden': 1, 'term_finish': 'close'})
  if preview <= 0
    return
  endif
  let old = getwinvar(a:source, 'glow_preview', 0)
  call term_setkill(preview, 'kill')
  call setbufvar(preview, 'glow_source', a:source)
  call win_execute(a:window, 'hide buffer ' . preview)
  call win_execute(a:window,
        \ 'tnoremap <silent> <buffer> <Space>p <C-W>N:call GlowPreview()<CR>')
  call win_execute(a:window,
        \ 'nnoremap <silent> <buffer> <Space>p :call GlowPreview()<CR>')
  call setwinvar(a:source, 'glow_preview', preview)
  call setwinvar(a:source, 'glow_topline', getwininfo(a:source)[0].topline)
  call s:Dispose(old)
endfunction

function! GlowPreview() abort
  let source = get(b:, 'glow_source', win_getid())
  let preview = getwinvar(source, 'glow_preview', 0)
  if preview > 0 && bufexists(preview)
    call win_gotoid(source)
    call s:Close(source)
    return
  endif
  update
  let file = expand('%:p')
  if empty(file) || !executable('glow')
    echoerr 'Glow requires a saved file and glow on PATH.'
    return
  endif
  botright vnew
  try
    call s:Render(source, win_getid(), file)
  finally
    call win_gotoid(source)
  endtry
endfunction

function! s:Refresh(buffer) abort
  for info in getwininfo()
    if info.bufnr == a:buffer && info.tabnr == tabpagenr()
      let preview = getwinvar(info.winid, 'glow_preview', 0)
      let window = preview > 0 ? bufwinid(preview) : -1
      if window != -1
        call s:Render(info.winid, window, fnamemodify(bufname(a:buffer), ':p'))
      endif
    endif
  endfor
endfunction

function! s:SyncScroll() abort
  for info in getwininfo()
    if info.tabnr != tabpagenr()
      continue
    endif
    let preview = getwinvar(info.winid, 'glow_preview', 0)
    if preview <= 0 || !bufexists(preview)
          \ || getbufvar(preview, '&buftype') !=# 'terminal'
          \ || job_status(term_getjob(preview)) !=# 'run'
      continue
    endif
    let previous = getwinvar(info.winid, 'glow_topline', info.topline)
    call setwinvar(info.winid, 'glow_topline', info.topline)
    let delta = info.topline - previous
    " Source lines and rendered lines need not match exactly.
    if delta != 0
      call term_sendkeys(preview, repeat(delta > 0 ? 'j' : 'k', abs(delta)))
    endif
  endfor
endfunction

function! s:SourceClosed(source) abort
  let preview = getwinvar(a:source, 'glow_preview', 0)
  if preview > 0 && bufexists(preview)
    " Wait until WinClosed has finished changing the window layout.
    call timer_start(0, function('s:Dispose', [preview]))
  endif
endfunction

augroup GlowScrollSync
  autocmd!
  autocmd WinScrolled * call s:SyncScroll()
  autocmd BufWritePost * call s:Refresh(str2nr(expand('<abuf>')))
  autocmd QuitPre * call s:Close(win_getid())
  autocmd WinClosed * call s:SourceClosed(str2nr(expand('<amatch>')))
augroup END
