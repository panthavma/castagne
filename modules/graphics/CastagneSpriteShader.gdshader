shader_type canvas_item;
render_mode unshaded;

uniform int paletteMode = 0;
uniform sampler2D paletteTexture;

const int PALETTEMODE_NONE = 0;
const int PALETTEMODE_MANUAL = 1;
const int PALETTEMODE_ONECHANNEL = 2;
const int PALETTEMODE_NUMBER = 2;

void fragment() {
	ivec2 spriteSize = textureSize(TEXTURE, 0);
	ivec2 spritePixelCoord = ivec2(UV*vec2(spriteSize));
	vec4 spriteColor = texelFetch(TEXTURE, spritePixelCoord, 0);
	
	if(paletteMode > PALETTEMODE_NONE && paletteMode < PALETTEMODE_NUMBER) {
		spriteColor = vec4(
			pow(spriteColor.r, 1.0/2.2),
			pow(spriteColor.g, 1.0/2.2),
			pow(spriteColor.b, 1.0/2.2),
			spriteColor.a);
		int colorID = 0;
		
		if(paletteMode == PALETTEMODE_ONECHANNEL) {
			colorID = int(spriteColor.r*255.0);
		}
		
		if(paletteMode == PALETTEMODE_MANUAL) {
			int r = int(0.5+spriteColor.r * 8.0);
			int g = int(0.5+spriteColor.g * 8.0);
			int b = int(0.5+spriteColor.b * 4.0);
			colorID = r + g*8 + b*64;
		}
		
		spriteColor = vec4(texelFetch(paletteTexture, ivec2(colorID%16, colorID/16), 0).rgb, spriteColor.a);
	}
	
	// SRGB correction
	spriteColor = vec4(
		pow(spriteColor.r, 1.0/2.2),
		pow(spriteColor.g, 1.0/2.2),
		pow(spriteColor.b, 1.0/2.2),
		spriteColor.a);
		
	COLOR = spriteColor;
}