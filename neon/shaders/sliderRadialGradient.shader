uniform vec4 inColor;
uniform vec4 outColor;
uniform float centerX;
uniform float centerY;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texturecolor = Texel(tex, texture_coords);
	float len = distance(vec2(centerX, centerY), screen_coords);
	return (texturecolor * mix(inColor, outColor, len)) * 0.1;
}
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
	return transform_projection * vertex_position;
}