/
    HTML Visualisation of qscripts provided
\

// Set Ports
@[system; "p 5014"; system["p 0W"]];

// Load util_main.q script
@[system; "l qscripts/util_main.q"; ::];

// Load entire qscripts directory
.util.loadDir[`qscripts];