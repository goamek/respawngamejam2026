# Player

The first-person player: a body that walks, crouches and looks around, a flashlight in hand, and the on-screen hints.

- Scene: `scenes/player.tscn`
- Scripts: `scripts/player.gd` (`class_name Player`) for movement and input, `scripts/player_body.gd` (`class_name PlayerBody`) for the visible body

Movement, inputs and the flashlight are covered in the project README and in `src/interaction/README.md`. This page is about the body model.

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

## Three things done to the pose every frame

The camera does not ride on the skeleton. It stays on the player's `Head` node at eye height, so the view is steady while the body animates underneath it. After the animation has posed the skeleton, `PlayerBody` adjusts it:

1. **The neck is kept just below and behind the eyes.** Each animation holds the shoulders somewhere of its own. Their heights do not match the player's standing and crouched eye heights (1.6 m and 0.8 m), and the crouched poses lean the whole torso well forward of the feet, which would put the player's own back in front of the camera. So the whole model is slid each frame to keep the base of the neck `neck_drop` (0.18 m) below the eyes and `neck_setback` (0.12 m) behind them. Crouched, that pushes the feet a little way into the floor, out of view.
2. **The head is hidden.** The head bone is scaled to almost nothing, so the head and hair collapse into the neck and the camera does not look out from inside them.
3. **The left hand is put on the flashlight.** Explained next.

## The hand on the flashlight

The flashlight is attached to the camera, so it moves as the player looks up and down. A fixed arm pose would only line up at one angle, so the left arm uses inverse kinematics (IK): the hand is pinned to a point and the engine works out the shoulder and elbow to match.

- **`Grip`**, a marker under `Head/Hand`, is where the wrist goes. Move it to change how the hand meets the flashlight.
- **`ElbowHint`**, a marker under `Head`, is the direction the elbow bends toward: down and out to the left. Move it if the elbow folds the wrong way.
- The IK is Godot's built-in `TwoBoneIK3D`, added to the skeleton by `PlayerBody` when the game starts. It is switched off while the player holds no flashlight, as at the start of the school level, and the arm then follows the animation.

The legs, the spine and the right arm are untouched and keep playing the animation.

Not done yet: the fingers are open, so the hand rests against the flashlight and does not wrap it, and the wrist keeps the angle the animation gives it.

## Showing the head for a cutscene

Call `show_head()` on the `Body` node to bring the head back, and `hide_head()` to hide it again. A shot that shows the player also needs its own camera, since the player's camera is where the head is, and somewhere to put the flashlight, which otherwise floats in front of the face.

## Settings

All are on the `Body` node in the Inspector.

| Setting | Default | Meaning |
|---|---|---|
| `is_head_hidden` | on | Whether the head is hidden. |
| `neck_drop` | 0.18 m | How far below the eyes the base of the neck is kept. Raise it to see less of the shoulders. |
| `neck_setback` | 0.12 m | How far behind the eyes the base of the neck is kept. Raise it to see less of the chest when looking down. |
| `blend_time` | 0.2 s | How long one animation takes to fade into the next. |
| `walk_animation_speed` | 1.8 | How many times faster than recorded the walk plays. |
| `crouch_walk_animation_speed` | 1.2 | The same for the crouched walk. |

To swap an animation: download the new one from Mixamo with the same settings (FBX Binary, Without Skin, 30 fps, In Place where offered), save it over the old file with the same name, and let Godot re-import it. To swap the character, the new one must use the standard Mixamo skeleton, since the script finds bones by Mixamo's names.
