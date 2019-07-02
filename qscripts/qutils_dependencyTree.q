/// Segment 1 --- To generate a table containing all the functions and tables
// Function for the nsSearch across each individual namespaces, can be potentially wrapped with protected evaluation in case of type error (though one should investigate thoroughly should it happen)
/ Protected eval can be defined with this additional line: 
/ .qutils.recursiveNSSearch: @[.qutils.recursiveNSSearch;;::]
/ The type error can happen if the object happens to be keyed tables or mixed lists, which is corrected for with the type check for 0 98h
.qutils.recursiveNSSearch: {
        x, $[type[a:key y] = 0h; 
                (); 
            type[a] = 98h; 
                [.qutils.tabList,:y; ()]; 
            y ~ a; 
                [$[(b:type value y) in 100 104 111 112h; .qutils.fnList,:y; 98h=b; .qutils.tabList,:y; ]; ()]; 
            .Q.dd'[y;a where not null a]
            ]
    }/[();];

// This function would initialise in any native q process (in a top-down fashion) with the function .qutils.genAllList
/ rootNs arg would determine whether the .qutils.fnDict would be generated with root namespace functions or not
.qutils.genAllList: {[rootNs] 
    / Initialise a global empty variable .qutils.fnList/tabList for the appending of functions or tabs 
    .qutils.tabList: .qutils.fnList: (); 
    / Search through 5 level of namespaces depth
    searchOP: (raze .qutils.recursiveNSSearch\[5;] @) each t: .Q.dd'[`; key[`] except `q`Q`h`j`o];
    / Generate the .qutils.fnDict to contain all the functions in each namespace across 5 level of namespace depth     
    .qutils.fnDict: t! distinct[.qutils.fnList] inter/: searchOP;
    .qutils.tabDict: t! distinct[.qutils.tabList] inter/: searchOP; 
    / Clear the existing fnList and tabList defined since its done
    delete fnList, tabList from `.qutils;
    / If one wants to include main (root) namespace functions, simply specify 1b for the rootNs argument
    if[rootNs; 
        .qutils.fnDict,: enlist[`root]!enlist system "f"; 
        .qutils.tabDict,: enlist[`root]!enlist tables[]
        ]; 
    };

// Function to provide nice display of .qutils.fnDict/tabDict under .qutils.displayAllFns/display_all_tabs
/ It ensures that all dict keys are of equivalent sizes
/ An additional argument is provided to determine if table should be made nicer
.qutils.fillDictWithNulls: {a: $[y; (`$ " | " sv "." vs string @)''; ] x;
    flip a ,' (max[b] - b:count each a) #' ` 
    }; 

// Function to help filter empty namespace columns for easier viewing
.qutils.filterEmptyCols: {a: where[not (all null@) each flip x]; $[count a; a#x; x]};

// Generalised function to display either all functions or tabs
.qutils.displayAllObj: {[regen;beautify;obj]
    / Check if obj is defined, else generate it with .qutils.genAllList with rootNs:1b
    if[regen or not type key obj; .qutils.genAllList[1b]];
    / Display the .qutils.fnList in a nice q table 
    .qutils.filterEmptyCols .qutils.fillDictWithNulls[value obj;beautify]
    };

// Function to display .qutils.fnDict (which is essentially all the functions defined within the q process)
.qutils.displayAllFns: .qutils.displayAllObj[;;`.qutils.fnDict];

// Function to display .qutils.tabDict (which is essentially all the tables defined within the q process)
.qutils.displayAllTabs: .qutils.displayAllObj[;;`.qutils.tabDict];

// Example of using Segment 1:
/ .qutils.displayAllFns[1b;1b] to display all the functions (regenerated) defined within the q process in beautified format
/ .qutils.displayAllTabs[1b;1b] to display all the tables

/// Segment 2 --- To generate a table containing the dependency tree of the analytic specified in the regex
// Function to generate .qutils.fullFnList
.qutils.genFullFnList: {[isDC]
    .qutils.fullFnList: $[isDC; system["f"], .al.getLoadedAnalytics[]; [.qutils.genAllList[1b]; raze .qutils.fnDict]];
    };

// Function to check if .qutils.fullFnList is defined, if not define it
/ It takes in an isDC argument to determine if the process should be generated with First Derivatives's DC analytics or the above analytics defined
/ Check if .qutils.fnDict is defined, else generate it with .qutils.genAllList[1b] (with root namespaces)
.qutils.checkFullFnList: {[isDC] if[not type key `.qutils.fullFnList; .qutils.genFullFnList[isDC]]};

// Function to search the analytic definition for keywords/analytics name (for the layered approach used below for bottom-up fashion)
/ If addFilter is 1b, it would search the analytic name/key word in conjunction with certain symbols/spaces, this should be set to 1b by default to ensure optimal search results 
.qutils.searchFnRegex: {[isDC;addFilter;regex] 
    .qutils.checkFullFnList[isDC];
    .qutils.fullFnList where ("b"$count ss[;string[regex], $[addFilter;"[(/[') ;@.]";""]] string value @) each .qutils.fullFnList
    };

// For purposes of searching a single layer, instead of entire dependency tree
/ The equivalent is .al.searchAnalyticCode in FD's DC, but this one would display it in a table format, facilitating easy reading
.qutils.searchAnalyticCode: {[isDC;addFilter;regex] ([] Search_List: $[isDC; .qutils.searchFnRegex[isDC;addFilter;regex]; .al.searchAnalyticCode[regex]])};

// Wrapper for .qutils.searchFnRegex for the purpose of .qutils.elicitDependencyTree
.qutils.searchFnRegexWrapper: {[params;regexlist] regexlist, enlist distinct[raze .qutils.searchFnRegex[params 0;params 1] each last regexlist] except union/[regexlist]};

// Function to elicit the dependency trees --- For a SINGLE analytic
/ The isDC arg takes into account whether the process is First Derivatives's DC IDE or not (just specify 0b for native q processes)
.qutils.elicitDependencyTree: {[isDC;addFilter;regex]
    .qutils.checkFullFnList[isDC];
    (uj/) til[count val] .qutils.convertDictToTable' (val: 1_ -1_ .qutils.searchFnRegexWrapper[(isDC;addFilter)]/[("b"$ count last @); (), regex])
    };

// Function to elicit dependency trees --- For MULTIPLE analytics
.qutils.elicitMultiDependencyTrees: {[isDC;addFilter;regexList] 
    () {$[count a: .qutils.elicitDependencyTree[x 0;x 1;z]; y uj `Analytic xcols update Analytic:z from a; y]}[(isDC;addFilter)]/ regexList
    };

// Wrapper to convert a dictionary key-value pair into a table
/ Though its quicker to do it outside the function, to make it more generalisable, the `$ string x is done within the function
.qutils.convertDictToTable: {flip enlist[`$ string x]!enlist (), y};

// Function to elicit dependency trees -- For MULTIPLE analytics (within First Derivatives's DC IDE only)
/ This can only be run in main DC process, where there's access to this .al.searchAnalyticCode analytic
.qutils.DC.elicitDependencyTreeWrapper: {x, enlist distinct[raze .al.searchAnalyticCode each last x] except union/[x]};

.qutils.DC.elicitDependencyTree: {(uj/) til[count val] .qutils.convertDictToTable' (val: 1_ -1_ .qutils.DC.elicitDependencyTreeWrapper/[("b"$ count last @); (), x])};

.qutils.DC.elicitMultiDependencyTrees:{$[count a:.qutils.DC.elicitDependencyTree y; x uj `Analytic xcols update Analytic:y from a; x]}/[();];

// Just in case one want to define these defined functions loaded via the script on remote instances 
/ The following analytic can be used:
.qutils.defineRemoteFns: {[handle] handle each (set;;)'[a; value'[a: .Q.dd'[`.qutils; system "f .qutils"]]]};

// Example of using Segment 2:
// It is advisable to run .qutils.genFullFnList[0b] before the start of running Segment 2 to ensure latest function lists is populated
/ .qutils.elicitDependencyTree[0b;1b;`.qutils.searchFnRegexWrapper] to find the dependency tree of functions
/ .qutils.elicitMultiDependencyTrees[0b;1b;`.qutils.searchFnRegexWrapper`f1`.qutils.searchFnRegex]

/ The equivalent in FD's Delta Control IDE is:
/ --- Outside main FD's DC IDE process ---
/ .qutils.elicitDependencyTree[1b;1b;`.qutils.searchFnRegexWrapper] to find the dependency tree of functions
/ .qutils.elicitMultiDependencyTrees[1b;1b;`.qutils.searchFnRegexWrapper`f1`.qutils.searchFnRegex]
/ --- Within main FD's DC IDE process ---
/ .qutils.DC.elicitDependencyTree[`.qutils.searchFnRegexWrapper] 
/ .qutils.DC.elicitMultiDependencyTrees[`.qutils.searchFnRegexWrapper`f1`.qutils.searchFnRegex]