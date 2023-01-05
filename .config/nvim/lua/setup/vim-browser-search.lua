vim.api.nvim_set_var("browser_search_engines", {
	crates = "https://crates.io/keywords/%s",
  null_ls = "https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md?%s",
})
--      Default will extend with above
--      {
--        \ 'baidu':'https://www.baidu.com/s?ie=UTF-8&wd=%s',
--        \ 'bing': 'https://www.bing.com/search?q=%s',
--        \ 'duckduckgo': 'https://duckduckgo.com/?q=%s',
--        \ 'github':'https://github.com/search?q=%s',
--        \ 'google':'https://google.com/search?q=%s',
--        \ 'stackoverflow':'https://stackoverflow.com/search?q=%s',
--        \ 'translate': 'https://translate.google.com/?sl=auto&tl=it&text=%s',
--        \ 'wikipedia': 'https://en.wikipedia.org/wiki/%s',
--        \ 'youtube':'https://www.youtube.com/results?search_query=%s&page=&utm_source=opensearch',
--    \ }
