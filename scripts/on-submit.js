// Validation
import { Categories, ActionsByCatIx } from "./options-array.js";
import { c,a,t,s, getDuration, getSelVal, getKey, get } from "./controls.js";

export function validateSubmit(){
    let cat = getSelVal(c),
	act = getSelVal(a),
	stm = get("stime"),
    	val = getDuration(),
	ctext = ( "Category: " + cat + "\n" +
		  "Activity: " + act + "\n" +
		  "Started: " + stm + "\n" +
		  "Duration: " + val );
    return confirm(ctext);
}
