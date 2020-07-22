/
    Dependency Tree Utilities 
    Author: Ng Hai Ming
\

// Get base namespaces
.util.baseNS: {.Q.dd[`;] each key[`] except `q`Q`h`j`o};

// Check nulls for first dictionary type
.util.chkNSDict: {(99h = type x) and (::) ~ first x};

// Collate the full namespace of subsequent NS dict
.util.getNS: {.Q.dd[x;] each where .util.chkNSDict each value x};

// Generate the levels of individual namespaces, max up to 5 levels
.util.genNSDict: {do[4; x: x, enlist $[count last x; raze .util.getNS each last x; ()]]; x};

// To check the namespace for specific variable types in each individual scan loop
.util.scanVarType: {y, enlist raze .Q.dd/:'[z; .util.sysCmd[x;] each z]};

// Use .util.scanVarTypes to generate a list of depth 5 for a specific variable type
.util.getVarType: {.util.scanVarType[x]/[(); .util.genNSDict y]};

// Generate unique dictionaries
.util.genUniqDict: {[func;dict;iterkeys]
    @[dict; iterkeys; union; func iterkeys]
 };

// Get all variables defined within kdb namespaces
.util.getAllKeys: {
    if[not .util.toSymbol[x] in `f`a`v;  
        '"Only `f`a`v allowed!"
    ];
    dict: (`u# (), `)! enlist .util.sysCmd[x];
    .util.genUniqDict[raze .util.getVarType[x] ::]/[dict; .util.baseNS[]]
 };

// To pretty print a nice table
.util.prettyTab: {
    x: where["b"$ b: count each x]# x;
    @[flip; x ,' (max[b] - count each x) #' `; ()]
 };

// To get all the relevant info
// To get all functions, run .util.getAllKeysInfo `f
.util.getAllInfo: .util.prettyTab .util.getAllKeys ::;

// Generate tables from the list
.util.makeDepthDict: {
    tab: (uj/) .util.toSymbol[til count x] {flip enlist[x]!enlist (), y}' x;
    $[count tab; 
        `Regex xcols ![tab; enlist (=;`i;0); 0b; enlist[`Regex]!enlist (), y]; 
        ([] Regex:`$())
    ]
 };

// Find regex functions
.util.findRegex: {[caseFn;regex;fn]
    "b"$ count caseFn[string value fn] ss regex
 };

// To search the function-string for particular regex match
.util.searchRegex: {[allFns;filterStr;caseFn;convert;regex]
    
    regex: first regex;

    keyword: $[convert; last ` vs regex; regex];
    ns: ` sv 2 sublist ` vs regex;
    
    nsAllFns: $[ns in key allFns; allFns ns; ()];
    allFns: raze ns _ allFns;

    isRegex: .util.findRegex[caseFn;;] caseFn ,[;filterStr] .util.toString ::;
    
    allFns@: where isRegex[regex] each allFns;
    nsAllFns@: where isRegex[keyword] each nsAllFns;

    allFns, nsAllFns
 };

// Wrapper for .util.searchRegex to stack additional layers of dependencies 
.util.searchRegexWrap: {[allFns;regexList]
    regexList, enlist distinct[raze .util.searchRegex[allFns;"[(/[' @.]";::;1b] each raze last regexList] except union/[regexList]
 };

// Check for dependencies for regex - Can accept up to 3 args
.util.genDepTree: {[options]
    
    options: 3# options, 11b;

    addFilter: options 1;
    isCase: options 2;
    regex: (), .util.toSymbol first options;
    
    baseOp: (enlist .util.singleSearch[;addFilter;isCase] ::) each regex;
    output: (-1_ .util.searchRegexWrap[.util.getAllKeys `f]/["b"$ count last ::;] ::) each baseOp;

    uj/[.util.makeDepthDict'[output;regex]]
 
 } enlist ::;

// Single level search - can accept up to 3 args 
.util.singleSearch: {[options]
    
    options: 3# options, 11b;
    
    regex: (), .util.toSymbol first options;
    filterStr: $[options 1; "[(/[' @.]"; ""];
    caseFn: $[options 2; ::; lower];

    .util.searchRegex[.util.getAllKeys `f; filterStr; caseFn; 0b; regex]
 
 } enlist ::;

\ 
Example Usage: 
1) To get all functions within the `.a namespace
.util.getVarType[`f;`.a] 

2) To get all functions across namespaces in table format
.util.getAllInfo `f
.util.getAllInfo "f"
.util.getAllInfo `a

3) Generate regex dependency tree with additional filter and case sensitivity
.util.genDepTree `getVarType
.util.genDepTree "getVarType"

4) Generate regex dependency tree without additional filter and case insensitive
.util.genDepTree[`getVarType;0b;0b]
.util.genDepTree[`getVarType`sysCmd;0b;0b]
.util.genDepTree["getVarType";0b;0b]

5) Generate regex dependency trees without additional filter but case sensitivity
.util.genDepTree[`getVarType;0b]

5) Single level search without associated dependency trees, with options similar to above
.util.singleSearch `getVarType
.util.singleSearch "getVarType"
.util.singleSearch[`getVarType;1b]
.util.singleSearch[`getVarType;0b;0b]
.util.singleSearch[`getVarType;0b;1b]


