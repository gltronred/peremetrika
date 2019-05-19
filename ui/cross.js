var canvas = document.getElementById('canvas');
var context = canvas.getContext('2d');

var cross = {left:100,right:100,top:100,down:100};
var space1 = new Image();
space1.src = "cross.png";

context.clearRect(0,0,canvas.width,canvas.height);
 

space1.onload = function() { 
	context.drawImage (space1,1,1);
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
   console.log( xhr.responseText );
}
