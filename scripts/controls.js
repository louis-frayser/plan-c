// Stuff other modules need
import { Categories, ActionsByCatIx } from "./options-array.js";

// A for activities, C for categories
export var c = document.getElementById("category");
export var a = document.getElementById("activity");
export var s = document.getElementById("change");

export function getSelVal(sel){
   return sel.options[sel.selectedIndex].value;
}

export function getKey(){
    // Not currently used by may be preferrable
    // to sending back cx,ax as is currently done
    let cx = getSelVal('category'),
	ax = getSelVal('activity');
    
    return [Categories[cx],ActionsByCatIx[cx][ax]];
}

export function getDuration(){
    return document.getElementById('duration').value;
}


