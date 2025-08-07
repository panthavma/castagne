shader_type canvas_item;

uniform ivec2 spritesheetDimensions = ivec2(1, 1);
uniform ivec2 spriteOrigin = ivec2(0);
//uniform int spriteMode = 0;

uniform int spriteIDToShow = 0;
uniform bool showOrigin = true;

uniform int paletteMode = 0;
uniform sampler2D paletteTexture;

const int PALETTEMODE_NONE = 0;
const int PALETTEMODE_MANUAL = 1;
const int PALETTEMODE_ONECHANNEL = 2;
const int PALETTEMODE_NUMBER = 2;



void fragment() {
	vec2 spriteUV = UV / vec2(spritesheetDimensions);
	ivec2 spriteToShowCoords = ivec2(spriteIDToShow % spritesheetDimensions.x, spriteIDToShow / spritesheetDimensions.x);
	spriteUV += vec2(spriteToShowCoords) / vec2(spritesheetDimensions);
	vec4 spriteColor = texelFetch(TEXTURE, ivec2(spriteUV * vec2(textureSize(TEXTURE, 0))), 0);
	
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
	//	COLOR = texture(TEXTURE, spriteUV);
	
	COLOR = vec4(
		pow(spriteColor.r, 1.0/2.2),
		pow(spriteColor.g, 1.0/2.2),
		pow(spriteColor.b, 1.0/2.2),
		spriteColor.a);
	
	vec4 originGizmo = vec4(0,0,0,0);
	
	ivec2 spriteSizePixels = textureSize(TEXTURE, 0) / spritesheetDimensions;
	ivec2 uvPixel = ivec2(vec2(UV.x, 1.0 - UV.y) * vec2(spriteSizePixels));
	
	int gizmo_CrossSize = 2;
	int gizmo_CircleSize = 8;
	int gizmo_CircleThickness = 2;
	
	// Cross to highlight
	if(abs(uvPixel.x-spriteOrigin.x) < gizmo_CrossSize || abs(uvPixel.y-spriteOrigin.y) < gizmo_CrossSize)
		originGizmo = vec4(1, 0, 1, 0.6);
	
	int distOriginToUV = int(length(vec2(uvPixel - spriteOrigin)));
	
	if(distOriginToUV <= gizmo_CircleSize + gizmo_CircleThickness)
		originGizmo = vec4(1, 0, 1, 0.8);
	
	if(distOriginToUV < gizmo_CircleSize)
		originGizmo = vec4(0,0,0,0);
	
	// Highlight the pixel
	if(uvPixel == spriteOrigin)
		originGizmo = vec4(1, 0, 1, 1);
	
	if(showOrigin)
		COLOR = mix(COLOR, vec4(originGizmo.rgb, 1), originGizmo.a);
}