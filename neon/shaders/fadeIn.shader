uniform float time;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texturecolor = Texel(tex, texture_coords);
	texturecolor.a += time;
	return texturecolor;
}
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
	return transform_projection * vertex_position;
}