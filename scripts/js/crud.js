document.addEventListener("DOMContentLoaded", theDomHasLoaded, false);
window.addEventListener("load", pageFullyLoaded, false);
const modes = { None : 0, Reading : 1, Creating: 2, Adding: 3, Inserting: 4, Updating: 5, Deleting: 6 };
var current_date;
var Mode;
function theDomHasLoaded(e) {
    // finish generating DOM
    // Configure DOM
    crud_date.onchange=get_data_for_date;
    add_button.onclick=local_insert;
    Mode=modes.None;
}

function pageFullyLoaded(e) {
    // Update any data dependant on the form values
    current_date=crud_date.value;

}

function get_data_for_date(){
    if (crud_date.value != current_date.value){
	crud_form.submit();
    }
}

function local_insert(){
    mode=modes.Creating;
    var  row=crud_table.insertRow(-1);
    for (i=0; i <=4; i++)
	row.insertCell(i);
    // The submit button
    row.cells[0].innerHTML='<button id="save" type="Submit"  name="req_action" value="insert">Save</button>';

    var spec = [row.cells[0]
		,{ type : "text",   id : "start", value: "09:00",          name : "stime" }
		,{ type : "text",   id : "cat",   value: "Music Practice", name : "category" }
		,{ type : "text",   id : "act",   value:  "Cello",        name : "activity" }
		,{ type : "text",   id : "dur",    value: "00:30",         name : "duration" }
		, {type : "hidden", id : "recid", value: "-1",             name : "rec_id" }
	       ];

    function make_row(i){
  	var s=  '<input '
	    + ' type="' + spec[i].type
	    + '" id="'  + spec[i].id
    	    + '" value="'  + spec[i].value
    	    + '" name="'  + spec[i].name
	    + '">';
	console.log(s);
	return s;
    }

    for (i=1; i <= 4; i++) {
	row.cells[i].innerHTML=make_row(i);
	console.log(row.cells[i].innerHTML);
    }
    Mode=modes.Adding;
}
// save.onclick=crud_form.submit;


