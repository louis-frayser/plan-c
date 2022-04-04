// Validation
import { Categories, ActionsByCatIx } from "./options-array.js";
import { c,a,s, getDuration, getSelVal, getKey } from "./controls.js";

export function validateSubmit(){
    let cx = getSelVal(c),
	ax = getSelVal(a),
	cat = Categories[cx];

    let act = ActionsByCatIx[cx][ax],
	val = getDuration(),
	ctext = ( "Category: " + cat + "\n" +
		  "Activity: " + act + "\n" +
		  "Duration: " + val );
    return confirm(ctext);
}
