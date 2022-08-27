/*
** Black clock code 
*/
var id;
var Timeout = 750;
function Now(){
    var today = new Date();
    var h0 = today.getHours();
    var m0 = today.getMinutes();
    var s0 = today.getSeconds();
    var ymd=today.getFullYear()	+ "-" + 
	zeroPad((today.getMonth()+1) )+ "-" +
	zeroPad(today.getDate());
    var dow=today.getDay();
    var h = zeroPad(h0), 
	m = zeroPad(m0), 
	s = zeroPad(s0);
    var tl=[24-h, 60 - m, 60 - s]; /* time left in day*/
    var sep="&nbsp;";
    
    var date_str= Now.days[dow] + sep + ymd;
    var tstr= h + ":" + m + ":" + s;

    var lstr= 
	zeroPad(tl[0]) + ":" +
	zeroPad(tl[1]) + ":" +
	zeroPad(tl[2]);
    var stimes = [date_str, tstr, lstr];
    this.strs = stimes;
}
Now.days = ["Sunday", "Monday", "Tuesday", "Wednesday", 
	    "Thursday", "Friday", "Saturday" ];

function run_clock() {
    var now = new Now();
    var idc =  document.getElementById('txcap'),
        id =  document.getElementById('txt'), 
        id2 =  document.getElementById('tx2');

    idc.innerHTML = now.strs[0];
     id.innerHTML = now.strs[1];
    id2.innerHTML = now.strs[2];

    var t = setTimeout(run_clock, Timeout);
}

function zeroPad(i) {
    if (i < 10) {i = "0" + i};  // add zero in front of numbers < 10
    return i;
}
