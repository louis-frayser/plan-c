document.addEventListener("DOMContentLoaded", theDomHasLoaded, false);
window.addEventListener("load", pageFullyLoaded, false);
import { putOptions } from "../plan.js";
let i=0;
const modes = { None : i++,  Selecting: i++, Reading :i++, Creating: i++, Adding: i++, Inserting: i++,
		Editing: i++, Updating: i++, Deleting: i++ };
var Mode=modes.None;
var current_date;
var sels;

function theDomHasLoaded(e) {
    // finish generating DOM
    // Configure DOM
    crud_date.onchange=crud_date.onblur=get_data_for_date; // Blur is for Brave on Android
    IDB_ADD.onclick=local_insert;
    IDB_DEL.onclick=not_implemented;
    IDB_EDIT.disabled=true;

    // Set sel radio buttons to switch into selecting mode
    sels = document.getElementsByName("sel");
    function set_sel_mode(el){ Mode = modes.Selecting; IDB_EDIT.onclick=do_edit; IDB_EDIT.disabled=false; } 
    function do_sel (el){ el.addEventListener('change', set_sel_mode); }
    sels.forEach (do_sel);

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
    Mode=modes.Creating;
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


function do_edit(){
    function edit(){
	Mode=modes.Editing;
	IDB_ADD.disabled=true;
	maybe_cancel.innerHTML='<button type="button" id="cancel">Cancel</button>';
	links.hidden=true;
	let rowno=crud_form.elements["sel"].value;
	let els=assoc_form.elements;
	function getval(pfx){ return document.getElementById(pfx + rowno).innerHTML; }
	els.stime.value=crud_date.value + "T" + getval("IDSTIME");
	els.category.value=getval("IDCAT");
	putOptions();
	els.activity.value=getval("IDACT");
	els.duration.value=getval("IDDUR");
	assoc_form.rowno.value=rowno;
	crud_dlg.show();
    }

    if (Mode == modes.Selecting){
	edit();
    } else {
	return false;
    }
}


function not_implemented() {
    alert("[Del], [Add], [Edit]: Not yet fully implented!");
}


// save.onclick=crud_form.submit;


