// Full-screen crayon look: dark outlines along object edges, waxy grain over the image, and a
// slight hand-drawn wobble. Drawn on a screen-covering quad in front of the camera; the HUD is unaffected.
shader_type spatial;
render_mode unshaded, fog_disabled, cull_disabled, depth_test_disabled, depth_draw_never;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D normal_texture : hint_normal_roughness_texture, repeat_disable, filter_nearest;

group_uniforms outlines;
// Color of the outlines; alpha sets how strongly they cover the image.
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
// How far apart, in pixels, the samples that find an edge are; wider gives thicker lines.
uniform float line_thickness : hint_range(0.5, 4.0) = 1.5;
// Relative jump in distance that counts as an object's edge; lower finds more edges.
uniform float depth_threshold : hint_range(0.01, 0.5) = 0.08;
// Change in surface direction that counts as a crease; lower finds more creases.
uniform float normal_threshold : hint_range(0.05, 1.0) = 0.35;

group_uniforms crayon;
// How strongly the waxy grain darkens the image.
uniform float grain_strength : hint_range(0.0, 1.0) = 0.3;
// Size of the grain, in pixels.
uniform float grain_scale : hint_range(1.0, 16.0) = 3.0;
// Direction of the crayon strokes in the grain, in degrees.
uniform float stroke_angle : hint_range(0.0, 180.0) = 35.0;

group_uniforms wobble;
// How far the lines and grain shift on each wobble step, in pixels; 0 keeps everything still.
uniform float wobble_amount : hint_range(0.0, 4.0) = 0.0;
// Wobble steps per second; a low, choppy rate looks hand-drawn.
uniform float wobble_rate : hint_range(1.0, 24.0) = 8.0;

void vertex() {
	// Cover the whole screen at the near plane, whatever the camera does.
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

float hash(vec2 point) {
	return fract(sin(dot(point, vec2(127.1, 311.7))) * 43758.5453);
}

// Smooth random value from 0 to 1 that varies gently across [param point].
float value_noise(vec2 point) {
	vec2 cell = floor(point);
	vec2 local = fract(point);
	vec2 blend = local * local * (3.0 - 2.0 * local);
	float bottom = mix(hash(cell), hash(cell + vec2(1.0, 0.0)), blend.x);
	float top = mix(hash(cell + vec2(0.0, 1.0)), hash(cell + vec2(1.0, 1.0)), blend.x);
	return mix(bottom, top, blend.y);
}

// Distance from the camera of whatever is drawn at [param uv], in meters.
float linear_depth(vec2 uv, mat4 inv_projection) {
	float raw_depth = texture(depth_texture, uv).x;
	vec4 view = inv_projection * vec4(uv * 2.0 - 1.0, raw_depth, 1.0);
	return -view.z / view.w;
}

// How strongly an edge lies between [param uv] and its neighbor [param offset] away, from 0 to 1.
float edge_toward(vec2 uv, vec2 offset, float center_depth, vec3 center_normal, mat4 inv_projection) {
	vec2 neighbor = uv + offset;
	float depth_gap = abs(linear_depth(neighbor, inv_projection) - center_depth) / max(center_depth, 0.001);
	vec3 normal = texture(normal_texture, neighbor).xyz * 2.0 - 1.0;
	float normal_gap = 1.0 - dot(center_normal, normal);
	float depth_edge = smoothstep(depth_threshold, depth_threshold * 1.5, depth_gap);
	float normal_edge = smoothstep(normal_threshold, normal_threshold * 1.5, normal_gap);
	return max(depth_edge, normal_edge);
}

void fragment() {
	vec2 pixel = 1.0 / VIEWPORT_SIZE;
	// With no wobble, the step stays at 0 so the grain holds still too.
	float wobble_step = wobble_amount > 0.0 ? floor(TIME * wobble_rate) : 0.0;

	// Shift where edges are looked for by a small amount that changes on each wobble step.
	vec2 wobble_noise = vec2(
		value_noise(SCREEN_UV * 9.0 + wobble_step * 1.37),
		value_noise(SCREEN_UV * 9.0 + 17.0 + wobble_step * 2.11));
	vec2 uv = SCREEN_UV + (wobble_noise - 0.5) * 2.0 * wobble_amount * pixel;

	float center_depth = linear_depth(uv, INV_PROJECTION_MATRIX);
	vec3 center_normal = texture(normal_texture, uv).xyz * 2.0 - 1.0;
	vec2 reach = pixel * line_thickness;
	float edge = 0.0;
	edge = max(edge, edge_toward(uv, vec2(reach.x, 0.0), center_depth, center_normal, INV_PROJECTION_MATRIX));
	edge = max(edge, edge_toward(uv, vec2(-reach.x, 0.0), center_depth, center_normal, INV_PROJECTION_MATRIX));
	edge = max(edge, edge_toward(uv, vec2(0.0, reach.y), center_depth, center_normal, INV_PROJECTION_MATRIX));
	edge = max(edge, edge_toward(uv, vec2(0.0, -reach.y), center_depth, center_normal, INV_PROJECTION_MATRIX));

	// Waxy grain: soft paper noise mixed with noise stretched along the stroke direction.
	vec2 grain_uv = SCREEN_UV * VIEWPORT_SIZE / grain_scale + wobble_step * 3.17;
	float angle = radians(stroke_angle);
	mat2 stroke_rotation = mat2(vec2(cos(angle), sin(angle)), vec2(-sin(angle), cos(angle)));
	float paper = value_noise(grain_uv);
	float strokes = value_noise((stroke_rotation * grain_uv) * vec2(0.15, 1.2));
	float grain = mix(paper, strokes, 0.6);

	vec3 color = texture(screen_texture, SCREEN_UV).rgb;
	color *= 1.0 - grain_strength * (1.0 - grain);
	// Crayon lines are uneven: the grain thins them in places.
	float line = edge * mix(0.65, 1.0, grain) * outline_color.a;
	ALBEDO = mix(color, outline_color.rgb, line);
}
