// Update Ativities control when Categories is changed
import { Categories, ActionsByCatIx } from "./options-array.js";

// A for activities, C for categories
var c = document.getElementById("category");
var a = document.getElementById("activity");

function populate(sel, items){
    // empty then repopulate
    while (sel.firstChild){ sel.removeChild(sel.firstChild); }
    
    for (let i=0; i <  items.length; i++){
        var option = document.createElement("option");
        option.value = i;
        option.text = items[i];
        sel.appendChild(option);
    }
}

function putOptions(){
    let cix = c.options[c.selectedIndex].value;
    let items = ActionsByCatIx[cix];
    populate(a, items);  
}

/* Startup */
c.onchange=putOptions;
populate(c,Categories);
putOptions();
