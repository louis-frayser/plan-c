// 1. Update Ativities control when Categories is changed
// 2. Connect form validation
import { c, a, s } from "./controls.js";
import { Categories, ActionsByCatIx } from "./options-array.js";
import { validateSubmit } from "./on-submit.js";

function populate(sel, items){
    // empty then repopulate
    while (sel.firstChild){ sel.removeChild(sel.firstChild); }
    
    for (let i=0; i <  items.length; i++){
        var option = document.createElement("option");
	option.value = option.text = items[i];
        sel.appendChild(option);
    }
}

export function putOptions(){
    let csix = c.selectedIndex;
    let items = ActionsByCatIx[csix];
    populate(a, items);  
}

/* Startup */
populate(c,Categories);
putOptions();
c.onchange=putOptions;

let fx=document.getElementById('assoc_form');
fx.onsubmit=validateSubmit;

