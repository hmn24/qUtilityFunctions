function send(messages){ 
	ws.send(messages)
}

function search(){ 
	
	var msg, searchBar = document.getElementsByName('search')[0].value;
	searchBar = '\"' + searchBar + '\"';

	/* 1st Message to create the tables of dependency trees */
	if (2 == searchBar.length) {ws.send('.util.getAllFns[]');}
	else {msg = 'delete Regex from .util.genDepTree[1b;1b] `$' + searchBar; ws.send(msg);};
	
	/* 2nd Message to display the function string */
	msg = '$[(`$' + searchBar + ') in raze flip .util.getAllFns[]; .Q.s1 value ' + searchBar + ';""]'; ws.send(msg);

}


function trigger(change){
	
	var x = document.getElementsByClassName('active');
	Array.prototype.forEach.call(x, function (x) {x.style.backgroundColor = "#BCCE98"});

	document.getElementById(change).style.backgroundColor = "#80CCFF";

	document.getElementById("csvExportButton").setAttribute("onclick", "exportTableToCSV('" + change + ".csv')");

}

function reset(){
	input.innerHTML = "";
	document.getElementsByName('search')[0].value = "";
}

// Taken from https://www.codexworld.com/export-html-table-data-to-csv-using-javascript/
function downloadCSV(csv, filename) {
	var csvFile;
	var downloadLink;

	// CSV file
	csvFile = new Blob([csv], {type: "text/csv"});

	// Download link
	downloadLink = document.createElement("a");

	// File name
	downloadLink.download = filename;

	// Create a link to the file
	downloadLink.href = window.URL.createObjectURL(csvFile);

	// Hide download link
	downloadLink.style.display = "none";

	// Add the link to DOM
	document.body.appendChild(downloadLink);

	// Click download link
	downloadLink.click();
}

// Taken from https://www.codexworld.com/export-html-table-data-to-csv-using-javascript/
function exportTableToCSV(filename) {
	var csv = [];
	var rows = document.querySelectorAll("table tr");
	
	if (rows.length == 0) {output.innerHTML = "No tables to save down"; throw "No tables to save down";}

	for (var i = 0; i < rows.length; i++) {
		var row = [], cols = rows[i].querySelectorAll("td, th");
		
		for (var j = 0; j < cols.length; j++) 
			row.push(cols[j].innerText);
		
		csv.push(row.join(","));        
	}

	// Download CSV file
	downloadCSV(csv.join("\n"), filename);
}            

// Modified from https://code.kx.com/v2/wp/websockets/#a-simpledemohtml
function connect(){   
	if ("WebSocket" in window) {       
		/* its here where we should specify the correct port, i.e. for example the RDB */
		ws = new WebSocket("ws://localhost:5014/");       
		output.value="connecting...";       
		
		ws.onopen=function(e){output.innerHTML="connected";}        
		ws.onclose=function(e){output.innerHTML="disconnected";}       
		ws.onerror=function(e){output.value=e.data;} 
		
		/* when a message is received, prepend the message to the display area along with the input command  */
		ws.onmessage=function(e){ 
			var t, d = JSON.parse(e.data);
			if (typeof d == "object") { 
					if (d.length) { 
						t = '<table border="1"><tr>'
						for (var x in d[0]) {t += '<th>' + x + '</th>';}
						t += '</tr>';
						for (var i = 0; i < d.length; i++) {
							t += '<tr>'; for (var x in d[0]) {t += '<td>' + d[i][x] + '</td>';} t += '</tr>';
						}
						t += '</table>';
					} else {t = ""; for (var x in d){t += x + " | " + d[x] + "<br/>";}}
				} else {t = d;}

			if (typeof d == "object") {output.innerHTML = t;} else {input.innerHTML = t;}
			}
		}    
	}
