// -- This script is mainly for the use of the HTML visualisation interface to work with the qscripts provided here

/ If this setting of port fails, proceed to set the next available port -> This would require the changing of ports within the html files
@[system; "p 5014"; system["p 0W"]];

/ Initialise function load the directory scripts
.util.loadDir: {op: (@[system;;::] "l ", _[1]  @) each string .Q.dd'[a; key a: hsym x]; -1 $[not all null op;"Error loading q scripts";"Loading q scripts successfully"];};

/ Load all the key scripts for the html interfaces to work
.util.loadDir[`qscripts];

