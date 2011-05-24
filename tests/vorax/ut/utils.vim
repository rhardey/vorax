let s:ut_dir = expand('<sfile>:h')

function! TestVoraxUtilsSortUnique()
  " test sorts
  call VUAssertEquals(voraxlib#utils#SortUnique([3, 3, 1, 2]), ['1', '2', '3'], ': Test SortUnique() 1')
  call VUAssertTrue(voraxlib#utils#SortUnique(['a', 'b', 'a', 'd', 'd', 'c']) == ['a', 'b', 'c', 'd'], ': Test SortUnique() 2')
endfunction

function! TestVoraxUtilsFlattenList()
  " test FlattenList
  call VUAssertTrue(voraxlib#utils#FlattenList([1, 2, [3, [4, 5], 7], 8]) == [1, 2, 3, 4, 5, 7, 8], ': Test FlattenList() 1')
  call VUAssertTrue(voraxlib#utils#FlattenList([1, [1, 1], 2]) == [1, 1, 1, 2], ': Test FlattenList() 2')
endfunction

function! TestVoraxUtilsAddUnique()
  " test AddUnique
  let list = [1, 2, 3]
  call voraxlib#utils#AddUnique(list, 1)
  call VUAssertTrue(list == [1, 2, 3], ': Test AddUnique() 1')
  call voraxlib#utils#AddUnique(list, 4)
  call VUAssertTrue(list == [1, 2, 3, 4], ': Test AddUnique() 2')
endfunction

function! TestVoraxUtilsLtrimSqlComments()
  " test remove comments from the head
  let cmd = "select /*+ hint*/ from cat;\n--muci\n/* ab\n c */"
  call VUAssertEquals(cmd, 
                    \ voraxlib#utils#LTrimSqlComments("\n\n--test\n/* c1 */\n/* a new \n comment */\n".cmd),
                    \ 'voraxlib#utils#LTrimSqlComments() test 1')
  call VUAssertEquals(cmd, 
                    \ voraxlib#utils#LTrimSqlComments("\r\n  \r\n".cmd),
                    \ 'voraxlib#utils#LTrimSqlComments() test 2')
  call VUAssertEquals(cmd, 
                    \ voraxlib#utils#LTrimSqlComments(cmd),
                    \ 'voraxlib#utils#LTrimSqlComments() test 3')
  call VUAssertEquals(cmd, 
                    \ voraxlib#utils#LTrimSqlComments('/* test */'.cmd),
                    \ 'voraxlib#utils#LTrimSqlComments() test 4')
endfunction

function! TestVoraxUtilsRTrimSqlComments()
  " test remove comments from the tail
  let cmd = "\n--muci\n/* ab\n c */\nselect /*+ hint */ * from cat;"
  call VUAssertEquals(cmd, 
                    \ voraxlib#utils#RTrimSqlComments(cmd."\n\n--test\n/* c1 */\n/* a new \n comment */\n"),
                    \ 'voraxlib#utils#RTrimSqlComments() test 1')
  call VUAssertEquals(cmd, 
                    \ voraxlib#utils#RTrimSqlComments(cmd."\r\n   \r\n"),
                    \ 'voraxlib#utils#RTrimSqlComments() test 2')
  call VUAssertEquals(cmd, 
                    \ voraxlib#utils#RTrimSqlComments(cmd),
                    \ 'voraxlib#utils#RTrimSqlComments() test 3')
  call VUAssertEquals(cmd, 
                    \ voraxlib#utils#RTrimSqlComments(cmd.'/* test */'),
                    \ 'voraxlib#utils#RTrimSqlComments() test 4')
endfunction

function! TestVoraxUtilsTrimSqlComments()
  " test trim comments
  let cmd = "\n--muci\n/* ab\n c */\nselect /*+ hint */ * from cat;--test\n/*comment 2*/"
  call VUAssertEquals('select /*+ hint */ * from cat;', 
                    \ voraxlib#utils#TrimSqlComments(cmd),
                    \ 'voraxlib#utils#TrimSqlComments() test 1')
endfunction

function! TestVoraxUtilsGetStartOfCurrentSql()
  silent exe 'split ' . s:ut_dir . '/../sql/under_cursor.sql'

  call setpos('.', [bufnr('%'), 1, 5, 0])
  let [l, c] = voraxlib#utils#GetStartOfCurrentSql(0)
  call VUAssertEquals([l, c], [1, 1], 'voraxlib#utils#GetStartOfCurrentSql test 1')

  call setpos('.', [bufnr('%'), 4, 28, 0])
  let [l, c] = voraxlib#utils#GetStartOfCurrentSql(1)
  call VUAssertEquals([l, c], [3, 1], 'voraxlib#utils#GetStartOfCurrentSql test 2')
  call VUAssertEquals([line('.'), col('.')], [3, 1], 'voraxlib#utils#GetStartOfCurrentSql test 3')

  call setpos('.', [bufnr('%'), 6, 40, 0])
  let [l, c] = voraxlib#utils#GetStartOfCurrentSql(0)
  call VUAssertEquals([l, c], [6, 10], 'voraxlib#utils#GetStartOfCurrentSql test 4')

  syntax clear
  try
    let [l, c] = voraxlib#utils#GetStartOfCurrentSql(0)
    call VUAsserFail('voraxlib#utils#Get...OfCurrentSql should not work without a syntax file.')
  catch /^A sql syntax must be enabled for the current buffer.$/
  endtry

  bwipe!
endfunction

function! TestVoraxUtilsGetEndOfCurrentSql()
  silent exe 'split ' . s:ut_dir . '/../sql/under_cursor.sql'

  call setpos('.', [bufnr('%'), 1, 1, 0])
  let [l, c] = voraxlib#utils#GetEndOfCurrentSql(0)
  call VUAssertEquals([l, c], [2, 1], 'voraxlib#utils#GetEndOfCurrentSql test 1')

  call setpos('.', [bufnr('%'), 3, 5, 0])
  let [l, c] = voraxlib#utils#GetEndOfCurrentSql(1)
  call VUAssertEquals([l, c], [4, 43], 'voraxlib#utils#GetEndOfCurrentSql test 2')
  call VUAssertEquals([line('.'), col('.')], [4, 43], 'voraxlib#utils#GetEndOfCurrentSql test 2')

  call setpos('.', [bufnr('%'), 5, 5, 0])
  let [l, c] = voraxlib#utils#GetEndOfCurrentSql(0)
  call VUAssertEquals([l, c], [6, 9], 'voraxlib#utils#GetEndOfCurrentSql test 3')

  call setpos('.', [bufnr('%'), 6, 9, 0])
  let [l, c] = voraxlib#utils#GetEndOfCurrentSql(0)
  call VUAssertEquals([l, c], [6, 9], 'voraxlib#utils#GetEndOfCurrentSql test 4')

  call setpos('.', [bufnr('%'), 6, 10, 0])
  let [l, c] = voraxlib#utils#GetEndOfCurrentSql(0)
  call VUAssertEquals([l, c], [6, 43], 'voraxlib#utils#GetEndOfCurrentSql test 5')

  call setpos('.', [bufnr('%'), 12, 8, 0])
  let [l, c] = voraxlib#utils#GetEndOfCurrentSql(0)
  call VUAssertEquals([l, c], [13, 9], 'voraxlib#utils#GetEndOfCurrentSql test 6')

  syntax clear
  try
    let [l, c] = voraxlib#utils#GetEndOfCurrentSql(0)
    call VUAsserFail('voraxlib#utils#Get...OfCurrentSql should not work without a syntax file.')
  catch /^A sql syntax must be enabled for the current buffer.$/
  endtry

  bwipe!
endfunction

function! TestVoraxUtilsGetTextFromRange()
  silent exe 'split ' . s:ut_dir . '/../sql/under_cursor.sql'

  call VUAssertEquals(voraxlib#utils#GetTextFromRange(6, 11, 6, 43), 'select /* ; */ '';'' ";" from dual;', 'voraxlib#utils#GetTextFromRange Test 1')
  call VUAssertEquals(voraxlib#utils#GetTextFromRange(7, 1, 11, 18), "select *\nfrom\ncat,\nmuci\nwhere rownum < 10;", 'voraxlib#utils#GetTextFromRange Test 2')
  call VUAssertEquals(voraxlib#utils#GetTextFromRange(1, 1, 1, 1), "s", 'voraxlib#utils#GetTextFromRange Test 3')

  bwipe!
endfunction

function! TestVoraxUtilsExtractLines()
  let text = "line1\nline2\nline3\nline4\nline5\nline6\nline7"
  call VUAssertEquals(voraxlib#utils#ExtractLines(text, 1, 2), "line1\nline2\n", "voraxlib#utils#ExtracLines test 1")
  call VUAssertEquals(voraxlib#utils#ExtractLines(text, 2, 1), "line2\n", "voraxlib#utils#ExtracLines test 2")
  call VUAssertEquals(voraxlib#utils#ExtractLines(text, 2, 3), "line2\n\line3\nline4\n", "voraxlib#utils#ExtracLines test 3")
  call VUAssertEquals(voraxlib#utils#ExtractLines(text, 1, 1), "line1\n", "voraxlib#utils#ExtracLines test 4")
  call VUAssertEquals(voraxlib#utils#ExtractLines(text, 1, 0), "", "voraxlib#utils#ExtracLines test 5")
  call VUAssertEquals(voraxlib#utils#ExtractLines(text, 7, 1), "line7", "voraxlib#utils#ExtracLines test 6")
  call VUAssertEquals(voraxlib#utils#ExtractLines(text, 6, 2), "line6\nline7", "voraxlib#utils#ExtracLines test 7")
  call VUAssertEquals(voraxlib#utils#ExtractLines(text, 6, 1), "line6\n", "voraxlib#utils#ExtracLines test 8")
  call VUAssertEquals(voraxlib#utils#ExtractLines(text, 6, 10), "line6\nline7", "voraxlib#utils#ExtracLines test 9")
  let text = "line1\r\nline2\r\nline3\r\nline4\r\nline5\r\nline6\r\nline7"
  call VUAssertEquals(voraxlib#utils#ExtractLines(text, 6, 10), "line6\r\nline7", "voraxlib#utils#ExtracLines test 10")
  call VUAssertEquals(voraxlib#utils#ExtractLines(text, 1, 1), "line1\r\n", "voraxlib#utils#ExtracLines test 11")
endfunction

function! TestVoraxUtilsCountMatch()
  call VUAssertEquals(voraxlib#utils#CountMatch("line1\nline2\nline3\nline4", '\n'), 3, "Test 1")
  call VUAssertEquals(voraxlib#utils#CountMatch("line1\nline2\nline3\nline4", 'l'), 4, "Test 2")
endfunction