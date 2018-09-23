" vimrc ------------------------------------------------------------------------
"
" See README.md for setup and basic history
"
" tips:
"  http://rayninfo.co.uk/vimtips.html (copied locally)
"  https://github.com/romainl/idiomatic-vimrc/blob/master/idiomatic-vimrc.vim
"
" nice digraph help page:
"  :help digraph-table
"
" ▶ ◀  ► ◄  ▸ ◂
" 🔒  🔑  + ∄ ⎇  Ξ

filetype off
"packloadall " normally done after loading vimrc, uncomment to load earlier
filetype plugin indent on
syntax on

let mapleader=","
let maplocalleader=","

" base options, other options are (re)set below
source $HOME/.vim/vimrc.opts

" behavior ---------------------------------------------------------------------

" make sure vim returns to the same line when you reopen a file
augroup line_return
	au!
	au BufReadPost *
		\ if line("'\"") > 0 && line("'\"") <= line("$") |
		\     execute 'normal! g`"zvzz' |
		\ endif
augroup END

" save all buffers when focus is lost
au FocusLost * :silent! wa

" treat buffers from stdin (e.g.: echo foo | vim -) as scratch
au StdinReadPost * :set buftype=nofile

" the . to execute once for each line of a visual selection
vnoremap . :normal .<CR>
" and same for macros
vnoremap <Leader>@ :normal @

" don't move on first *
nnoremap <silent> * :let stay_star_view=winsaveview()<CR>*:call winrestview(stay_star_view)<CR>

" resize panes when window/terminal gets resize
au VimResized * :wincmd =

" folding is overrated imo
set foldlevelstart=0
set foldtext=MyFoldText()
" recursively open whatever fold we're in
nnoremap zO zczO

function! MyFoldText()
	let line=getline(v:foldstart)

	let nucolwidth=&fdc + &number * &numberwidth
	let windowwidth=winwidth(0) - nucolwidth - 3
	let foldedlinecount=v:foldend - v:foldstart

	" expand tabs into spaces
	let onetab=strpart('          ', 0, &tabstop)
	let line=substitute(line, '\t', onetab, 'g')

	let line=strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
	let fillcharcount=windowwidth - len(line) - len(foldedlinecount)
	return line . '…' . repeat(" ",fillcharcount) . foldedlinecount . '…' . ' '
endfunction


" mappings ---------------------------------------------------------------------

" fuck you apple for taking away the physical ESC key
" tried various mappings, using karabiner w/ cmd key combos for now
" always works: <c-[> and <c-c>

" toggle options
nnoremap <Leader>S :setlocal spell!<CR>
nnoremap <Leader>N :setlocal number!<CR>
nnoremap <Leader>P :set paste!<CR>

" natural move
nnoremap <down> gj
nnoremap <up> gk

" keep the cursor in place while joining lines
nnoremap J mzJ`z
" split line (sister to [J]oin lines)
nnoremap S i<CR><Esc>^mwgk:silent! s/\v +$//<CR>:noh<CR>`w

" add to local dictionary
nnoremap zg 2zg
nnoremap zG 1zg

" display the number of matches for the last search
nmap <Leader>/ :%s:<C-R>/::gn<CR>

nnoremap <Leader>L :call FocusLine()<CR>

" half/double spaces, clear trailing spaces
noremap <Leader>W1 mz:%s;^\(\s\+\);\=repeat('	', len(submatch(0))/2);<CR>:%s/\s\+$//<CR>:let @/=''<CR>`z
noremap <Leader>W2 mz:%s;^\(\s\+\);\=repeat('	', len(submatch(0))*2);<CR>:%s/\s\+$//<CR>:let @/=''<CR>`z
noremap <Leader>W0 mz:set ts=4 sts=4 et<CR>:retab<CR>:set ts=8 sts=2 noet<CR>:%s;^\(\s\+\);\=repeat('	', len(submatch(0))/2);<CR>:%s/\s\+$//<CR>:let @/=''<CR>`z

" clean trailing whitespace in entire file
nnoremap <Leader>WW mz:%s/\s\+$//<CR>:let @/=''<CR>`z

" zip right, this should preserve your last yank/delete as well
nnoremap zl :let @z=@"<CR>x$p:let @"=@z<CR>

" underline the current line
nnoremap <Leader>1 yypVr=

" uppercase word in insert mode
inoremap <C-u> <Esc>mzgUiw`za

" panic
nnoremap <F9> mzggg?G`z

command! RemoveFancyCharacters :call RemoveFancyCharacters()

" show syntax group(s)
nmap <Leader>ss :call <SID>SynStack()<CR>
" show highlight group(s)
nnoremap <Leader>SS :echo "hi<"
	\ . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
	\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
	\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

nnoremap <silent> <Leader>h0 :call ClearInterestingWords()<CR>
nnoremap <silent> <Leader>h1 :call HiInterestingWord(1)<CR>
nnoremap <silent> <Leader>h2 :call HiInterestingWord(2)<CR>
nnoremap <silent> <Leader>h3 :call HiInterestingWord(3)<CR>
nnoremap <silent> <Leader>h4 :call HiInterestingWord(4)<CR>
nnoremap <silent> <Leader>h5 :call HiInterestingWord(5)<CR>
nnoremap <silent> <Leader>h6 :call HiInterestingWord(6)<CR>

" listchars
nnoremap <Leader>I :set listchars+=tab:⋮\ <CR>
nnoremap <Leader>i :set listchars-=tab:⋮\ <CR>
"nnoremap <Leader>I :set listchars+=tab:▸‧<CR>
"nnoremap <Leader>i :set listchars-=tab:▸‧<CR>

" select (charwise) the contents of the current line, excluding indentation.
nnoremap vv ^vg_

" custom copy/paste using tmp file
vmap <Leader>C :w! ~/.tmp/.pbuf<CR>
nmap <Leader>V :r ~/.tmp/.pbuf<CR>

" quickfix
noremap <Leader>co :copen<CR>zvzz
noremap <Leader>cc :ccl<CR>zvzz
noremap ]q :cnext<CR>
noremap [q :cprev<CR>

" tags https://github.com/grassdog/dotfiles/blob/master/files/.ctags

" switch with last buffer
nnoremap <silent> <Space><Space> <C-^>
nnoremap <silent> <C-n> :bp<CR>
nnoremap <silent> <C-p> :bn<CR>

" easy buffer navigation, save current buffer
noremap <silent> <C-h> <C-w>h:call PulseCursorLine()<CR>
noremap <silent> <C-j> <C-w>j:call PulseCursorLine()<CR>
noremap <silent> <C-k> <C-w>k:call PulseCursorLine()<CR>
noremap <silent> <C-l> <C-w>l:call PulseCursorLine()<CR>

" navigation via fzf (fzf opts/mappings below)
nmap <Leader>, :Buffers<CR>
nmap <Leader><Space> :Files<CR>
nmap <Leader>t :Tags<CR>
nmap <Leader>f :Find<CR>
" https://medium.com/@crashybang/supercharge-vim-with-fzf-and-ripgrep-d4661fc853d2
command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1, <bang>0)

" mkdir dir(s) that contains the file in the current buffer
nnoremap <Leader>MD :!mkdir -p %:p:h<CR>


" functions --------------------------------------------------------------------

" Focus/pulse the current line wiping out z mark, moves line 25 above center.
" Closes all folds and opens the folds containing the current line.

function! FocusLine()
    let oldscrolloff = &scrolloff
    set scrolloff=0
    execute "keepjumps normal! mzzMzvzt25\<c-y>`z:call PulseCursorLine()\<CR>"
    let &scrolloff = oldscrolloff
endfunction

" Pulse cursor line
" https://github.com/JessicaKMcIntosh/Vim/blob/master/plugin/pulse.vim

hi CursorLine guibg=NONE ctermbg=NONE

"if has("termguicolors") || has('gui_running')
if has('gui_running')
	let g:PulseColorList=['#ff0000','#00ff00','#0000ff','#ff0000']
	"let g:PulseColorList=['#2a2a2a','#333333','#3a3a3a','#444444','#4a4a4a' ]
	let g:PulseColorattr='guibg'
else
	let g:PulseColorList=['160','40','123','160']
	"let g:PulseColorList=['233','234','235','236','237']
	let g:PulseColorattr='ctermbg'
endif

function! PulseCursorLine()
	set cursorline
	for pulse in g:PulseColorList
		execute 'hi CursorLine ' . g:PulseColorattr . '=' . pulse
		redraw
		sleep 12m
	endfor
	"for pulse in reverse(copy(g:PulseColorList))
	"	execute 'hi CursorLine ' . g:PulseColorattr . '=' . pulse
	"	redraw
	"	sleep 9m
	"endfor
	execute 'hi CursorLine ' . g:PulseColorattr . '=NONE'
	set nocursorline
endfunction


function! <SID>SynStack()
	echo join(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'), " > ")
endfunc


function! RemoveFancyCharacters()
	let typo={}
	let typo["“"]='"'
	let typo["”"]='"'
	let typo["‘"]="'"
	let typo["’"]="'"
	let typo["–"]='--'
	let typo["—"]='---'
	let typo["…"]='...'
	:exe ":%s/".join(keys(typo), '\|').'/\=typo[submatch(0)]/ge'
endfunction


" Highlight words temporarily
" http://vim.wikia.com/wiki/Highlight_multiple_words

hi def InterestingWord1 guifg=#000000 ctermfg=16 guibg=#aeee00 ctermbg=154
hi def InterestingWord2 guifg=#000000 ctermfg=16 guibg=#ff9eb8 ctermbg=211
hi def InterestingWord3 guifg=#000000 ctermfg=16 guibg=#ffa724 ctermbg=214
hi def InterestingWord4 guifg=#000000 ctermfg=16 guibg=#b88853 ctermbg=137
hi def InterestingWord5 guifg=#000000 ctermfg=16 guibg=#8cffba ctermbg=121
hi def InterestingWord6 guifg=#000000 ctermfg=16 guibg=#ff2c4b ctermbg=195

function! HiInterestingWord(n)
	" Save our location.
	normal! mz

	" Yank the current word into the z register.
	normal! "zyiw

	" Calculate an arbitrary match ID.  Hopefully nothing else is using it.
	let mid=86750 + a:n

	" Clear existing matches, but don't worry if they don't exist.
	silent! call matchdelete(mid)

	" Construct a literal pattern that has to match at boundaries.
	let pat='\V\<' . escape(@z, '\') . '\>'

	" Actually match the words.
	call matchadd("InterestingWord" . a:n, pat, 1, mid)

	" Move back to our original location.
	normal! `z
endfunction

function! ClearInterestingWords()
	silent! call matchdelete(86751)
	silent! call matchdelete(86752)
	silent! call matchdelete(86753)
	silent! call matchdelete(86754)
	silent! call matchdelete(86755)
	silent! call matchdelete(86756)
endfunction


" abbrev helpers

function! EatChar(pat)
	let c=nr2char(getchar(0))
	return (c =~ a:pat) ? '' : c
endfunction

function! MakeSpacelessIabbrev(from, to) " global
	execute "iabbrev <silent> ".a:from." ".a:to."<C-R>=EatChar('\\s')<CR>"
endfunction

function! MakeSpacelessBufferIabbrev(from, to) " buffer local
	execute "iabbrev <silent> <buffer> ".a:from." ".a:to."<C-R>=EatChar('\\s')<CR>"
endfunction


" settings/plugins -------------------------------------------------------------

set complete=.,w,b,u,t,i
set completeopt=menuone,preview

" complete-functions ins-completion
inoremap <C-]> <C-x><C-]>
" http://tilvim.com/2016/01/06/fzf.html
imap <C-l> <Plug>(fzf-complete-line)

" supertab
let g:SuperTabDefaultCompletionType="context"
let g:SuperTabMappingForward='<C-n>'
let g:SuperTabMappingBackward='<C-p>'
let g:SuperTabClosePreviewOnPopupClose=1

" fzf
set rtp+=~/bin/.fzf

" ack
let g:ackprg='rg --vimgrep --smart-case --no-heading'
"let g:ackprg='ag --vimgrep'
let g:ack_apply_qmappings=1
let g:ackhighlight=1

nnoremap <Leader>G :Ack!<Space>""<left>
xnoremap <Leader>G y:Ack!<Space>"<C-r>""
xnoremap <silent> <Leader>g y:Ack!<Space>"<C-r>"" -w<CR>

" The directory for where bookmarks and history are saved (as .netrwbook and .netrwhist)
let g:netrw_home='$HOME/.tmp'

" Kwbd
nmap <Leader>q <Plug>Kwbd

" `%%` is (command mode) abbrev for current directory
cabbr <expr> %% expand('%:p:h')

" http://eclim.org/vim/core/eclim.html
let g:EclimQuickfixSignText='▴'
let g:EclimLoclistSignText='➞' " https://unicode-table.com/en/sets/arrows-symbols/

let g:EclimHighlightError='ErrorMsg'     " (Default: “Error”)
let g:EclimHighlightWarning='WarningMsg' " (Default: “WarningMsg”)
let g:EclimHighlightInfo='Statement'     " (Default: “Statement”)
let g:EclimHighlightDebug='Normal'       " (Default: “Normal”)
let g:EclimHighlightTrace='Normal'       " (Default: “Normal”)

" eclim mappings
au FileType java nnoremap <buffer> <silent> <Leader>v :silent! w<CR>:Validate<CR>
au FileType java inoremap <buffer> <silent> <Leader>v <Esc>:silent! w<CR>:Validate<CR>
au FileType java nnoremap <silent> <Leader>jc :JavaCorrect<CR>
au FileType java nnoremap <silent> <Leader>jd :JavaDocSearch -x declarations<CR>
au FileType java nnoremap <silent> <Leader>jh :JavaCallHierarchy<CR>
au FileType java nnoremap <silent> <Leader>ji :JavaImport<CR>
au FileType java nnoremap <silent> <Leader>jI :JavaImportOrganize<CR>

" clam
let g:clam_autoreturn=1
let g:clam_debug=1
let g:clam_winpos='botright'

nnoremap ! :Clam<Space>
vnoremap ! :ClamVisual<Space>

" dadbod
" dbext
let g:dbext_default_prompt_for_parameters=0 " globally turn off input prompt
let g:dbext_default_buffer_lines=27 " size of Result buffer window (default is 5)
let g:dbext_default_history_file='$HOME/.tmp/.dbext_history'
let g:dbext_default_type='PGSQL'
let g:dbext_default_profile_pg='type=PGSQL:user=postgres:passwd='

" fugitive
au BufNewFile,BufRead .git/index setlocal nolist

" nerdtree
noremap  <F2> :NERDTreeToggle<CR>
inoremap <F2> <Esc>:NERDTreeToggle<CR>
augroup ps_nerdtree
	au!
	au Filetype nerdtree setlocal nolist
	au Filetype nerdtree nnoremap <buffer> H :vertical resize -10<CR>
	au Filetype nerdtree nnoremap <buffer> L :vertical resize +10<CR>
	"au Filetype nerdtree nnoremap <buffer> K :q<CR>
augroup END
let g:NERDTreeDirArrowExpandable='▸'
let g:NERDTreeDirArrowCollapsible='▾'
let NERDTreeHighlightCursorline=1
let NERDTreeIgnore=[
	\ '\~$',
	\ '.*\.pyc$', 'pip-log\.txt$',
	\ '.*.pid', 'monitor.py',
	\ '.*\.o$', '.*\.pdf$', '.*\.idocx$',
	\ '^tags$',
	\ '.*\.class$']
let NERDTreeMinimalUI=1
let NERDTreeChDirMode=2
let NERDTreeMapJumpFirstChild='gK'
"let NERDTreeDirArrows = 1
"let NERDChristmasTree = 1

" ale
"let g:ale_lint_on_save=1
"let g:ale_lint_on_text_changed=0
"let g:ale_lint_on_enter=0

"let g:ale_pattern_options = {
"\	'.*\.json$': {'ale_enabled': 0},
"\	'.*\.js$': {'ale_enabled': 0},
"\	'.*\.html$': {'ale_enabled': 0},
"\}
"\	'\.foo\.js$': { 'ale_linters': {'javascript': ['eslint']}, },

"let g:ale_sign_error='>>'
"let g:ale_sign_warning='>'
let g:ale_sign_error = '•'
let g:ale_sign_warning = '•'

"let g:ale_echo_msg_error_str='E'
"let g:ale_echo_msg_warning_str='W'
"let g:ale_echo_msg_format='[%linter%] %s [%severity%]'

"nmap <silent> <Leader>k <Plug>(ale_previous_wrap)
"nmap <silent> <Leader>j <Plug>(ale_next_wrap)


" filetype/plugins -------------------------------------------------------------

" highlight VCS conflict markers
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

au Filetype qf setlocal number colorcolumn=0 nolist nowrap tw=0 scrolloff=1

autocmd FileType diff setlocal foldmethod=expr
autocmd FileType diff setlocal foldexpr=DiffFoldLevel()

" https://github.com/sgeb/vim-diff-fold/ without the extra settings crap. Ie just the folding expr
function! DiffFoldLevel()
	let l:line=getline(v:lnum)

	if l:line =~# '^\(diff\|Index\)'     " file
		return '>1'
	elseif l:line =~# '^\(@@\|\d\)'  " hunk
		return '>2'
	elseif l:line =~# '^\*\*\* \d\+,\d\+ \*\*\*\*$' " context: file1
		return '>2'
	elseif l:line =~# '^--- \d\+,\d\+ ----$' " context: file2
		return '>2'
	else
		return '='
	endif
endfunction


" JSON formating is generally useful, jq leaves order and is fast, py is slow and sorts the keys
vnoremap <leader>j :!jq '.'<CR>
vnoremap <leader>J :!python -mjson.tool<CR>

augroup ft_text
	au!
	au Filetype text setlocal spell
	au FileType text setlocal textwidth=100
augroup END

augroup ft_vim
	au!
	au FileType vim inoremap <c-n> <c-x><c-n>
augroup END

augroup ft_java
	au!
	au FileType java setlocal foldmethod=marker
	au FileType java setlocal foldmarker={{{,}}}

	au FileType java call MakeSpacelessBufferIabbrev('LOG.', 'private static final Logger LOG = LogManager.getLogger();<left><left>')

	au FileType java call MakeSpacelessBufferIabbrev('pr.', 'org.apache.logging.log4j.LogManager.getLogger(this.getClass()).info(">>> {}", );<left><left>')
	au FileType java call MakeSpacelessBufferIabbrev('slf.', 'org.slf4j.LoggerFactory.getLogger(this.getClass()).info(">>> {}", );<left><left>')
	au FileType java call MakeSpacelessBufferIabbrev('sb.', 'org.apache.commons.lang3.builder.ReflectionToStringBuilder.toString()<left>')

	let g:ale_linters={'java': []}
augroup END

augroup ft_javascript
	au!
	au FileType javascript call MakeSpacelessBufferIabbrev('pr.', "console.log('>>> ', );<left><left>")
augroup END

augroup ft_python
	au!
	au FileType python setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=110
	au FileType python setlocal nowrap
	au FileType python setlocal define=^\s*\\(def\\\\|class\\)

	au FileType python nnoremap <localleader>e :w<CR>:Clam python %:p<CR>
	au FileType python nnoremap <localleader>E :w<CR>:Clam python <C-R>=expand("%:p")<CR>

	" yapf doesn't work w/ gq generally (only formats complete blocks)
	let g:yapf_style="pep8"
	au FileType python nnoremap <buffer> <localleader>p ^vg_:!yapf<CR>
	au FileType python vnoremap <buffer> <localleader>p :!yapf<CR>

	au FileType python call MakeSpacelessBufferIabbrev('pr.', "print(f'>>> {}')<left><left><left>")
augroup END

augroup ft_postgres
	au!
	au BufNewFile,BufRead *.sql set filetype=pgsql
	au BufNewFile,BufRead *.pgsql set filetype=pgsql

	au FileType pgsql setlocal foldmethod=marker
	au FileType pgsql setlocal foldmarker={{{,}}}

	au FileType pgsql setlocal commentstring=--\ %s comments=:--

	" send to tmux with localleader e
	"au FileType pgsql nnoremap <buffer> <silent> <localleader>e :let psql_tslime_view=winsaveview()<CR>vip"ry:call SendToTmux(@r)<CR>:call winrestview(psql_tslime_view)<CR>

	" kill pager with q
	"au FileType pgsql nnoremap <buffer> <silent> <localleader>q :call SendToTmuxRaw("q")<CR>
augroup END

augroup ft_html
	au!
	au FileType markdown setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab textwidth=100
	au Filetype markdown nnoremap <buffer> <localleader>p :w<CR>:!open %<CR>
augroup END

augroup ft_markdown
	au!
	au Filetype markdown setlocal spell
	au FileType markdown setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=100
	au Filetype markdown nnoremap <buffer> <localleader>p :w<CR>:!gfm % \|bcat<CR>
augroup END

augroup ft_json
	au!
	au FileType json setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab

	au FileType json setlocal formatprg=jq\ '.'
augroup END

augroup ft_xml
	au!
	au FileType xml setlocal foldmethod=manual
	" use <localleader>F to fold the current tag
	au FileType xml nnoremap <buffer> <localleader>F Vatzf
	" Indent tag
	au FileType xml nnoremap <buffer> <localleader>= Vat=
augroup END

augroup ft_yaml
	au!
	au FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
augroup END

augroup ft_muttrc
	au!
	au BufRead,BufNewFile *.muttrc set ft=muttrc
	au FileType muttrc setlocal foldmethod=marker foldmarker={{{,}}}
augroup END

" clojure/fireplace/paredit -----

let g:clojure_fold_extra=[
            \ 'defgauge',
            \ 'defsketch'
	\ ]

let g:fireplace_no_maps=1

let g:paredit_smartjump=1
let g:paredit_shortmaps=0
let g:paredit_electric_return=1
let g:paredit_disable_lisp=1
let g:paredit_matchlines=200

augroup ft_clojure
	au!

	au BufNewFile,BufRead *.edn set filetype=clojure

	au FileType clojure silent! call TurnOnClojureFolding()
	au FileType clojure compiler clojure
	au FileType clojure setlocal isk-=.

	au FileType clojure iabbrev <buffer> defun defn

	" Things that should be indented 2-spaced
	au FileType clojure setlocal lispwords+=when-found,defform,when-valid,try,while-let,try+,throw+

	au FileType clojure RainbowParenthesesActivate
	au syntax clojure RainbowParenthesesLoadRound

	" Paredit
	au FileType clojure call EnableParedit()
	au FileType clojure nnoremap <buffer> <localleader>( :call PareditToggle()<cr>
	" )

	" Duplicate
	au FileType clojure nnoremap <buffer> [] :call DuplicateLispForm()<cr>

	" Indent top-level form.
	au FileType clojure nmap <buffer> gi mz99[(v%='z
augroup END

function! EnableParedit()
	call PareditInitBuffer()

	" Quit fucking with my split-line mapping, paredit.
	nunmap <buffer> S

	" Also quit fucking with my save file mapping.
	nunmap <buffer> s

	" Please just stop
	nunmap <buffer> <leader>W
	nunmap <buffer> <leader>O
	nunmap <buffer> <leader>S

	" Oh my god will you fuck off already
	" nnoremap <buffer> dp :diffput<cr>
	" nnoremap <buffer> do :diffobtain<cr>

	" Eat shit
	nunmap <buffer> [[
	nunmap <buffer> ]]

	" Better mappings
	noremap <buffer> () :<c-u>call PareditWrap("(", ")")<cr>
	noremap <buffer> )( :<c-u>call PareditSplice()<cr>
	noremap <buffer> (( :<c-u>call PareditMoveLeft()<cr>
	noremap <buffer> )) :<c-u>call PareditMoveRight()<cr>
	noremap <buffer> (j :<c-u>call PareditJoin()<cr>
	noremap <buffer> (s :<c-u>call PareditSplit()<cr>
	noremap <buffer> )j :<c-u>call PareditJoin()<cr>
	noremap <buffer> )s :<c-u>call PareditSplit()<cr>
	" ))
endfunction


" ui/colorscheme ---------------------------------------------------------------
" note, other config/plugins can change the colors

set mouse=a

" show trailing spaces in non-insert mode
augroup trailing
	au!
	au InsertEnter * :set listchars-=trail:⌴
	au InsertLeave * :set listchars+=trail:⌴
augroup END

" lightline

let g:lightline = {
	\ 'colorscheme': 'my',
	\ 'separator': { 'left': '', 'right': '' },
	\ 'subseparator': { 'left': '│', 'right': '⋮' }
	\ }

" ----- colors/highlights/cursors

set notermguicolors " not available for terminal :(
hi Comment gui=italic cterm=italic
hi SpellBad cterm=undercurl,italic guifg=#d33682

" 117 matches lightline (also can use 24, 31)
autocmd InsertEnter * hi ColorColumn ctermbg=117 guibg=#87dfff
autocmd InsertLeave * hi ColorColumn ctermbg=7 guibg=#eee8d5

function! ColorSet(...)
	if a:0 > 0
		execute 'colorscheme ' . a:1
	endif

	" NonText for [eol, extends, precedes]; SpecialKey for [nbsp, tab, trail]
	hi! link SignColumn LineNr
	" ale
	hi! link ALEErrorSign ErrorMsg
	hi! link ALEWarningSign WarningMsg
endfunction
function! ColorSolarized()
	" for terminal.app, use https://github.com/tomislav/osx-terminal.app-colors-solarized
	let g:solarized_contrast='normal' " normal/high/low
	let g:solarized_visibility='low'  " normal/high/low
	colorscheme solarized
	if &background == 'light'
		hi SpecialKey ctermfg=6 guifg=#ded8b5
		hi NonText ctermfg=178 guifg=#ffd885
		hi WarningMsg ctermbg=7 guibg=#eee8d5
	else
		hi SpecialKey ctermfg=10 guifg=#586e75
		hi NonText ctermfg=10 guifg=#4996a2
		"hi SignColumn ctermbg=0 guibg=#073642
	endif
	call ColorSet()
endfunction
function! ColorNord()
	call ColorSet('nord')
	hi! link SignColumn Folded
endfunction
function! ColorIceberg()
	call ColorSet('iceberg')
	" reverse ErrorMsg
	hi ErrorMsg guibg=#e27878 guifg=#161821
	hi SpecialKey guifg=#444b71
	hi NonText guifg=#89b8c2
endfunction
function! ColorToNBlue()
	call ColorSet('Tomorrow-Night-Blue')
	hi SpecialKey ctermfg=67 guifg=#7285b7
	hi NonText ctermfg=14 guifg=Yellow
	hi LineNr ctermbg=19 ctermfg=67 guifg=#7285b7
endfunction

if &diff
	" better diff colorscheme
	colorscheme Tomorrow-Night
else
	if $TERM_PROFILE == 'Ocean'
		set background=dark
		call ColorToNBlue()
	elseif $TERM_PROFILE == 'Silver_Aerogel'
		set background=light
		call ColorNord()
	else
		set background=light
		call ColorSolarized()
	endif
endif

if has("gui_macvim")
	set guifont=SF\ Mono:h10'
	"set guifont=IBM\ Plex\ Mono:h11'

	set blurradius=15
	au FocusLost * :set transparency=15
	au FocusGained * :set transparency=0
endif

set guicursor=n-c:block-Cursor-blinkon0
set guicursor+=v:block-blinkon0
set guicursor+=i-ci:ver20
set guioptions=egm

" enable cursor change in tmux mode
if exists('$TMUX')
	let &t_SI="\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
	let &t_EI="\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
	let &t_SI="\<Esc>]50;CursorShape=1\x7"
	let &t_EI="\<Esc>]50;CursorShape=0\x7"
endif

" italics
" https://www.reddit.com/r/vim/comments/24g8r8/italics_in_terminal_vim_and_tmux/
" https://apple.stackexchange.com/a/267261
set t_ZH=[3m
set t_ZR=[23m

" http://vim.wikia.com/wiki/Change_cursor_shape_in_different_modes
" DECSCUSR 1/2, 3/4, 5/6 -> blinking/steady block, underline, bar
let &t_SI.="\e[5 q"
let &t_EI.="\e[2 q"

" http://vim.wikia.com/wiki/Xterm256_color_names_for_console_Vim
function! CtermColors()
	let num = 255
	while num >= 0
		exec 'hi col_'.num.' ctermbg='.num.' ctermfg=white'
		exec 'syn match col_'.num.' "ctermbg='.num.':...." containedIn=ALL'
		call append(0, 'cterm='.num.':....')
		let num = num - 1
	endwhile
endfunction