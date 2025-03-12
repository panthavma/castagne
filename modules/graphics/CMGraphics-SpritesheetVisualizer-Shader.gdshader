shader_type canvas_item;

uniform ivec2 spritesheetDimensions = ivec2(1, 1);
uniform ivec2 spriteOrigin = ivec2(0);
//uniform int spriteMode = 0;

uniform int spriteIDToShow = 0;
uniform bool showOrigin = true;


void fragment() {
	vec2 spriteUV = UV / vec2(spritesheetDimensions);
	ivec2 spriteToShowCoords = ivec2(spriteIDToShow % spritesheetDimensions.x, spriteIDToShow / spritesheetDimensions.x);
	spriteUV += vec2(spriteToShowCoords) / vec2(spritesheetDimensions);
	
	COLOR = texture(TEXTURE, spriteUV);
	
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