// Draws a surface in grey until a flashlight beam of its hue, or a white beam, falls on it; there its real color shows.
// Unlike reveal.gdshader the surface still takes light and shade while grey, so set dressing reads as part of the room.
shader_type spatial;

// Must match Spectrum.Hue.WHITE in spectrum.gd.
const int WHITE_HUE = 7;
// Value of hue for a picture of many colors, where each pixel shows under the hue nearest its own; must match true_colors.gd.
const int PICTURE_HUE = -2;
// Where each spectrum hue sits on the color wheel, in degrees, in the order of Spectrum.Hue; worked out from Spectrum.COLORS.
const float HUE_ANGLES[7] = float[7](0.0, 24.0, 54.0, 126.0, 222.0, 261.0, 283.0);
// How much each of red, green and blue adds to how bright a color looks; used to turn a color into its grey.
const vec3 BRIGHTNESS_WEIGHTS = vec3(0.2126, 0.7152, 0.0722);

// Published every frame by flashlight.gd.
global uniform vec3 flashlight_position;
global uniform vec3 flashlight_direction;
global uniform float flashlight_cone_cos;
global uniform float flashlight_range;
global uniform int flashlight_hue;

// Hue the beam must be for the real color to show, or PICTURE_HUE.
uniform int hue = 0;
// In a picture, how strong a pixel's color must be to count as colored: below the first it never changes, above the second it fully does.
uniform vec2 picture_color_range = vec2(0.2, 0.4);
// Whether only the strongly colored parts of the surface ever show, such as paint on a wooden floor; the rest stays grey under every beam.
uniform bool is_paint_only = false;
// On a paint-only surface, how strong a pixel's color must be to count as paint, in the same way as picture_color_range.
uniform vec2 paint_color_range = vec2(0.8, 0.9);
// In a picture, how much further than its nearest hue a color may be from the beam's hue and still show, in degrees.
uniform float picture_hue_overlap : hint_range(1.0, 40.0) = 16.0;
// How brightly the real color shows inside the beam; it gives off its own light there, so the beam cannot wash it out.
uniform float glow_strength : hint_range(0.0, 2.0) = 0.9;
// Width of the fade at the edge of the cone, as a difference in cosine.
uniform float edge_softness : hint_range(0.001, 0.2) = 0.02;
// Fraction of the beam's range at which the color starts fading out with distance.
uniform float fade_start : hint_range(0.0, 1.0) = 0.6;

group_uniforms surface;
// Copied from the material this one stands in for, by true_colors.gd.
uniform vec4 albedo : source_color = vec4(1.0);
uniform sampler2D albedo_texture : source_color, hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D normal_texture : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D roughness_texture : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D metallic_texture : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool has_normal_texture = false;
uniform float normal_scale = 1.0;
uniform float roughness : hint_range(0.0, 1.0) = 1.0;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float specular : hint_range(0.0, 1.0) = 0.5;
uniform vec3 uv_scale = vec3(1.0);
uniform vec3 uv_offset = vec3(0.0);
// Whether textures are laid on from the three world axes instead of the mesh's own UVs.
uniform bool is_triplanar = false;

varying vec3 world_position;
varying vec3 triplanar_position;
varying vec3 triplanar_weights;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	if (is_triplanar) {
		// Same layout as Godot's own world triplanar, so the stand-in lines up with the original.
		vec3 world_normal = MODEL_NORMAL_MATRIX * NORMAL;
		vec3 facing = abs(world_normal);
		TANGENT = vec3(0.0, 0.0, -1.0) * facing.x + vec3(1.0, 0.0, 0.0) * facing.y + vec3(1.0, 0.0, 0.0) * facing.z;
		TANGENT = inverse(MODEL_NORMAL_MATRIX) * normalize(TANGENT);
		BINORMAL = vec3(0.0, 1.0, 0.0) * facing.x + vec3(0.0, 0.0, -1.0) * facing.y + vec3(0.0, 1.0, 0.0) * facing.z;
		BINORMAL = inverse(MODEL_NORMAL_MATRIX) * normalize(BINORMAL);
		triplanar_weights = facing / (facing.x + facing.y + facing.z);
		triplanar_position = (world_position * uv_scale + uv_offset) * vec3(1.0, -1.0, 1.0);
	} else {
		UV = UV * uv_scale.xy + uv_offset.xy;
	}
}

// Reads [param map] at the mesh's UV, or blended from the three world axes when the surface is triplanar.
vec4 read_map(sampler2D map, vec2 uv, vec3 position, vec3 weights) {
	if (!is_triplanar) {
		return texture(map, uv);
	}
	vec4 blended = texture(map, position.xy) * weights.z;
	blended += texture(map, position.xz) * weights.y;
	blended += texture(map, position.zy * vec2(-1.0, 1.0)) * weights.x;
	return blended;
}

// How well [param color] belongs to the beam's hue, from 0 to 1. A color belongs to the hue nearest it on the color
// wheel, and one that sits between two hues belongs to both, so that a grain of mixed shades shows evenly.
float picture_match(vec3 color) {
	if (flashlight_hue < 0 || flashlight_hue >= 7) {
		return 0.0;
	}
	// Judged the way the eye sees it, not in the linear values lighting uses, so that it agrees with HUE_ANGLES.
	vec3 seen = pow(max(color, vec3(0.0)), vec3(1.0 / 2.2));
	float angle = degrees(atan(sqrt(3.0) * (seen.g - seen.b), 2.0 * seen.r - seen.g - seen.b));
	float nearest_gap = 360.0;
	for (int index = 0; index < 7; index++) {
		nearest_gap = min(nearest_gap, abs(mod(angle - HUE_ANGLES[index] + 540.0, 360.0) - 180.0));
	}
	float beam_gap = abs(mod(angle - HUE_ANGLES[flashlight_hue] + 540.0, 360.0) - 180.0);
	return 1.0 - smoothstep(picture_hue_overlap * 0.5, picture_hue_overlap, beam_gap - nearest_gap);
}

// How far the real [param color] shows at [param position] in the world, from 0 outside a revealing beam to 1 inside it.
float reveal_at(vec3 position, vec3 color) {
	vec3 to_fragment = position - flashlight_position;
	float distance_to_light = length(to_fragment);
	float alignment = dot(to_fragment / distance_to_light, flashlight_direction);

	float in_cone = smoothstep(flashlight_cone_cos, flashlight_cone_cos + edge_softness, alignment);
	float in_range = 1.0 - smoothstep(flashlight_range * fade_start, flashlight_range, distance_to_light);
	float in_beam = in_cone * in_range;
	float brightest = max(color.r, max(color.g, color.b));
	float strength = (brightest - min(color.r, min(color.g, color.b))) / max(brightest, 0.001);
	if (is_paint_only) {
		in_beam *= smoothstep(paint_color_range.x, paint_color_range.y, strength);
	}
	if (flashlight_hue == WHITE_HUE) {
		return in_beam;
	}
	if (hue != PICTURE_HUE) {
		return in_beam * float(flashlight_hue == hue);
	}
	// Paper, ink and other near-grey parts of a picture look the same either way, so they are left to the light.
	float is_colored = smoothstep(picture_color_range.x, picture_color_range.y, strength);
	return in_beam * is_colored * picture_match(color);
}

void fragment() {
	vec3 true_color = albedo.rgb * read_map(albedo_texture, UV, triplanar_position, triplanar_weights).rgb;
	vec3 grey = vec3(dot(true_color, BRIGHTNESS_WEIGHTS));
	float reveal = reveal_at(world_position, true_color);

	ALBEDO = grey;
	EMISSION = true_color * reveal * glow_strength;
	ROUGHNESS = roughness * read_map(roughness_texture, UV, triplanar_position, triplanar_weights).r;
	METALLIC = metallic * read_map(metallic_texture, UV, triplanar_position, triplanar_weights).r;
	SPECULAR = specular;
	if (has_normal_texture) {
		NORMAL_MAP = read_map(normal_texture, UV, triplanar_position, triplanar_weights).rgb;
		NORMAL_MAP_DEPTH = normal_scale;
	}
}

void light() {
	// Only the strength of a light is kept, not its tint: a red beam on a grey locker would otherwise turn it red
	// and look like a reveal. Where the real color is showing, the surface's own glow takes over from the light.
	float strength = max(LIGHT_COLOR.r, max(LIGHT_COLOR.g, LIGHT_COLOR.b));
	float facing = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	vec3 true_color = albedo.rgb * read_map(albedo_texture, UV, triplanar_position, triplanar_weights).rgb;
	DIFFUSE_LIGHT += vec3(strength * facing * ATTENUATION / PI) * (1.0 - reveal_at(world_position, true_color));
}
