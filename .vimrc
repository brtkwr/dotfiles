syntax on

" Use new regular expression engine
set re=0

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

" Default tabstop
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
autocmd FileType typescript setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
autocmd FileType svelte setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab

" Do not slurp to clipboard when using d to delete
nnoremap d "_d
vnoremap d "_d

" Load plugins
call plug#begin('~/.vim/plugged')
Plug 'pangloss/vim-javascript'
Plug 'evanleck/vim-svelte', {'branch': 'main'}
call plug#end()
