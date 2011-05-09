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

function s:shquote(s)
  return "'" . substitute(a:s, "'", "'\\\\''", 'g') . "'"
endfunction

function s:lastline(s)
  return substitute(a:s, ".*\\n\\(.\\)\\@=", '', '')
endfunction

function s:addnl(s)
  if &ft == 'python'
    " if the last line starts with whitespace and ends with newline,
    " append an additional newline to finish the block
    if s:lastline(a:s) =~ "^[ \t].*\n"
      return "\n"
    endif
  endif
  return ""
endfunction

function! ScreenRepl_Send(text)
  if !exists("b:screenrepl_session") || !exists("b:screenrepl_window")
    if ScreenRepl_Vars() != 0
      " error or user cancelled
      return
    endif
  end
  call system('screen'.
        \ ' -S '.s:shquote(b:screenrepl_session).
        \ ' -p '.s:shquote(b:screenrepl_window).
        \ ' -X stuff '.s:shquote(a:text.s:addnl(a:text)))
  if v:shell_error != 0
    " probably the screen session has disappeared.
    " kill the var so the user can call back
    unlet b:screenrepl_session
    echoerr "screen stuff failed, call back to try again"
  endif
endfunction

function ScreenRepl_Sessions(A,L,P)
  return system('screen -ls | awk '.s:shquote('/attached/ {print $1}'))
endfunction

function ScreenRepl_Vars()
  let l:sessions = split(ScreenRepl_Sessions('','',0), "\n")
  if len(l:sessions) == 0
    echoerr "can't find any running screen sessions"
    return 1
  endif

  " if the session has gone away, reset b:screenrepl_session
  if exists('b:screenrepl_session')
    if index(l:sessions, b:screenrepl_session) < 0
      unlet b:screenrepl_session
    end
  end

  " default to the current screen session or look for one
  if !exists("b:screenrepl_session") || !exists("b:screenrepl_window")
    if exists('$STY')
      let b:screenrepl_session = $STY
      let b:screenrepl_window = "1"
    else
      let b:screenrepl_session = (len(l:sessions) == 1) ? l:sessions[0] : ""
      let b:screenrepl_window = "0"
    endif
  endif

  " ask the user
  let b:screenrepl_session = input("session name: ", b:screenrepl_session,
        \ "custom,ScreenRepl_Sessions")
  if len(b:screenrepl_session) == 0 | return 2 | endif

  let b:screenrepl_window = input("window name: ", b:screenrepl_window)
  if len(b:screenrepl_window) == 0 | return 3 | endif

  return 0 " success (we hope)
endfunction

vnoremap <C-c><C-c> "ry :call ScreenRepl_Send(@r)<CR>
nmap <C-c><C-c> vip<C-c><C-c>
nmap <C-c>v :call Screen_Vars()<CR>
