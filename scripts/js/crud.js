document.addEventListener("DOMContentLoaded", theDomHasLoaded, false);
window.addEventListener("load", pageFullyLoaded, false);
var current_date;

function theDomHasLoaded(e) {
    // finish generating DOM
    // Configure DOM
    crud_date.onchange=get_data_for_date;
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



