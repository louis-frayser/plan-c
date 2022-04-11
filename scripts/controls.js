// Stuff other modules need
import { Categories, ActionsByCatIx } from "./options-array.js";

// A for activities, C for categories
export const c = document.getElementById("category");
export const a = document.getElementById("activity");
export const s = document.getElementById("change");

export function getSelVal(sel){
   return sel.options[sel.selectedIndex].value;
}

export function getKey(){
    // Not curently used, but in the app, key = `(cat act) 
    let cat = getSelVal(c),
	act = getSelVal(a);
    return [cat,act];
}

export function getDuration(){
    return document.getElementById('duration').value;
}


