// Shows an object's color only where a flashlight beam of the matching hue falls on it.
// A white beam reveals every hue. Everywhere else the object keeps its hidden color.
shader_type spatial;

// Must match Spectrum.Hue.WHITE in spectrum.gd.
const int WHITE_HUE = 7;

// Published every frame by flashlight.gd.
global uniform vec3 flashlight_position;
global uniform vec3 flashlight_direction;
global uniform float flashlight_cone_cos;
global uniform float flashlight_range;
global uniform int flashlight_hue;

// Set per object by revealable.gd.
instance uniform int hue = 0;
instance uniform vec4 reveal_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

// Color of the object while it is not revealed.
uniform vec3 hidden_color : source_color = vec3(0.05, 0.05, 0.05);
// How strongly the revealed color glows on top of the beam's own lighting.
uniform float glow_strength : hint_range(0.0, 2.0) = 0.5;
// Width of the fade at the edge of the cone, as a difference in cosine.
uniform float edge_softness : hint_range(0.001, 0.2) = 0.02;
// Fraction of the beam's range at which the reveal starts fading out with distance.
uniform float fade_start : hint_range(0.0, 1.0) = 0.6;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 to_fragment = world_position - flashlight_position;
	float distance_to_light = length(to_fragment);
	float alignment = dot(to_fragment / distance_to_light, flashlight_direction);

	float in_cone = smoothstep(flashlight_cone_cos, flashlight_cone_cos + edge_softness, alignment);
	float in_range = 1.0 - smoothstep(flashlight_range * fade_start, flashlight_range, distance_to_light);
	float hue_reveals = float(flashlight_hue == hue || flashlight_hue == WHITE_HUE);
	float reveal = in_cone * in_range * hue_reveals;

	ALBEDO = mix(hidden_color, reveal_color.rgb, reveal);
	EMISSION = reveal_color.rgb * reveal * glow_strength;
}
