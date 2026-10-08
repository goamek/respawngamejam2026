# Player

The first-person player: a body that walks, crouches and looks around, a flashlight in hand, and the on-screen hints.

- Scene: `scenes/player.tscn`
- Scripts: `scripts/player.gd` (`class_name Player`) for movement and input, `scripts/player_body.gd` (`class_name PlayerBody`) for the visible body, `scripts/hand_grip.gd` (`class_name HandGrip`) for the hands
- Shader: `shaders/first_person_body.gdshader`

Movement, inputs and the flashlight are covered in the project README and in `src/interaction/README.md`. This page is about the body.

## What the player sees of themselves

Forearms, hands and legs, and never the chest, shoulders or head. The left hand holds the flashlight. Looking down shows the belly, the legs and the right hand hanging at the side. When something is carried, the right arm comes up and reaches toward it.

## The body model

The files are in `models/`, all downloaded from Mixamo as FBX.

| File | What it is | Plays while |
|---|---|---|
| `player.fbx` | The character mesh and skeleton | |
| `idle.fbx` | Idle | Standing still |
| `walk.fbx` | Walking | Moving upright |
| `crouch_idle.fbx` | Crouching Idle | Crouched, still |
| `crouch_walk.fbx` | Crouched Walking | Crouched, moving |

How it is put together:

- **One skeleton, four animation files.** The character file holds the mesh. Each animation was downloaded "without skin", so it holds movement only, and is imported as an animation library (Import dock, **Import As: Animation Library**), set to loop. The `AnimationPlayer` inside the model lists the four libraries by name.
- **The script picks the animation.** `PlayerBody` asks the player two things each frame, whether it is moving and whether it is crouching, and fades to the matching animation over `blend_time`.
- **In place.** The two walks were downloaded with Mixamo's "In Place" box ticked. The player script moves the body; an animation that also moved it would make it slide and snap back.
- **Walk speed.** The player moves at 5.3 m/s, far faster than the recorded walk, so the walk plays at `walk_animation_speed` (1.8 times). The feet still slide a little; in first person that is hard to see.
- **Size and facing.** The character is 1.47 m tall as downloaded and faces the opposite way to Godot's forward, so the `Model` node is scaled by 1.3 and turned half a circle.

## Keeping the body by the camera

The camera does not ride on the skeleton. It stays on the player's `Head` node at eye height, so the view is steady while the body animates underneath it.

Each animation holds the shoulders somewhere of its own. Their heights do not match the player's standing and crouched eye heights (1.6 m and 0.8 m), and the crouched poses lean the whole torso well forward of the feet. So after the animation has posed the skeleton, `PlayerBody` slides the whole model to keep the base of the neck `neck_drop` (0.18 m) below the eyes and `neck_setback` (0.12 m) behind them. Crouched, that pushes the feet a little way into the floor, out of view.

The body is slid further back the further down the player looks, up to `look_down_setback` (0.5 m) more when looking straight down. Eyes are ahead of the hips, not above them: without the slide, looking down would look into the waist from on top.

One more nudge: when the flashlight is held further off than the left arm can reach, as when looking far up, the model leans toward it by the difference, so the hand never lets go.

## Leaving the chest and head undrawn

The character is one mesh with one material, so the torso cannot be switched off as a separate part, and shrinking its bones would drag the arms in with it. It is done in the shader instead. `first_person_body.gdshader` draws the body normally except for three regions, which `PlayerBody` describes to it every frame from where the bones are:

| Region | Shape | Setting |
|---|---|---|
| Chest and shoulders | Everything within `cut_radius` (0.26 m) of the upper spine, up to the neck | `cut_radius`, `waist_margin` |
| Head and hair | Everything within `head_cut_radius` (0.34 m) of the middle of the head | `head_cut_radius` |
| The right arm, while it carries nothing (off by default) | Everything within `idle_arm_radius` of the line from shoulder to fingertips | `idle_arm_radius` |

Because the regions follow the bones, a crouch that leans the body forward hides it as well as standing upright does.

The lower arms and hands are never left undrawn, however close a pose brings them to the chest or head; crouched, the flashlight hand sits well inside the head's region. A shader cannot ask which bones move a point, so when the game starts `PlayerBody` makes a copy of the mesh with that answer stored in its vertex colors (red 1 means moved wholly by the bones below an elbow), and the shader skips the regions for those points.

The upper arms fade out where they enter the torso's region, so the forearms appear to come from just off screen. The shader draws both sides of the surface, with the inside near black, so that the opening where the chest was cut away reads as shadow and not as a hole in the world.

## The shadow

The mesh the player sees casts no shadow. A second, unseen copy of it under the same skeleton, wearing the model's original material, casts the whole body's shadow, head included. Both are driven by the one skeleton, so the model is not animated twice.

## The hands

Both arms use inverse kinematics (IK): the wrist is pinned to a point and the engine works out the shoulder and elbow to match. A fixed arm pose would not do, because what the hands hold moves with the player's view. The IK is Godot's built-in `TwoBoneIK3D`, added to the skeleton by `PlayerBody` when the game starts.

After the arm is in place, a `HandGrip` node poses the hand. It is a skeleton modifier: a node that adjusts bones after the animation and after any modifier before it, which is why it sits after the arm's IK under the skeleton. It turns the wrist to match a marker, then closes the fingers and thumb. The bends are measured from the open hand the skeleton rests in and not from the animation, so the grip is the same in every animation.

Each bone of this model is twisted about its own length by a different amount, so `HandGrip` does not hinge the joints about a fixed axis. It works out each joint's hinge from the shape of the hand in its rest pose (a T-pose, palms down): fingers close toward the palm, the thumb closes across it.

The flashlight is held overhand: the palm on top of the barrel, the fingers down the far side, the thumb underneath.

| | Left hand | Right hand |
|---|---|---|
| Used while | A flashlight is held | Something is carried |
| Wrist goes to | `Grip`, a marker under `Head/Hand` | Just beside the carried object (`carry_grip_offset`) |
| Elbow bends toward | `ElbowHint`, under `Head` | `RightElbowHint`, under `Head` |
| Hand pose | `LeftHandGrip`: a closed fist | `RightHandGrip`: a loose, open cup |

The `Grip` marker reads like a hand: its position is the wrist, the fingers point along its forward direction (the opposite way to its blue arrow), and the palm faces its down (the opposite way to its green arrow). Turn the marker to turn the hand; move it to move the wrist.

Settings on each grip node, under `Body/Model/Skeleton3D`:

| Setting | Meaning |
|---|---|
| **Is Wrist Turned** | Off leaves the hand in line with the forearm and ignores the marker's rotation. |
| **Finger Curl** | How far each finger joint closes, in degrees: knuckle, middle joint, fingertip. |
| **Finger Spread** | Angle between neighbouring fingers at the knuckle, which fans them apart. |
| **Little Finger Extra** | How much further the little finger closes at the knuckle; the ring finger takes half. |
| **Thumb Curl** | How far each thumb joint closes across the palm: base, middle joint, tip. |

With no flashlight, as at the start of the school level, the left arm is left to the animation.

A carried object floats 1.4 m in front of the player, further than an arm can reach, so the right hand reaches toward it and does not touch it.

## Showing the whole body for a cutscene

Call `show_whole_body()` on the `Body` node to draw the torso, head and right arm again, and `hide_torso()` to go back. A shot that shows the player also needs its own camera, since the player's camera is where the head is.

## Settings

All are on the `Body` node in the Inspector.

| Group | Setting | Default | Meaning |
|---|---|---|---|
| | `is_torso_hidden` | on | Whether the torso and head are left undrawn. |
| Fit To Camera | `neck_drop` | 0.18 m | How far below the eyes the base of the neck is kept. |
| Fit To Camera | `neck_setback` | 0.12 m | How far behind the eyes the base of the neck is kept. |
| Fit To Camera | `look_down_setback` | 0.5 m | How much further back the body is slid when looking straight down. Raise it if the view looks into the waist. |
| Fit To Camera | `cut_radius` | 0.26 m | How far from the spine nothing is drawn. Raise it if the shoulders show; lower it if the forearms are cut short. |
| Fit To Camera | `head_cut_radius` | 0.34 m | How far from the middle of the head nothing is drawn. |
| Fit To Camera | `waist_margin` | 1.6 | How far above the hips the cut starts, as a fraction of the cut radius. Higher keeps more of the belly, seen when looking down. |
| Right Hand | `carry_grip_offset` | (0.09, -0.05, 0.07) | Where the right wrist aims, relative to a carried object, in the player's view. |
| Right Hand | `carry_grip_rotation` | (0, 0, -90) | How the right wrist is turned while carrying, in degrees; the default faces the palm inward. |
| Right Hand | `idle_arm_radius` | 0 m | Thickness of the right arm left undrawn while it carries nothing. Zero draws the arm; about 0.18 hides it. |
| Animation | `blend_time` | 0.2 s | How long one animation takes to fade into the next. |
| Animation | `walk_animation_speed` | 1.8 | How many times faster than recorded the walk plays. |
| Animation | `crouch_walk_animation_speed` | 1.2 | The same for the crouched walk. |

To swap an animation: download the new one from Mixamo with the same settings (FBX Binary, Without Skin, 30 fps, In Place where offered), save it over the old file with the same name, and let Godot re-import it. To swap the character, the new one must use the standard Mixamo skeleton, since the scripts find bones by Mixamo's names; the cut radii, the grip marker and the finger curls will need retuning to its proportions.
