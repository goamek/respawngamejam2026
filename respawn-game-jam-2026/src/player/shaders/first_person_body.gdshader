// Draws the player's own body for a first-person camera: everything except the torso, shoulders and head.
// Nothing is drawn within a set distance of the spine, from the waist to the neck, or within a ball around the head,
// so the forearms, hands and legs are all the player sees of themselves. Both follow the pose, so a crouch that
// leans the body forward hides it just as well as standing upright.
// The lower arms and hands are always drawn, however close a pose brings them to the torso or head: player_body.gd
// marks them in the mesh's vertex colors, by which bones move them, so they are told apart by what they are, not where.
// An arm with nothing to do can be left out as well, so it does not hang in view cut off at the shoulder.
shader_type spatial;
// Both sides of the surface are drawn: where the torso was cut away the player can see into the body,
// and the inside is drawn dark, so the opening reads as shadow and not as a hole in the world.
render_mode cull_disabled;

// The model's own color and surface detail, copied from its imported material.
uniform sampler2D albedo_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D normal_texture : hint_normal, filter_linear_mipmap, repeat_enable;

// Set every frame by player_body.gd, in global space.
// Ends of the spine, waist and neck, and how far around it nothing is drawn; a radius of zero or less draws the torso.
uniform vec3 spine_start = vec3(0.0);
uniform vec3 spine_end = vec3(0.0);
uniform float cut_radius = 0.0;
// Middle of the head and how far around it nothing is drawn; a radius of zero or less draws the head.
uniform vec3 head_center = vec3(0.0);
uniform float head_radius = 0.0;
// Ends of the arm to leave out, shoulder and fingertips, and how thick it is; a radius of zero or less draws the arm.
uniform vec3 idle_arm_start = vec3(0.0);
uniform vec3 idle_arm_end = vec3(0.0);
uniform float idle_arm_radius = 0.0;

// Color of the inside of the body, seen where it was cut open.
uniform vec3 inside_color : source_color = vec3(0.02, 0.015, 0.015);

varying vec3 world_position;
// How much of this point is moved by the bones of a lower arm or hand, from 0 to 1.
varying float lower_arm_weight;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	lower_arm_weight = COLOR.r;
}

// Distance from a point to the nearest point on the line between two ends.
float distance_to_segment(vec3 point, vec3 start, vec3 end) {
	vec3 along = end - start;
	float place = clamp(dot(point - start, along) / max(dot(along, along), 0.0001), 0.0, 1.0);
	return distance(point, start + along * place);
}

void fragment() {
	if (lower_arm_weight < 0.5) {
		if (distance_to_segment(world_position, spine_start, spine_end) < cut_radius) {
			discard;
		}
		if (distance(world_position, head_center) < head_radius) {
			discard;
		}
	}
	if (distance_to_segment(world_position, idle_arm_start, idle_arm_end) < idle_arm_radius) {
		discard;
	}
	if (FRONT_FACING) {
		ALBEDO = texture(albedo_texture, UV).rgb;
		NORMAL_MAP = texture(normal_texture, UV).rgb;
	} else {
		ALBEDO = inside_color;
	}
	ROUGHNESS = 1.0;
	SPECULAR = 0.5;
}
