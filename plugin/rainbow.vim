"==============================================================================
"Script Title: rainbow parentheses improved
"Script Version: 2.52
"Author: luochen1990, Francisco Lopes
"Last Edited: 2013 Sep 12

" By default, use rainbow colors copied from gruvbox colorscheme (https://github.com/morhetz/gruvbox).
" They are generally good for both light and dark colorschemes.
let g:rainbow_blocklist = get(g:, 'rainbow_blocklist', [])

let s:guifgs = exists('g:rainbow_guifgs')? g:rainbow_guifgs : [
            \ '#458588',
            \ '#b16286',
            \ '#cc241d',
            \ '#d65d0e',
            \ '#458588',
            \ '#b16286',
            \ '#cc241d',
            \ '#d65d0e',
            \ '#458588',
            \ '#b16286',
            \ '#cc241d',
            \ '#d65d0e',
            \ '#458588',
            \ '#b16286',
            \ '#cc241d',
            \ '#d65d0e',
            \ ]

let s:ctermfgs = exists('g:rainbow_ctermfgs')? g:rainbow_ctermfgs : [
            \ 'brown',
            \ 'Darkblue',
            \ 'darkgray',
            \ 'darkgreen',
            \ 'darkcyan',
            \ 'darkred',
            \ 'darkmagenta',
            \ 'brown',
            \ 'gray',
            \ 'black',
            \ 'darkmagenta',
            \ 'Darkblue',
            \ 'darkgreen',
            \ 'darkcyan',
            \ 'darkred',
            \ 'red',
            \ ]

let s:max = has('gui_running')? len(s:guifgs) : len(s:ctermfgs)

func! rainbow#load(...)
    if index(g:rainbow_blocklist, expand('%:e:r')) != -1 || index(g:rainbow_blocklist, &ft) != -1
        return
    endif
    if exists('b:loaded')
        cal rainbow#clear()
    endif

    let b:loaded = a:0 >= 1 ? a:1 : [ ['(', ')'], ['\[', '\]'], ['{', '}'] ]

    let b:operators = (a:0 < 2) ? '"\v[{\[(<_"''`#*/>)\]}]@![[:punct:]]|\*/@!|/[/*]@!|\<#@!|#@<!\>"' : a:2

    let str = 'TOP'
    let cmd = 'syn match %s %s containedin=%s contained'
    let cmd2 = 'syn region %s matchgroup=%s start=+%s+ end=+%s+ containedin=%s contains=%s,%s,@Spell fold'
    if b:operators != ''
        exe 'syn match op_lv0 '.b:operators
    endif

    for [left , right] in b:loaded
        for each in range(1, s:max)
            exe printf(cmd, 'op_lv'.each, b:operators, 'lv'.each)
            if b:operators != ""
                let str .= ',lv'.each
            endif
            exe printf(cmd2, 'lv'.each, 'lv'.each.'c', left, right, 'lv'.(each % s:max + 1), str, 'op_lv'.each)
        endfor
    endfor

    cal rainbow#activate()
endfunc

func! rainbow#clear()
    if exists('b:loaded')
        unlet b:loaded
        exe 'syn clear op_lv0'
        for each in range(1 , s:max)
            exe 'syn clear lv'.each
            exe 'syn clear op_lv'.each
        endfor
    endif
endfunc

func! rainbow#activate()
    if !exists('b:loaded')
        cal rainbow#load()
    endif
    exe 'hi default op_lv0 ctermfg='.s:ctermfgs[-1].' guifg='.s:guifgs[-1]
    for id in range(1 , s:max)
        let ctermfg = s:ctermfgs[(s:max - id) % len(s:ctermfgs)]
        let guifg = s:guifgs[(s:max - id) % len(s:guifgs)]
        exe 'hi default lv'.id.'c ctermfg='.ctermfg.' guifg='.guifg
        exe 'hi default op_lv'.id.' ctermfg='.ctermfg.' guifg='.guifg
    endfor
    exe 'syn sync fromstart'
    let b:active = 'active'
endfunc

func! rainbow#inactivate()
    if exists('b:active')
        exe 'hi clear op_lv0'
        for each in range(1, s:max)
            exe 'hi clear lv'.each.'c'
            exe 'hi clear op_lv'.each.''
        endfor
        exe 'syn sync fromstart'
        unlet b:active
    endif
endfunc

func! rainbow#toggle()
    if exists('b:active')
        cal rainbow#inactivate()
    else
        cal rainbow#activate()
    endif
endfunc

if exists('g:rainbow_load_separately')
    let ps = g:rainbow_load_separately
    for i in range(len(ps))
        if len(ps[i]) < 3
            exe printf('au syntax,colorscheme %s call rainbow#load(ps[%d][1])' , ps[i][0] , i)
        else
            exe printf('au syntax,colorscheme %s call rainbow#load(ps[%d][1] , ps[%d][2])' , ps[i][0] , i , i)
        endif
    endfor
else
    au syntax,colorscheme * call rainbow#load()
endif

command! RainbowToggle call rainbow#toggle()
command! RainbowLoad call rainbow#load()
