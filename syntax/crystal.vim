" Language: Crystal
" Maintainer: rhysd <https://rhysd.github.io>
"
" Based on Ruby syntax highlight
" which was made by Mirko Nasato and Doug Kearns
" ----------------------------------------------

" Prelude
if exists('b:current_syntax')
  finish
endif

" eCrystal Config
if exists('g:main_syntax') && g:main_syntax ==# 'ecrystal'
  let b:crystal_no_expensive = 1
end

" Folding Config
if has('folding') && exists('g:crystal_fold')
  setlocal foldmethod=syntax
endif

let s:foldable_groups = split(
      \   get(
      \     b:,
      \     'crystal_foldable_groups',
      \     get(g:, 'crystal_foldable_groups', 'ALL')
      \   )
      \ )

function! s:foldable(...) abort
  if index(s:foldable_groups, 'NONE') > -1
    return 0
  endif

  if index(s:foldable_groups, 'ALL') > -1
    return 1
  endif

  for l:i in a:000
    if index(s:foldable_groups, l:i) > -1
      return 1
    endif
  endfor

  return 0
endfunction

function! s:run_syntax_fold(args) abort
  let [_0, _1, groups, cmd; _] = matchlist(a:args, '\(["'']\)\(.\{-}\)\1\s\+\(.*\)')
  if call('s:foldable', split(groups))
    let cmd .= ' fold'
  endif
  exe cmd
endfunction

com! -nargs=* SynFold call s:run_syntax_fold(<q-args>)

" Not-Top Cluster
syn cluster crystalNotTop contains=@crystalExtendedStringSpecial,@crystalRegexpSpecial,@crystalDeclaration,crystalConditional,crystalExceptional,crystalMethodExceptional,crystalTodo,crystalLinkAttr

" Macro
syn region crystalMacroRegion matchgroup=crystalMacroDelim start="\\\={%" end="%}" oneline display contains=ALLBUT,@crystalNotTop containedin=ALL
syn region crystalMacroRegion matchgroup=crystalMacroDelim start="\\\={{" end="}}" oneline display contains=ALLBUT,@crystalNotTop containedin=ALL

" Whitespace Errors
if exists('g:crystal_space_errors')
  if !exists('g:crystal_no_trail_space_error')
    syn match crystalSpaceError display excludenl "\s\+$"
  endif
  if !exists('g:crystal_no_tab_space_error')
    syn match crystalSpaceError display " \+\t"me=e-1
  endif
endif

" Operators
if exists('g:crystal_operators')
  syn match  crystalOperator "[~!^&|*/%+-]\|\%(class\s*\)\@<!<<\|<=>\|<=\|\%(<\|\<class\s\+\u\w*\s*\)\@<!<[^<]\@=\|===\|==\|=\~\|>>\|>=\|=\@<!>\|\*\*\|\.\.\.\|\.\.\|::"
  syn match  crystalOperator "->\|-=\|/=\|\*\*=\|\*=\|&&=\|&=\|&&\|||=\||=\|||\|%=\|+=\|!\~\|!=\|//"
  syn region crystalBracketOperator matchgroup=crystalOperator start="\%(\w[?!]\=\|[]})]\)\@<=\[\s*" end="\s*]" contains=ALLBUT,@crystalNotTop
endif

" Expression Substitution and Backslash Notation
syn match crystalStringEscape "\\\\\|\\[abefnrstv]\|\\\o\{1,3}\|\\x\x\{1,2}"                            contained display
syn match crystalStringEscape "\%(\\M-\\C-\|\\C-\\M-\|\\M-\\c\|\\c\\M-\|\\c\|\\C-\|\\M-\)\%(\\\o\{1,3}\|\\x\x\{1,2}\|\\\=\S\)" contained display

syn region crystalInterpolation      matchgroup=crystalInterpolationDelim start="#{" end="}" contained contains=ALLBUT,@crystalNotTop
syn match  crystalInterpolation      "#\%(\$\|@@\=\)\w\+" display contained contains=crystalInterpolationDelim,crystalInstanceVariable,crystalClassVariable,crystalGlobalVariable,crystalPredefinedVariable
syn match  crystalInterpolationDelim "#\ze\%(\$\|@@\=\)\w\+" display contained
syn match  crystalInterpolation      "#\$\%(-\w\|\W\)" display contained contains=crystalInterpolationDelim,crystalPredefinedVariable,crystalInvalidVariable
syn match  crystalInterpolationDelim "#\ze\$\%(-\w\|\W\)" display contained
syn region crystalNoInterpolation    start="\\#{" end="}" contained
syn match  crystalNoInterpolation    "\\#{" display contained
syn match  crystalNoInterpolation    "\\#\%(\$\|@@\=\)\w\+" display contained
syn match  crystalNoInterpolation    "\\#\$\W" display contained

syn match crystalDelimEscape "\\[(<{\[)>}\]]" transparent display contained contains=NONE

syn region crystalNestedParentheses    start="("  skip="\\\\\|\\)"  matchgroup=crystalString end=")"  transparent contained
syn region crystalNestedCurlyBraces    start="{"  skip="\\\\\|\\}"  matchgroup=crystalString end="}"  transparent contained
syn region crystalNestedAngleBrackets  start="<"  skip="\\\\\|\\>"  matchgroup=crystalString end=">"  transparent contained
syn region crystalNestedSquareBrackets start="\[" skip="\\\\\|\\\]" matchgroup=crystalString end="\]" transparent contained

" These are mostly Oniguruma ready
syn region crystalRegexpComment     matchgroup=crystalRegexpSpecial   start="(?#" skip="\\)" end=")" contained
syn region crystalRegexpParens      matchgroup=crystalRegexpSpecial   start="(\(?:\|?<\=[=!]\|?>\|?<[a-z_]\w*>\|?[imx]*-[imx]*:\=\|\%(?#\)\@!\)" skip="\\)" end=")" contained transparent contains=@crystalRegexpSpecial
syn region crystalRegexpBrackets    matchgroup=crystalRegexpCharClass start="\[\^\=" skip="\\\]" end="\]" contained transparent contains=crystalStringEscape,crystalRegexpEscape,crystalRegexpCharClass oneline
syn match  crystalRegexpCharClass   "\\[DdHhSsWw]" contained display
syn match  crystalRegexpCharClass   "\[:\^\=\%(alnum\|alpha\|ascii\|blank\|cntrl\|digit\|graph\|lower\|print\|punct\|space\|upper\|xdigit\):\]" contained
syn match  crystalRegexpEscape      "\\[].*?+^$|\\/(){}[]" contained
syn match  crystalRegexpQuantifier  "[*?+][?+]\=" contained display
syn match  crystalRegexpQuantifier  "{\d\+\%(,\d*\)\=}?\=" contained display
syn match  crystalRegexpAnchor      "[$^]\|\\[ABbGZz]" contained display
syn match  crystalRegexpDot         "\." contained display
syn match  crystalRegexpSpecial     "|"  contained display
syn match  crystalRegexpSpecial     "\\[1-9]\d\=\d\@!" contained display
syn match  crystalRegexpSpecial     "\\k<\%([a-z_]\w*\|-\=\d\+\)\%([+-]\d\+\)\=>" contained display
syn match  crystalRegexpSpecial     "\\k'\%([a-z_]\w*\|-\=\d\+\)\%([+-]\d\+\)\='" contained display
syn match  crystalRegexpSpecial     "\\g<\%([a-z_]\w*\|-\=\d\+\)>" contained display
syn match  crystalRegexpSpecial     "\\g'\%([a-z_]\w*\|-\=\d\+\)'" contained display

syn cluster crystalStringSpecial         contains=crystalInterpolation,crystalNoInterpolation,crystalStringEscape
syn cluster crystalExtendedStringSpecial contains=@crystalStringSpecial,crystalNestedParentheses,crystalNestedCurlyBraces,crystalNestedAngleBrackets,crystalNestedSquareBrackets
syn cluster crystalRegexpSpecial         contains=crystalInterpolation,crystalNoInterpolation,crystalStringEscape,crystalRegexpSpecial,crystalRegexpEscape,crystalRegexpBrackets,crystalRegexpCharClass,crystalRegexpDot,crystalRegexpQuantifier,crystalRegexpAnchor,crystalRegexpParens,crystalRegexpComment

" Numbers and ASCII Codes
syn match crystalASCIICode "\%(\w\|[]})\"'/]\)\@<!\%(?\%(\\M-\\C-\|\\C-\\M-\|\\M-\\c\|\\c\\M-\|\\c\|\\C-\|\\M-\)\=\%(\\\o\{1,3}\|\\x\x\{1,2}\|\\\=\S\)\)"
syn match crystalInteger   "\<0x[[:xdigit:]_]\+\%([ui]\%(8\|16\|32\|64\|128\)\|f\%(32\|64\)\)\=\>" display
syn match crystalInteger   "\<0o[0-7_]\+\%([ui]\%(8\|16\|32\|64\|128\)\)\=\>" display
syn match crystalInteger   "\<0b[01_]\+\%([ui]\%(8\|16\|32\|64\|128\)\)\=\>" display
syn match crystalInteger   "\<\d[[:digit:]_]*\%([ui]\%(8\|16\|32\|64\|128\)\|f\%(32\|64\)\)\=\>" contains=crystalInvalidInteger display
syn match crystalFloat     "\<\d[[:digit:]_]*\.\d[[:digit:]_]*\%(f\%(32\|64\)\)\=\>" contains=crystalInvalidInteger display
syn match crystalFloat     "\<\d[[:digit:]_]*\%(\.\d[[:digit:]_]*\)\=\%([eE][-+]\=[[:digit:]_]\+\)\%(f\%(32\|64\)\)\=\>" contains=crystalInvalidInteger display
" Note: 042 is invalid but 0, 0_, 0_u8 and 0_1 are valid (#73)
syn match crystalInvalidInteger "\.\@<!\<0\d\+\>" contained containedin=crystalFloat,crystalInteger display

" Identifiers
syn match crystalLocalVariableOrMethod "\<[_[:lower:]][_[:alnum:]]*[?!=]\=" contains=NONE display transparent
syn match crystalBlockArgument         "&[_[:lower:]][_[:alnum:]]"          contains=NONE display transparent

syn match  crystalTypeName          "\%(\%([.@$]\@<!\.\)\@<!\<\|::\)\_s*\zs\u\w*\%(\>\|::\)\@=" contained
syn match  crystalClassName         "\%(\%([.@$]\@<!\.\)\@<!\<\|::\)\_s*\zs\u\w*\%(\>\|::\)\@=" contained
syn match  crystalModuleName        "\%(\%([.@$]\@<!\.\)\@<!\<\|::\)\_s*\zs\u\w*\%(\>\|::\)\@=" contained
syn match  crystalStructName        "\%(\%([.@$]\@<!\.\)\@<!\<\|::\)\_s*\zs\u\w*\%(\>\|::\)\@=" contained
syn match  crystalLibName           "\%(\%([.@$]\@<!\.\)\@<!\<\|::\)\_s*\zs\u\w*\%(\>\|::\)\@=" contained
syn match  crystalEnumName          "\%(\%([.@$]\@<!\.\)\@<!\<\|::\)\_s*\zs\u\w*\%(\>\|::\)\@=" contained
syn match  crystalConstant          "\%(\%([.@$]\@<!\.\)\@<!\<\|::\)\_s*\zs\u\w*\%(\>\|::\)\@="
syn match  crystalClassVariable     "@@\%(\h\|%\|[^\x00-\x7F]\)\%(\w\|%\|[^\x00-\x7F]\)*" display
syn match  crystalInstanceVariable  "@\%(\h\|%\|[^\x00-\x7F]\)\%(\w\|%\|[^\x00-\x7F]\)*" display
syn match  crystalGlobalVariable    "$\%(\%(\h\|%\|[^\x00-\x7F]\)\%(\w\|%\|[^\x00-\x7F]\)*\|-.\)"
syn match  crystalFreshVariable     "\%(\h\|[^\x00-\x7F]\)\@<!%\%(\h\|[^\x00-\x7F]\)\%(\w\|%\|[^\x00-\x7F]\)*" display
syn match  crystalSymbol            "[]})\"':]\@<!:\%(\^\|\~\|<<\|<=>\|<=\|<\|===\|[=!]=\|[=!]\~\|!\|>>\|>=\|>\||\|-@\|-\|/\|\[][=?]\|\[]\|\*\*\|\*\|&\|%\|+@\|+\|`\)"
syn match  crystalSymbol            "[]})\"':]\@<!:\$\%(-.\|[`~<=>_,;:!?/.'"@$*\&+0]\)"
syn match  crystalSymbol            "[]})\"':]\@<!:\%(\$\|@@\=\)\=\%(\h\|[^\x00-\x7F]\)\%(\w\|[^\x00-\x7F]\)*"
syn match  crystalSymbol            "[]})\"':]\@<!:\%(\h\|%\|[^\x00-\x7F]\)\%(\w\|%\|[^\x00-\x7F]\)*\%([?!=]>\@!\)\="
syn match  crystalSymbol            "\%([{(,]\_s*\)\@<=\l\w*[!?]\=::\@!"he=e-1
syn match  crystalSymbol            "[]})\"':]\@<!\%(\h\|[^\x00-\x7F]\)\%(\w\|[^\x00-\x7F]\)*[!?]\=:\s\@="he=e-1
syn match  crystalSymbol            "\%([{(,]\_s*\)\@<=[[:space:],{]\l\w*[!?]\=::\@!"hs=s+1,he=e-1
syn match  crystalSymbol            "[[:space:],{]\%(\h\|[^\x00-\x7F]\)\%(\w\|[^\x00-\x7F]\)*[!?]\=:\s\@="hs=s+1,he=e-1

SynFold ':' syn region crystalSymbol start="[]})\"':]\@<!:\"" end="\"" skip="\\\\\|\\\"" contains=@crystalStringSpecial

syn match  crystalBlockParameter     "\%(\h\|%\|[^\x00-\x7F]\)\%(\w\|%\|[^\x00-\x7F]\)*" contained
syn region crystalBlockParameterList start="\%(\%(\<do\>\|{\)\s*\)\@<=|" end="|" oneline display contains=crystalBlockParameter

syn match crystalInvalidVariable    "$[^ %A-Za-z_-]"
syn match crystalPredefinedVariable #$[!$&"'*+,./0:;<=>?@\`~]#
syn match crystalPredefinedVariable "$\d\+" display
syn match crystalPredefinedVariable "$_\>" display
syn match crystalPredefinedVariable "$-[0FIKadilpvw]\>" display
syn match crystalPredefinedVariable "$\%(deferr\|defout\|stderr\|stdin\|stdout\)\>" display
syn match crystalPredefinedVariable "$\%(DEBUG\|FILENAME\|KCODE\|LOADED_FEATURES\|LOAD_PATH\|PROGRAM_NAME\|SAFE\|VERBOSE\)\>" display
syn match crystalPredefinedConstant "\%(\%(\.\@<!\.\)\@<!\|::\)\_s*\zs\%(MatchingData\|ARGF\|ARGV\|ENV\)\>\%(\s*(\)\@!"
syn match crystalPredefinedConstant "\%(\%(\.\@<!\.\)\@<!\|::\)\_s*\zs\%(DATA\|FALSE\|NIL\)\>\%(\s*(\)\@!"
syn match crystalPredefinedConstant "\%(\%(\.\@<!\.\)\@<!\|::\)\_s*\zs\%(STDERR\|STDIN\|STDOUT\|TOPLEVEL_BINDING\|TRUE\)\>\%(\s*(\)\@!"
syn match crystalPredefinedConstant "\%(\%(\.\@<!\.\)\@<!\|::\)\_s*\zs\%(crystal_\%(VERSION\|RELEASE_DATE\|PLATFORM\|PATCHLEVEL\|REVISION\|DESCRIPTION\|COPYRIGHT\|ENGINE\)\)\>\%(\s*(\)\@!"

" Normal Regular Expression
SynFold '/' syn region crystalRegexp matchgroup=crystalRegexpDelimiter start="\%(\%(^\|\<\%(and\|or\|while\|until\|unless\|if\|elsif\|ifdef\|when\|not\|then\|else\)\|[;\~=!|&(,[<>?:*+-]\)\s*\)\@<=/" end="/[iomxneus]*" skip="\\\\\|\\/" contains=@crystalRegexpSpecial
SynFold '/' syn region crystalRegexp matchgroup=crystalRegexpDelimiter start="\%(\h\k*\s\+\)\@<=/[ \t=/]\@!" end="/[iomxneus]*" skip="\\\\\|\\/" contains=@crystalRegexpSpecial

" Generalized Regular Expression
SynFold '%' syn region crystalRegexp matchgroup=crystalRegexpDelimiter start="%r\z([~`!@#$%^&*_\-+=|\:;"',.? /]\)" end="\z1[iomxneus]*" skip="\\\\\|\\\z1" contains=@crystalRegexpSpecial
SynFold '%' syn region crystalRegexp matchgroup=crystalRegexpDelimiter start="%r{"  end="}[iomxneus]*"  skip="\\\\\|\\}"  contains=@crystalRegexpSpecial
SynFold '%' syn region crystalRegexp matchgroup=crystalRegexpDelimiter start="%r<"  end=">[iomxneus]*"  skip="\\\\\|\\>"  contains=@crystalRegexpSpecial,crystalNestedAngleBrackets,crystalDelimEscape
SynFold '%' syn region crystalRegexp matchgroup=crystalRegexpDelimiter start="%r\[" end="\][iomxneus]*" skip="\\\\\|\\\]" contains=@crystalRegexpSpecial
SynFold '%' syn region crystalRegexp matchgroup=crystalRegexpDelimiter start="%r("  end=")[iomxneus]*"  skip="\\\\\|\\)"  contains=@crystalRegexpSpecial

" Normal String
let s:spell_cluster = exists('crystal_spellcheck_strings') ? ',@Spell' : ''
let s:fold_arg      = s:foldable('string') ? ' fold' : ''
exe 'syn region crystalString matchgroup=crystalStringDelimiter start="\"" end="\"" skip="\\\\\|\\\"" contains=@crystalStringSpecial' . s:spell_cluster . s:fold_arg
unlet s:spell_cluster s:fold_arg

" Shell Command Output
SynFold 'string' syn region crystalString matchgroup=crystalStringDelimiter start="`" end="`" skip="\\\\\|\\`" contains=@crystalStringSpecial

" Character
syn match crystalCharLiteral "'\%([^\\]\|\\[abefnrstv'\\]\|\\\o\{1,3}\|\\x\x\{1,2}\|\\u\x\{4}\)'" contains=crystalStringEscape display

" Generalized Single Quoted String, Symbol and Array of Strings
SynFold '%' syn region crystalString matchgroup=crystalStringDelimiter start="%[qwi]\z([~`!@#$%^&*_\-+=|\:;"',.?/]\)" end="\z1" skip="\\\\\|\\\z1"
SynFold '%' syn region crystalString matchgroup=crystalStringDelimiter start="%[qwi]{" end="}" skip="\\\\\|\\}" contains=crystalNestedCurlyBraces,crystalDelimEscape
SynFold '%' syn region crystalString matchgroup=crystalStringDelimiter start="%[qwi]<" end=">" skip="\\\\\|\\>" contains=crystalNestedAngleBrackets,crystalDelimEscape
SynFold '%' syn region crystalString matchgroup=crystalStringDelimiter start="%[qwi]\[" end="\]" skip="\\\\\|\\\]" contains=crystalNestedSquareBrackets,crystalDelimEscape
SynFold '%' syn region crystalString matchgroup=crystalStringDelimiter start="%[qwi](" end=")" skip="\\\\\|\\)" contains=crystalNestedParentheses,crystalDelimEscape
SynFold '%' syn region crystalString matchgroup=crystalStringDelimiter start="%q " end=" " skip="\\\\\|\\)"
SynFold '%' syn region crystalSymbol matchgroup=crystalSymbolDelimiter start="%s\z([~`!@#$%^&*_\-+=|\:;"',.? /]\)" end="\z1" skip="\\\\\|\\\z1"
SynFold '%' syn region crystalSymbol matchgroup=crystalSymbolDelimiter start="%s{" end="}" skip="\\\\\|\\}" contains=crystalNestedCurlyBraces,crystalDelimEscape
SynFold '%' syn region crystalSymbol matchgroup=crystalSymbolDelimiter start="%s<" end=">" skip="\\\\\|\\>" contains=crystalNestedAngleBrackets,crystalDelimEscape
SynFold '%' syn region crystalSymbol matchgroup=crystalSymbolDelimiter start="%s\[" end="\]" skip="\\\\\|\\\]" contains=crystalNestedSquareBrackets,crystalDelimEscape
SynFold '%' syn region crystalSymbol matchgroup=crystalSymbolDelimiter start="%s(" end=")" skip="\\\\\|\\)" contains=crystalNestedParentheses,crystalDelimEscape

" Generalized Double Quoted String and Array of Strings and Shell Command Output
" Note: %= is not matched here as the beginning of a double quoted string
SynFold '%' syn region crystalString matchgroup=crystalStringDelimiter start="%\z([~`!@#$%^&*_\-+|\:;"',.?/]\)" end="\z1" skip="\\\\\|\\\z1" contains=@crystalStringSpecial
SynFold '%' syn region crystalString matchgroup=crystalStringDelimiter start="%[QWIx]\z([~`!@#$%^&*_\-+=|\:;"',.?/]\)" end="\z1" skip="\\\\\|\\\z1" contains=@crystalStringSpecial
SynFold '%' syn region crystalString matchgroup=crystalStringDelimiter start="%[QWIx]\={" end="}" skip="\\\\\|\\}" contains=@crystalStringSpecial,crystalNestedCurlyBraces,crystalDelimEscape
SynFold '%' syn region crystalString matchgroup=crystalStringDelimiter start="%[QWIx]\=<" end=">" skip="\\\\\|\\>" contains=@crystalStringSpecial,crystalNestedAngleBrackets,crystalDelimEscape
SynFold '%' syn region crystalString matchgroup=crystalStringDelimiter start="%[QWIx]\=\[" end="\]" skip="\\\\\|\\\]" contains=@crystalStringSpecial,crystalNestedSquareBrackets,crystalDelimEscape
SynFold '%' syn region crystalString matchgroup=crystalStringDelimiter start="%[QWIx]\=(" end=")" skip="\\\\\|\\)" contains=@crystalStringSpecial,crystalNestedParentheses,crystalDelimEscape
SynFold '%' syn region crystalString matchgroup=crystalStringDelimiter start="%[Qx] " end=" " skip="\\\\\|\\)" contains=@crystalStringSpecial

" Here Document
syn region crystalHeredocStart matchgroup=crystalStringDelimiter start=+\%(\%(class\s*\|\%([]})"'.]\|::\)\)\_s*\|\w\)\@<!<<-\=\zs\%(\%(\h\|[^\x00-\x7F]\)\%(\w\|[^\x00-\x7F]\)*\)+ end=+$+ oneline contains=ALLBUT,@crystalNotTop
syn region crystalHeredocStart matchgroup=crystalStringDelimiter start=+\%(\%(class\s*\|\%([]})"'.]\|::\)\)\_s*\|\w\)\@<!<<-\=\zs"\%([^"]*\)"+ end=+$+ oneline contains=ALLBUT,@crystalNotTop
syn region crystalHeredocStart matchgroup=crystalStringDelimiter start=+\%(\%(class\s*\|\%([]})"'.]\|::\)\)\_s*\|\w\)\@<!<<-\=\zs'\%([^']*\)'+ end=+$+ oneline contains=ALLBUT,@crystalNotTop
syn region crystalHeredocStart matchgroup=crystalStringDelimiter start=+\%(\%(class\s*\|\%([]})"'.]\|::\)\)\_s*\|\w\)\@<!<<-\=\zs`\%([^`]*\)`+ end=+$+ oneline contains=ALLBUT,@crystalNotTop

SynFold '<<' syn region crystalString start=+\%(\%(class\|::\)\_s*\|\%([]})"'.]\)\s\|\w\)\@<!<<\z(\%(\h\|[^\x00-\x7F]\)\%(\w\|[^\x00-\x7F]\)*\)\ze\%(.*<<-\=['`"]\=\h\)\@!+hs=s+2 matchgroup=crystalStringDelimiter end=+^\z1$+ contains=crystalHeredocStart,crystalHeredoc,@crystalStringSpecial keepend
SynFold '<<' syn region crystalString start=+\%(\%(class\|::\)\_s*\|\%([]})"'.]\)\s\|\w\)\@<!<<"\z([^"]*\)"\ze\%(.*<<-\=['`"]\=\h\)\@!+hs=s+2 matchgroup=crystalStringDelimiter end=+^\z1$+ contains=crystalHeredocStart,crystalHeredoc,@crystalStringSpecial keepend
SynFold '<<' syn region crystalString start=+\%(\%(class\|::\)\_s*\|\%([]})"'.]\)\s\|\w\)\@<!<<'\z([^']*\)'\ze\%(.*<<-\=['`"]\=\h\)\@!+hs=s+2 matchgroup=crystalStringDelimiter end=+^\z1$+ contains=crystalHeredocStart,crystalHeredoc keepend
SynFold '<<' syn region crystalString start=+\%(\%(class\|::\)\_s*\|\%([]})"'.]\)\s\|\w\)\@<!<<`\z([^`]*\)`\ze\%(.*<<-\=['`"]\=\h\)\@!+hs=s+2 matchgroup=crystalStringDelimiter end=+^\z1$+ contains=crystalHeredocStart,crystalHeredoc,@crystalStringSpecial keepend

SynFold '<<' syn region crystalString start=+\%(\%(class\|::\)\_s*\|\%([]}).]\)\s\|\w\)\@<!<<-\z(\%(\h\|[^\x00-\x7F]\)\%(\w\|[^\x00-\x7F]\)*\)\ze\%(.*<<-\=['`"]\=\h\)\@!+hs=s+3 matchgroup=crystalStringDelimiter end=+^\s*\zs\z1$+ contains=crystalHeredocStart,@crystalStringSpecial keepend
SynFold '<<' syn region crystalString start=+\%(\%(class\|::\)\_s*\|\%([]}).]\)\s\|\w\)\@<!<<-"\z([^"]*\)"\ze\%(.*<<-\=['`"]\=\h\)\@!+hs=s+3 matchgroup=crystalStringDelimiter end=+^\s*\zs\z1$+ contains=crystalHeredocStart,@crystalStringSpecial keepend
SynFold '<<' syn region crystalString start=+\%(\%(class\|::\)\_s*\|\%([]}).]\)\s\|\w\)\@<!<<-'\z([^']*\)'\ze\%(.*<<-\=['`"]\=\h\)\@!+hs=s+3 matchgroup=crystalStringDelimiter end=+^\s*\zs\z1$+ contains=crystalHeredocStart keepend
SynFold '<<' syn region crystalString start=+\%(\%(class\|::\)\_s*\|\%([]}).]\)\s\|\w\)\@<!<<-`\z([^`]*\)`\ze\%(.*<<-\=['`"]\=\h\)\@!+hs=s+3 matchgroup=crystalStringDelimiter end=+^\s*\zs\z1$+ contains=crystalHeredocStart,@crystalStringSpecial keepend

" Module, Class, Method, and Alias Declarations
syn match crystalAliasDeclaration    "[^[:space:];#.()]\+" contained contains=crystalSymbol,crystalGlobalVariable,crystalPredefinedVariable nextgroup=crystalAliasDeclaration2 skipwhite
syn match crystalAliasDeclaration2   "[^[:space:];#.()]\+" contained contains=crystalSymbol,crystalGlobalVariable,crystalPredefinedVariable
syn match crystalMethodDeclaration   "[^[:space:];#(]\+"   contained contains=crystalConstant,crystalFunction,crystalBoolean,crystalPseudoVariable,crystalInstanceVariable,crystalClassVariable,crystalGlobalVariable
syn match crystalFunctionDeclaration "[^[:space:];#(=]\+"  contained contains=crystalFunction
syn match crystalTypeDeclaration     "[^[:space:];#=]\+"   contained contains=crystalTypeName
syn match crystalClassDeclaration    "[^[:space:];#<]\+"   contained contains=crystalClassName,crystalOperator
syn match crystalModuleDeclaration   "[^[:space:];#]\+"    contained contains=crystalModuleName,crystalOperator
syn match crystalStructDeclaration   "[^[:space:];#<]\+"   contained contains=crystalStructName,crystalOperator
syn match crystalLibDeclaration      "[^[:space:];#]\+"    contained contains=crystalLibName,crystalOperator
syn match crystalMacroDeclaration    "[^[:space:];#(]\+"   contained contains=crystalFunction
syn match crystalEnumDeclaration     "[^[:space:];#<\"]\+" contained contains=crystalEnumName
syn match crystalFunction "\<[_[:alpha:]][_[:alnum:]]*[?!=]\=[[:alnum:]_.:?!=]\@!" contained containedin=crystalMethodDeclaration,crystalFunctionDeclaration
syn match crystalFunction "\%(\s\|^\)\@<=[_[:alpha:]][_[:alnum:]]*[?!=]\=\%(\s\|$\)\@=" contained containedin=crystalAliasDeclaration,crystalAliasDeclaration2
syn match crystalFunction "\%([[:space:].]\|^\)\@<=\%(\[\][=?]\=\|\*\*\|[+-]@\=\|[*/%|&^~]\|<<\|>>\|[<>]=\=\|<=>\|===\|[=!]=\|[=!]\~\|!\|`\)\%([[:space:];#(]\|$\)\@=" contained containedin=crystalAliasDeclaration,crystalAliasDeclaration2,crystalMethodDeclaration,crystalFunctionDeclaration

syn cluster crystalDeclaration contains=crystalAliasDeclaration,crystalAliasDeclaration2,crystalMethodDeclaration,crystalFunctionDeclaration,crystalModuleDeclaration,crystalClassDeclaration,crystalStructDeclaration,crystalLibDeclaration,crystalMacroDeclaration,crystalFunction,crystalBlockParameter,crystalTypeDeclaration,crystalEnumDeclaration

" Keywords
" Note: the following keywords have already been defined:
" begin case class def do end for if module unless until while
syn match crystalControl        "\<\%(break\|in\|next\|rescue\|return\)\>[?!]\@!"
syn match crystalOperator       "\<defined?" display
syn match crystalKeyword        "\<\%(super\|previous_def\|yield\|of\|with\|uninitialized\|union\)\>[?!]\@!"
syn match crystalBoolean        "\<\%(true\|false\)\>[?!]\@!"
syn match crystalPseudoVariable "\<\%(nil\|self\|__DIR__\|__FILE__\|__LINE__\|__END_LINE__\)\>[?!]\@!" " TODO: reorganise

" Expensive Mode - match 'end' with the appropriate opening keyword for syntax
" based folding and special highlighting of module/class/method definitions
if !exists('b:crystal_no_expensive') && !exists('g:crystal_no_expensive')
  syn match crystalDefine "\<alias\>"  nextgroup=crystalAliasDeclaration skipwhite skipnl
  syn match crystalDefine "\<def\>"    nextgroup=crystalMethodDeclaration skipwhite skipnl
  syn match crystalDefine "\<fun\>"    nextgroup=crystalFunctionDeclaration skipwhite skipnl
  syn match crystalDefine "\<undef\>"  nextgroup=crystalFunction skipwhite skipnl
  syn match crystalDefine "\<\%(type\|alias\)\>\%(\s*\h\w*\s*=\)\@=" nextgroup=crystalTypeDeclaration skipwhite skipnl
  syn match crystalClass  "\<class\>"  nextgroup=crystalClassDeclaration skipwhite skipnl
  syn match crystalModule "\<module\>" nextgroup=crystalModuleDeclaration skipwhite skipnl
  syn match crystalStruct "\<struct\>" nextgroup=crystalStructDeclaration skipwhite skipnl
  syn match crystalLib    "\<lib\>"    nextgroup=crystalLibDeclaration skipwhite skipnl
  syn match crystalMacro  "\<macro\>"  nextgroup=crystalMacroDeclaration skipwhite skipnl
  syn match crystalEnum   "\<enum\>"   nextgroup=crystalEnumDeclaration skipwhite skipnl

  SynFold 'def'    syn region crystalMethodBlock start="\<\%(def\|macro\)\>" matchgroup=crystalDefine end="\%(\<\%(def\|macro\)\_s\+\)\@<!\<end\>"  contains=ALLBUT,@crystalNotTop
  SynFold 'class'  syn region crystalBlock       start="\<class\>"           matchgroup=crystalClass  end="\<end\>"                                 contains=ALLBUT,@crystalNotTop
  SynFold 'module' syn region crystalBlock       start="\<module\>"          matchgroup=crystalModule end="\<end\>"                                 contains=ALLBUT,@crystalNotTop
  SynFold 'struct' syn region crystalBlock       start="\<struct\>"          matchgroup=crystalStruct end="\<end\>"                                 contains=ALLBUT,@crystalNotTop
  SynFold 'lib'    syn region crystalBlock       start="\<lib\>"             matchgroup=crystalLib    end="\<end\>"                                 contains=ALLBUT,@crystalNotTop
  SynFold 'enum'   syn region crystalBlock       start="\<enum\>"            matchgroup=crystalEnum   end="\<end\>"                                 contains=ALLBUT,@crystalNotTop

  " modifiers
  syn match crystalConditionalModifier "\<\%(if\|unless\|ifdef\)\>" display
  syn match crystalRepeatModifier "\<\%(while\|until\)\>" display

  SynFold 'do' syn region crystalDoBlock matchgroup=crystalControl start="\<do\>" end="\<end\>" contains=ALLBUT,@crystalNotTop

  " curly bracket block or hash literal
  SynFold '{' syn region crystalCurlyBlock   matchgroup=crystalCurlyBlockDelimiter start="{"                     end="}" contains=ALLBUT,@crystalNotTop
  SynFold '[' syn region crystalArrayLiteral matchgroup=crystalArrayDelimiter      start="\%(\w\|[\]})]\)\@<!\[" end="]" contains=ALLBUT,@crystalNotTop

  " statements without 'do'
  SynFold 'begin'  syn region crystalBlockExpression       matchgroup=crystalControl     start="\<begin\>"  end="\<end\>" contains=ALLBUT,@crystalNotTop
  SynFold 'case'   syn region crystalCaseExpression        matchgroup=crystalConditional start="\<case\>"   end="\<end\>" contains=ALLBUT,@crystalNotTop
  SynFold 'select' syn region crystalSelectExpression      matchgroup=crystalConditional start="\<select\>" end="\<end\>" contains=ALLBUT,@crystalNotTop
  SynFold 'if'     syn region crystalConditionalExpression matchgroup=crystalConditional start="\%(\%(^\|\.\.\.\=\|[{:,;([<>~\*/%&^|+=-]\|\%(\<[_[:lower:]][_[:alnum:]]*\)\@<![?!]\)\s*\)\@<=\%(if\|ifdef\|unless\)\>" end="\%(\%(\%(\.\@<!\.\)\|::\)\s*\)\@<!\<end\>" contains=ALLBUT,@crystalNotTop

  syn match crystalConditional "\<\%(then\|else\|when\)\>[?!]\@!" contained containedin=crystalCaseExpression
  syn match crystalConditional "\<\%(when\|else\)\>[?!]\@!" contained containedin=crystalSelectExpression
  syn match crystalConditional "\<\%(then\|else\|elsif\)\>[?!]\@!" contained containedin=crystalConditionalExpression

  syn match crystalExceptional       "\<\%(\%(\%(;\|^\)\s*\)\@<=rescue\|else\|ensure\)\>[?!]\@!" contained containedin=crystalBlockExpression
  syn match crystalMethodExceptional "\<\%(\%(\%(;\|^\)\s*\)\@<=rescue\|else\|ensure\)\>[?!]\@!" contained containedin=crystalMethodBlock

  " statements with optional 'do'
  syn region crystalOptionalDoLine matchgroup=crystalRepeat start="\<for\>[?!]\@!" start="\%(\%(^\|\.\.\.\=\|[{:,;([<>~\*/%&^|+-]\|\%(\<[_[:lower:]][_[:alnum:]]*\)\@<![!=?]\)\s*\)\@<=\<\%(until\|while\)\>" matchgroup=crystalOptionalDo end="\%(\<do\>\)" end="\ze\%(;\|$\)" oneline contains=ALLBUT,@crystalNotTop

  SynFold 'for' syn region crystalRepeatExpression start="\<for\>[?!]\@!" start="\%(\%(^\|\.\.\.\=\|[{:,;([<>~\*/%&^|+-]\|\%(\<[_[:lower:]][_[:alnum:]]*\)\@<![!=?]\)\s*\)\@<=\<\%(until\|while\)\>" matchgroup=crystalRepeat end="\<end\>" contains=ALLBUT,@crystalNotTop nextgroup=crystalOptionalDoLine

  if !exists('g:crystal_minlines')
    let g:crystal_minlines = 500
  endif
  exec 'syn sync minlines=' . g:crystal_minlines

else
  " Non-expensive mode
  syn match crystalControl "\<def\>[?!]\@!"    nextgroup=crystalMethodDeclaration skipwhite skipnl
  syn match crystalControl "\<fun\>[?!]\@!"    nextgroup=crystalFunctionDeclaration skipwhite skipnl
  syn match crystalControl "\<class\>[?!]\@!"  nextgroup=crystalClassDeclaration  skipwhite skipnl
  syn match crystalControl "\<module\>[?!]\@!" nextgroup=crystalModuleDeclaration skipwhite skipnl
  syn match crystalControl "\<struct\>[?!]\@!" nextgroup=crystalStructDeclaration skipwhite skipnl
  syn match crystalControl "\<lib\>[?!]\@!"    nextgroup=crystalLibDeclaration skipwhite skipnl
  syn match crystalControl "\<macro\>[?!]\@!"  nextgroup=crystalMacroDeclaration skipwhite skipnl
  syn match crystalControl "\<enum\>[?!]\@!"   nextgroup=crystalEnumDeclaration skipwhite skipnl
  syn match crystalControl "\<\%(case\|begin\|do\|for\|if\|ifdef\|unless\|while\|until\|else\|elsif\|ensure\|then\|when\|end\)\>[?!]\@!"
  syn match crystalKeyword "\<\%(alias\|undef\)\>[?!]\@!"
endif

" Link attribute
syn region crystalLinkAttrRegion      start="@\[" nextgroup=crystalLinkAttrRegionInner end="]" contains=crystalLinkAttr,crystalLinkAttrRegionInner transparent display oneline
syn region crystalLinkAttrRegionInner start="\%(@\[\)\@<=" end="]\@=" contained contains=ALLBUT,@crystalNotTop transparent display oneline
syn match  crystalLinkAttr            "@\[" contained containedin=crystalLinkAttrRegion display
syn match  crystalLinkAttr            "]" contained containedin=crystalLinkAttrRegion display

" Special Methods
if !exists('g:crystal_no_special_methods')
  syn keyword crystalAccess    protected private
  " attr is a common variable name
  syn keyword crystalAttribute abstract
  syn match   crystalAttribute "\<\%(class_\)\=\%(getter\|setter\|property\)[!?]\=\s" display
  syn match   crystalControl   "\<\%(abort\|at_exit\|exit\|fork\|loop\)\>[?!]\@!" display
  syn keyword crystalException raise
  " false positive with 'include?'
  syn match   crystalInclude   "\<include\>[?!]\@!" display
  syn keyword crystalInclude   extend require
  syn keyword crystalKeyword   caller typeof pointerof sizeof instance_sizeof
  syn match   crystalRecord    "\<record\%(\s\+\u\w*\)\@=" display
endif

" Comments and Documentation
syn match   crystalSharpBang "\%^#!.*" display
syn keyword crystalTodo      FIXME NOTE TODO OPTIMIZE XXX todo contained
syn match   crystalComment   "#.*" contains=crystalSharpBang,crystalSpaceError,crystalTodo,@Spell

SynFold '#' syn region crystalMultilineComment start="\%(\%(^\s*#.*\n\)\@<!\%(^\s*#.*\n\)\)\%(\(^\s*#.*\n\)\{1,}\)\@=" end="\%(^\s*#.*\n\)\@<=\%(^\s*#.*\n\)\%(^\s*#\)\@!" contains=crystalComment transparent keepend

" Note: this is a hack to prevent 'keywords' being highlighted as such when called as methods with an explicit receiver
syn match crystalKeywordAsMethod "\%(\%(\.\@<!\.\)\|::\)\_s*\%(alias\|begin\|break\|case\|class\|def\|defined\|do\|else\|select\)\>" transparent contains=NONE
syn match crystalKeywordAsMethod "\%(\%(\.\@<!\.\)\|::\)\_s*\%(elsif\|end\|ensure\|false\|for\|if\|ifdef\|in\|module\|next\|nil\)\>" transparent contains=NONE
syn match crystalKeywordAsMethod "\%(\%(\.\@<!\.\)\|::\)\_s*\%(rescue\|return\|self\|super\|previous_def\|then\|true\)\>" transparent contains=NONE
syn match crystalKeywordAsMethod "\%(\%(\.\@<!\.\)\|::\)\_s*\%(undef\|unless\|until\|when\|while\|yield\|with\|__FILE__\|__LINE__\)\>" transparent contains=NONE

syn match crystalKeywordAsMethod "\<\%(alias\|begin\|case\|class\|def\|do\|end\)[?!]" transparent contains=NONE
syn match crystalKeywordAsMethod "\<\%(if\|ifdef\|module\|undef\|unless\|until\|while\)[?!]" transparent contains=NONE

syn match crystalKeywordAsMethod "\%(\%(\.\@<!\.\)\|::\)\_s*\%(abort\|at_exit\|caller\|exit\)\>" transparent contains=NONE
syn match crystalKeywordAsMethod "\%(\%(\.\@<!\.\)\|::\)\_s*\%(extend\|fork\|include\|asm\)\>" transparent contains=NONE
syn match crystalKeywordAsMethod "\%(\%(\.\@<!\.\)\|::\)\_s*\%(loop\|private\|protected\)\>" transparent contains=NONE
syn match crystalKeywordAsMethod "\%(\%(\.\@<!\.\)\|::\)\_s*\%(require\|raise\)\>" transparent contains=NONE
syn match crystalKeywordAsMethod "\%(\%(\.\@<!\.\)\|::\)\_s*\%(typeof\|pointerof\|sizeof\|instance_sizeof\|\)\>" transparent contains=NONE

hi def link crystalClass               crystalDefine
hi def link crystalModule              crystalDefine
hi def link crystalStruct              crystalDefine
hi def link crystalLib                 crystalDefine
hi def link crystalEnum                crystalDefine
hi def link crystalMethodExceptional   crystalDefine
hi def link crystalDefine              Define
hi def link crystalFunction            Function
hi def link crystalConditional         Conditional
hi def link crystalConditionalModifier crystalConditional
hi def link crystalExceptional         crystalConditional
hi def link crystalRepeat              Repeat
hi def link crystalRepeatModifier      crystalRepeat
hi def link crystalOptionalDo          crystalRepeat
hi def link crystalControl             Statement
hi def link crystalInclude             Include
hi def link crystalRecord              Statement
hi def link crystalInteger             Number
hi def link crystalASCIICode           Character
hi def link crystalFloat               Float
hi def link crystalBoolean             Boolean
hi def link crystalException           Exception
if !exists('g:crystal_no_identifiers')
  hi def link crystalIdentifier Identifier
else
  hi def link crystalIdentifier NONE
endif
hi def link crystalClassVariable        crystalIdentifier
hi def link crystalConstant             Type
hi def link crystalTypeName             crystalConstant
hi def link crystalClassName            crystalConstant
hi def link crystalModuleName           crystalConstant
hi def link crystalStructName           crystalConstant
hi def link crystalLibName              crystalConstant
hi def link crystalEnumName             crystalConstant
hi def link crystalGlobalVariable       crystalIdentifier
hi def link crystalBlockParameter       crystalIdentifier
hi def link crystalInstanceVariable     crystalIdentifier
hi def link crystalFreshVariable        crystalIdentifier
hi def link crystalPredefinedIdentifier crystalIdentifier
hi def link crystalPredefinedConstant   crystalPredefinedIdentifier
hi def link crystalPredefinedVariable   crystalPredefinedIdentifier
hi def link crystalSymbol               Constant
hi def link crystalKeyword              Keyword
hi def link crystalOperator             Operator
hi def link crystalAccess               Statement
hi def link crystalAttribute            Statement
hi def link crystalPseudoVariable       Constant
hi def link crystalCharLiteral          Character
hi def link crystalComment              Comment
hi def link crystalTodo                 Todo
hi def link crystalStringEscape         Special
hi def link crystalInterpolationDelim   Delimiter
hi def link crystalNoInterpolation      crystalString
hi def link crystalSharpBang            PreProc
hi def link crystalRegexpDelimiter      crystalStringDelimiter
hi def link crystalSymbolDelimiter      crystalStringDelimiter
hi def link crystalStringDelimiter      Delimiter
hi def link crystalString               String
hi def link crystalHeredoc              crystalString
hi def link crystalRegexpEscape         crystalRegexpSpecial
hi def link crystalRegexpQuantifier     crystalRegexpSpecial
hi def link crystalRegexpAnchor         crystalRegexpSpecial
hi def link crystalRegexpDot            crystalRegexpCharClass
hi def link crystalRegexpCharClass      crystalRegexpSpecial
hi def link crystalRegexpSpecial        Special
hi def link crystalRegexpComment        Comment
hi def link crystalRegexp               crystalString
hi def link crystalMacro                PreProc
hi def link crystalMacroDelim           crystalMacro
hi def link crystalLinkAttr             crystalMacro
hi def link crystalError                Error
hi def link crystalInvalidVariable      crystalError
hi def link crystalSpaceError           crystalError
hi def link crystalInvalidInteger       crystalError

let b:current_syntax = 'crystal'

delc SynFold

" vim: nowrap sw=2 sts=2:
