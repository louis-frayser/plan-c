// Validation
import { Categories, ActionsByCatIx } from "./options-array.js";
import { c,a,s, getDuration, getSelVal, getKey } from "./controls.js";

export function validateSubmit(){
    let cat = getSelVal(c),
	act = getSelVal(a),
    	val = getDuration(),
	ctext = ( "Category: " + cat + "\n" +
		  "Activity: " + act + "\n" +
		  "Duration: " + val );
    return confirm(ctext);
}
