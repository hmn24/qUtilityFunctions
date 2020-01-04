/
    Dependency Tree Utilities 
    Author: Ng Hai Ming
\

// Function to convert strings/symbols
.util.toString: {$[not type x; .z.s each x; 10h = abs type x; x; string x]};
.util.toSymbol: {$[11h = abs type x; x; `$ .util.toString x]};

// Run system commands, e.g. .util.sys[`f;`.a]
.util.sys: {@[system; raze .util.toString (x;" ";y); ()]};

// Get base namespaces
.util.baseNS: {.Q.dd[`;] each key[`] except `q`Q`h`j`o};

// Check nulls for first dictionary type
.util.chkNSDict: {(99h = type x) and (::) ~ first x};

// Collate the full namespace of subsequent NS dict
.util.getNS: {.Q.dd[x;] each where .util.chkNSDict peach value x};

// Generate the levels of individual namespaces, max up to 5 levels
.util.genNSDict: {do[5; x: x, enlist raze .util.getNS peach last x]; x};

// To check the namespace for specific variable types in each individual scan loop
.util.scanVarType: {y, enlist raze .Q.dd/:'[z; .util.sys[x] peach z]};

// Use .util.scanVarTypes to generate a list of depth 5 for a specific variable type
.util.getVarType: {.util.scanVarType[x]/[(); .util.genNSDict y]};

// Get all variables defined within kdb namespaces
.util.getAllVar: {
    if[not .util.toSymbol[x] in `f`a`v;  
        '"Only `f`a`v allowed!"
    ];
    .util.baseNS[]! (raze .util.getVarType[x] ::) peach .util.baseNS[]
 };

// To ensure dictionaries keys are of equal length
.util.makeEqualLength: {flip x ,' (max[b] - b:count each x) #' `};

// Create dictonaries on a each-both basis
.util.makeRowDict: {flip enlist[x]!enlist (), y};
.util.makeDepthDict: {
    tab: (uj/) .util.toSymbol[til count x] .util.makeRowDict' x;
    .util.updTabCol[tab; y]
 };
.util.updTabCol: {[tab;regex] $[count tab; `Regex xcols ![tab; (); 0b; enlist[`Regex]!enlist (), regex]; tab]}

// To generate all namespace dictionaries for functions
.util.getAllFns: {.util.makeEqualLength .util.getAllVar[`f]};
.util.getAllTabs: {.util.makeEqualLength .util.getAllVar[`a]};

// To search the function-string for particular regex match
.util.searchRegex: {[allFns;filterStr;caseFn;regex]
    regexStr: caseFn @ raze .util.toString regex, filterStr;
    allFns where "b"$ (count ss[;regexStr] caseFn @ string value ::) peach allFns
 };

// Wrapper for .util.searchRegex to ensure 
.util.searchRegexWrap: {[allFns;filterStr;caseFn;regexList]
    regexList, enlist distinct[raze .util.searchRegex[allFns;filterStr;caseFn] peach last regexList] except union/[regexList]
 };

// Check for dependencies for a single regex 
.util.genDepTree: {[addFilter;isCase;regex]
    allFns: raze .util.getAllVar[`f];
    caseFn: $[isCase;::;lower];
    filterStr: $[addFilter; "[(/[') ;@.]"; ""];
    regex: .util.toSymbol @ regex;
    output: (1_ -1_ .util.searchRegexWrap[allFns;filterStr;caseFn]/["b"$ count last ::;] ::) each (), regex;
    uj/[.util.makeDepthDict[;regex] peach output]
 };

\ 
Example Usage: 
1) To get all functions within the `.a namespace
.util.getVarTypes[`f;`.a] 

2) To get all functions across namespaces in table format
.util.getAllFns[]

3) To get all functions across namespaces in dict format
.util.getAllVar[`f]

4) To get the dependency tree of a particular regex with additional filter and case sensitivity
.util.genDepTree[1b;1b;`getVarType]
