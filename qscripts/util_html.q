/
    HTML/Metadata Utilities 
    Author: Ng Hai Ming
\

// Generate metadata in verbose form
.util.getTabMeta: {
    typeDict: (upper[c], c: .Q.t a)!(`$"list of ",/: string b), b: key'[(a:5h$ where " " <> 20#.Q.t) $\: ()]; 
    attributeDict: `s`u`p`g!`sorted`unique`parted`grouped;
    allTabs: raze/[.util.getVarType[`a] peach .util.baseNS[]], tables[];
    verboseMeta: ?[;();0b;(`$("Column Names";"Data Types";"Attribute Types"))!(`c;(typeDict;`t);(attributeDict;`a))]; 
    allTabs!(verboseMeta meta ::) each allTabs
 };

// Write metadata to xls form
.util.writeXlsTab: {[filePath] 
    filePath: .util.toString filePath;
    hsym[.util.toSymbol filePath, $[filePath like "*.xls";"";".xls"]] 0: .h.edsn .util.getTabMeta[]
 };

// Parse worksheet name out
.util.parseWSName: {first @[x ss "\"";0;+;1] _ x};

// Reversing .h.edsn xls files generated above
.util.reverseEdsn: {
    ws: raze 1_ read0 hsym .util.toSymbol x;                                                // Slice off XML version
    index: ,'/[ws ss/: "<>"];                                                               // Find all <>
    index[;1]+: 1;                                                                          // Account for slice indices 
    ws: except[raze[index] _ ws; enlist ""];                                                // Parse it into a matrix structure
    wsNames: .util.toSymbol .util.parseWSName each .util.regexFilter[ws; "<Worksheet*"];    // Get the appropriate wsNames
    wsTabs: .util.findTags["*[</]Table>"; ws];                                              // Break ws into its separate tables
    .util.parseXML each wsTabs
 };

// Filter list to specific regex
.util.regexFilter: {x where x like y};

// Parse into XML Structure
.util.parseXML: {
    tabString: ("," sv .util.sliceIndex each .util.findTags["*[</]Data[ >]*"] ::) each .util.findTags["*[</]Row>"; x];
    commaStr: (1+ count first[tabString] ss ",")#"*"; 
    (commaStr; enlist csv) 0: tabString
 };
    
// Add Double Apostrophes
.util.addDoubApost: {"\"", x, "\""};

// Parse .util.getTabMeta[] into HTML Structure
.util.createHTMLStruct: {.h.htac[`button; `id`onclick`class! `$ .util.addDoubApost each (x; "send('.util.getTabMeta[] @ `", x, "');trigger('", x, "');"; "active"); x]};

// Define CSS Styles 
.util.defineCSSStyle: {
    .h.sa: .h.htc[`style; "table {font-family: arial, sans-serif; border-collapse: collapse; width: auto !important;}"]; 
    .h.sb: .h.htc[`style; "td, th {border: 1px solid #dddddd; text-align: left; padding: 4px;}"];
    .h.sc: .h.htc[`style; "tr:nth-child(even) {background-color: #dddddd;}"];
 }; 

// Generation of each HTML table rows
.util.htc: {.h.htc[z] raze .h.htc[y] each x};

// Generate table in HTML format
.util.toHTMLTab: {[tab] 
    woHead: csv 0: tab;
    .h.htc[`table] {x, .util.htc["," vs y;`td;`tr]}/[.util.htc["," vs woHead 0;`th;`tr]; 1_ woHead]
 };

// .z.ws for HTML Interface   
.z.ws: {neg[.z.w] .j.j @[value; x; `$ "'",];};

// Find Specific <> Tags
.util.findTags: {(first _[;y] ::) each .[2 cut where y like x;(::;1);+;1]};
.util.sliceIndex: {"", first `char$ 1_ -1_ x};

\ 
Example Usage: 

1) Write to xls file
.util.writeXlsTab["test"] or .util.writeXlsTab[`test]

2) Reverse xls file
.util.reverseEdsn[`test.xls]

3) Use .h.html to generate HTML file

h: hopen `:test.html;
.util.defineCSSStyle[];
h .h.html .util.toHTMLTab[([] a: til 3; b: 3?`3)];
hclose h;