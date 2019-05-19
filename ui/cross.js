var canvas = document.getElementById('canvas');
var context = canvas.getContext('2d');

var cross = {left:100,right:100,top:100,down:100};
var space1 = new Image();
var carsprites = Array();
var timer;
var svetTime = [42,2,42,3];
var svetfull = 90;
var speed = 52;

space1.src = "cross.png";

for (i=0;i<4;i++) {
	carsprites[i] = new Image();
	carsprites[i].src = 'car'+(i+1)+'.jpg';
}


context.clearRect(0,0,canvas.width,canvas.height);
 

space1.onload = function() { 
	context.drawImage (space1,1,1);
}

function redraw (){
	context.drawImage (space1,1,1);
	svet=time1%svetfull;
	for (i=0;svet>0;i++) svet-=svetTime[i];
	//drawSvet(i-1);
	//console.log (fcd[time1].vehicles.length);
	//context.drawImage (carsprites[0],10,10);
	for (i=0;i<fcd[time1].vehicles.length;i++) {
		if ((+fcd[time1].vehicles[i].angle %180)<90) {
			context.drawImage (carsprites[1],510+10*fcd[time1].vehicles[i].x,675-8*fcd[time1].vehicles[i].y);
		}
		else {
			context.drawImage (carsprites[0],510+10*fcd[time1].vehicles[i].x,675-8*fcd[time1].vehicles[i].y);
		}//console.log (fcd[time1].vehicles[i].y);
	}
	
	time1++;
	
}

function drawSvet(state){
	if (state==0) {color1="green";color2="red"}
	else if (state==1) {color1="yellow";color2="red"}
	else if (state==2) {color1="red";color2="green"}
	else {color1="red";color2="yellow"}
	
	context.fillStyle=color1;
	context.fillRect(682,233,4,52);
	context.fillRect(557,287,4,52);
	context.fillStyle=color2;
	context.fillRect(595,195,26,4);
	context.fillRect(621,374,26,4);
}
		

function run2() {
time1=0;
mode="demo";

if (!timer) timer = setInterval(redraw,200);
}
function run(){
	var xhr = new XMLHttpRequest();
	req="http://peremetrika.gltronred.info/query?speed="+document.getElementById("speed").value+"&svetofor=";
	for (i=1;i<4;i++) req+=document.getElementById("sv"+i).value+",";
	req+=document.getElementById("sv4").value;

	xhr.open('POST', req, false);
    xhr.send();

	if (xhr.status != 200) {
		alert("error");
		return;
	}
	fcd2=JSON.parse(xhr.responseText);
	fcd=fcd2.fcd;
	console.log( xhr.responseText );
	time1=0;
	mode="demo";

	if (!timer) timer = setInterval(redraw,200);
}

function entw1(){
	svetfull=0;
	for (i=0;i<4;i++){
		svetTime[i]=document.getElementById("sv"+(i+1)).value;
		svetfull+=svetTime[i];
	}
	speed=document.getElementById("speed").value;
}