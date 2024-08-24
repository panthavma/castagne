shader_type canvas_item;

void fragment() {
	float modulation = max(abs(UV.x-0.5), abs(UV.y-0.5))*2.0;
	modulation = modulation*modulation;
	modulation = modulation*modulation;
	modulation = modulation*modulation;
	modulation = modulation*modulation;
	modulation = modulation*modulation;
	COLOR = vec4(COLOR.rgb, COLOR.a*modulation);
}