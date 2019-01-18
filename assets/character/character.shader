shader_type canvas_item;

uniform vec2 disp = vec2(0,0);
uniform float limit = 0.9;

void vertex(){
//	VERTEX += disp;
	if(COLOR.g > 0.1){
		VERTEX.x += disp.x * 0.75;
		//VERTEX.y += disp.y * 0.5;
	}
	if(COLOR.r > limit){
		VERTEX.y += (disp.x * COLOR.r) / 3.0;
	}
	if(COLOR.b > limit){
		VERTEX.y += (-disp.x * COLOR.b) / 3.0;
	}
	
	if(VERTEX.y == 0.0){
		VERTEX.y = VERTEX.y + 1.0	
	}
	
}

void fragment(){
	COLOR = vec4(1,1,1,1);
}