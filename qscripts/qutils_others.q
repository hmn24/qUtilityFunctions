// Load the script with 
/ q qutils_others.q -p 5014
/ This would allow one to view the meta of any tables existing within q in verbose format with the qutils_others.html script

// Generate the data and attribute types from existing KDB tables in verbose form
/ This is only for tables in the root namespace (can be combined with qutils_dependencyTree.q in the future, with some modifications, for all tables
/ This would need to be linked to the use of .qutils.tabDict
.qutils.getTabMeta: {
    typeDict: (upper[c], c: .Q.t a)!(`$"list of ",/: string b), b: key'[(a:5h$ where " " <> 20#.Q.t) $\: ()]; 
    attributeDict: `s`u`p`g!`sorted`unique`parted`grouped;
    @[a!meta each a; a:tables[]; ?[; (); 0b; (`$("Column Names";"Data Types";"Attribute Types"))!(`c;(typeDict;`t);(attributeDict;`a))]]
    };

// To write to an xls file with tabs for every corresponding table_name-meta combo
.qutils.writeXlsTab: {[filePath] hsym[`$ ssr[`$ raze string filePath;".xls";""], ".xls"] 0: .h.edsn .qutils.getTabMeta[]};

// An example of using this function is:
/ .qutils.writeXlsTab["test"] or .qutils.writeXlsTab[`test]



// For the purpose of "reversing" the .h.edsn xls file generated above, i.e. parsing through its XML (xls) structure
.qutils.reverseEdsn: {
    ws: .qutils.strFilt[read0 hsym `$ raze string x; "*<Worksheet *"];
    ws_key: `$ sublist'[(first ss[;"\""]@) each b; b: raze (count[b] + ws ss\: b:"Worksheet ss:Name=\"") _' ws];
    ws_key!.qutils.parseXML each ws
    };

.qutils.strFilt: {x where x like y};

.qutils.genIntervs: {-1_ (1+)\[y>=;x]};

.qutils.parseXML: {
    b: a[.qutils.genIntervs .' 2 cut where (a: (-1_ 1+ x ss ">") _ x) like "*[</]Row>*"]; 
    (count[c]#"*"; enlist csv) 0: csv 0: c: flip @[b; til count b; ssr[;"</Data>";""] each .qutils.strFilt[;"*</Data>"] @]
    };
    
// An example of using this function for the above is:
/ .qutils.reverseEdsn["test.xls"] or .qutils.reverseEdsn[`test.xls]


// For purposes of parsing into HTML structure for .qutils.getTabMeta[] generated above
/ Create the corresponding button tags 
/ To ensure the attached HTML page works with the above verbose meta information, one need to turn on the -p 5014 port or change the qutils_other.html port to match the ideal websocket output
.qutils.dColons: {"\"", x, "\""};
.qutils.createHTMLStruct: {.h.htac[`button; `id`onclick`class!`$.qutils.dColons each (x; "send('.qutils.getTabMeta[] @ `", x, "');trigger('", x, "');"; "active"); x]};

/ .z.ws is defined for the HTML structure to properly work above in conjunction with the qutils_other.html file provided in this repo
.z.ws: {neg[.z.w] .j.j @[value;x;`$"'",];};



/ Define the css styles of the HTML document for the sample tables
.qutils.defineCSSStyle: {
    .h.sa: .h.htc[`style; "table {font-family: arial, sans-serif; border-collapse: collapse; width: auto !important;}"]; 
    .h.sb: .h.htc[`style; "td, th {border: 1px solid #dddddd; text-align: left; padding: 4px;}"];
    .h.sc: .h.htc[`style; "tr:nth-child(even) {background-color: #dddddd;}"];
    }; 

/ Generation of each rows of HTML table
.qutils.htc: {.h.htc[z] raze .h.htc[y] each x};

/ To generate the q table in HTML format
.qutils.toHTMLTab: {[tab] .h.htc[`table] {x, .qutils.htc["," vs y;`td;`tr]}/[.qutils.htc["," vs wo_head 0;`th;`tr]; 1_ wo_head:csv 0: tab]};

/ Example of using above function using .h.html to capture the above styles specified is:
/ h: hopen `:test.html;
/ .qutils.defineCSSStyle[];
/ h .h.html .qutils.toHTMLTab[([] a: til 3; b: 3?`3)];
/ hclose h;

