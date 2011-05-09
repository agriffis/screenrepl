" Repl interaction support through screen, based on
" Jonathan Palardy's slime.vim available from
" http://technotales.wordpress.com/2007/10/03/like-slime-for-vim/
"
" Copyright 2009 Aron Griffis <agriffis@n01se.net>
" Released under the GNU GPL v2

if exists("g:loaded_screenrepl")
 finish
endif
let g:loaded_screenrepl = "v1"

function! ScreenRepl_Send(text)
  if !exists("b:screenrepl_session") || !exists("b:screenrepl_window")
    call ScreenRepl_Vars()
  end
  call system("screen" .
        \ " -S " . b:screenrepl_session . 
        \ " -p " . b:screenrepl_window . 
        \ " -X stuff '" . substitute(a:text, "'", "'\\\\''", 'g') . "'")
endfunction

function ScreenRepl_Sessions(A,L,P)
  return system("screen -ls | awk '/attached/ {print $1}'")
endfunction

function ScreenRepl_Vars()
  if !exists("b:screenrepl_session") || !exists("b:screenrepl_window")
    if exists('$STY')
      let b:screenrepl_session = $STY
      let b:screenrepl_window = "1"
    else
      let b:screenrepl_session =
            \ substitute(ScreenRepl_Sessions('','',0), '\n.*', '', '')
      let b:screenrepl_window = "0"
    endif
  end
  let b:screenrepl_session = 
        \ input("session name: ", b:screenrepl_session, "custom,ScreenRepl_Sessions")
  let b:screenrepl_window = input("window name: ", b:screenrepl_window)
endfunction

vnoremap <C-c><C-c> "ry :call ScreenRepl_Send(@r)<CR>
nmap <C-c><C-c> vip<C-c><C-c>
nmap <C-c>v :call Screen_Vars()<CR>
