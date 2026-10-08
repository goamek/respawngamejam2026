# Entity

The creature that hunts the player. It roams the level, chases the player for as long as it can see them, hunts for them where it lost them, comes to check noises, and catches the player if it reaches them.

- Scene: `scenes/entity.tscn`
- Script: `scripts/entity.gd` (`class_name Entity`)

The body is a rigged character from Mixamo, shown solid black with two white eyes, 1.8 m tall. See **Model and animations** below.

## Status

| Part | Status |
|---|---|
| Walking around walls (navigation) | Built |
| Roaming between patrol points | Built |
| Opening and closing doors | Built |
| Seeing the player | Built |
| Noticing the flashlight's lit spot when the player is out of view | Built |
| Investigating the last place it noticed the player | Built |
| Hearing footsteps and doors | Built |
| Hiding spots | Built |
| Catching the player | Built |
| Model and animations | Built |

## States

The entity is always in exactly one state.

| State | What it does | Moves to |
|---|---|---|
| `PAUSING` | Stands still for `pause_time`. Also the starting state. | `ROAMING` when the pause ends |
| `ROAMING` | Walks to a randomly chosen patrol point at `roam_speed`. | `PAUSING` on arrival or when blocked |
| `INVESTIGATING` | Hurries to `last_known_position` at `investigate_speed`, whether that is the player or a noise. On arrival, turns to face the player if it can still see them. | `SEARCHING` on arrival or when blocked, once the player is out of sight |
| `SEARCHING` | Turns on the spot for `search_time`, looking around. | `PAUSING` when the time runs out |
| `CATCHING` | Stands still facing the caught player. | `PAUSING` when reset with `reset_after_catch()` |
| `WATCHING` | Scripted: stands still and stares at the player. Entered with `watch_player()`. | Whatever the script sends it to next |
| `LEAVING` | Scripted: walks to a given spot at `roam_speed`. Entered with `leave_to(spot)`. | `PAUSING` on arrival or when blocked |
| `UNCOVERED` | Stands still facing the player, in full color, harmless. Entered when white light has been held on it for `uncover_time`. | Nothing; the game ends |

From any state except `CATCHING`, `WATCHING`, `LEAVING` and `UNCOVERED`, noticing the player or hearing a noise switches it to `INVESTIGATING`. In `WATCHING` and `LEAVING` its senses are off: it does not notice the player, their light or any noise, and cannot catch them. They are used by the first sighting (`src/level/scripts/first_sighting.gd`), which also keeps the entity hidden and switched off until that moment.

```
            pause ends
 PAUSING ---------------> ROAMING
    ^   <---------------     |
    |    arrived / blocked   |
    |                        |  notices player (from any state)
    |                        v
 SEARCHING <------------ INVESTIGATING ----> CATCHING
   (time up -> PAUSING)    arrived, player    player in reach
                           out of sight       (reset -> PAUSING)
```

## Noticing the player

Checked every physics frame. Whether the player is moving, and whether their flashlight is on, make no difference to being seen.

### Spotting

The entity spots the player when all of these are true:

1. **In range:** within `sight_range` of the entity's eyes.
2. **In view:** within `sight_angle` of straight ahead, or closer than `awareness_radius` in any direction. The second part means it cannot be hugged from behind.
3. **Nothing in between:** a ray from the eyes reaches the player's head or body before hitting anything on the world layer. Walls, closed doors and the carry box block it. Pickups such as crayons do not.
4. **Not hiding:** the player is not crouched in a hiding spot (see below).

It also spots the player through their light, even when the player themselves is out of view:

1. **The flashlight is on**, and the center of its beam lands on a surface.
2. **That lit spot is in range and in view**, by the same rules as above.
3. **Nothing blocks its view of the spot.**

The entity is smart enough to tell where the light comes from, so it heads for the player, not for the lit spot.

### Tracking

Once it has spotted the player it is tracking them, and two of the rules relax:

- **The view angle no longer matters.** It keeps seeing the player anywhere within `sight_range` as long as nothing is in between, so running round it does not shake it off.
- **Hiding spots no longer work.** It watched the player get in.

`last_known_position` follows the player every frame while they are seen.

### Losing the player

The only way to be lost is to put a wall or a closed door in the way, or to get out of range.

1. For `sight_memory` (1 second) after that, the entity still knows where the player really is and keeps heading there. This carries it round the corner or through the door the player just took, where it will usually see them again.
2. After that it stops tracking. It runs to the last position it knew, looks around (`SEARCHING`), and goes back to roaming.
3. From then on it has to spot the player afresh, so a hiding spot works again.

### Hiding spots

A hiding spot is an invisible region under a piece of furniture (`src/level/scripts/hiding_spot.gd`). A player who is crouched inside one cannot be spotted, however close the entity comes and whatever it can see. A player who is being tracked when they get in gains nothing from it. The entity remembers watching them hide, and until they come out again:

- it counts as seeing them even where the furniture blocks its view, so it never loses them and wanders off;
- it catches them from `hiding_catch_reach` (2.2 m) whichever way it faces, as if dragging them out. Furniture such as the desk has solid panels that keep its body further away than its normal reach.

Tracking includes the `sight_memory` second after losing sight, so ducking round a corner and straight under a desk does not count as hiding unseen.

How to add one is in `src/interaction/README.md`.

## Hearing

Two things make a noise the entity can hear:

| Noise | Carries | Setting |
|---|---|---|
| Each footstep the player takes standing up | 4 m | `step_noise_range` on the player |
| The player opening or closing a door | 6 m | `noise_range` on the door |

Crouched footsteps are silent, and so are doors the entity opens itself. Sneaking past it closer than 4 m means crouching.

A noise carries its distance in a straight line, through walls. An entity within that distance runs to where the noise came from and searches there. It learns the spot, not where the player is, so making a noise and leaving sends it the wrong way.

It ignores a noise while it is already tracking the player, while catching, while asleep or scripted (the first sighting), and when the noise comes from inside a safe room it is still kept out of.

Anything else can make a noise with one call: `EntityHearing.make_noise(get_tree(), global_position, range_in_meters)` (`scripts/entity_hearing.gd`).

## Catching the player

The entity catches the player when all of these are true:

1. **It can see the player right now**, by the rules above. Standing still does not help; a player in a hiding spot it never saw them enter is safe.
2. **The player is within `catch_reach`.**
3. **The player is within `catch_angle` of straight ahead.** Closer than 0.3 m counts whatever the angle, because the two bodies pass through each other.

   Rules 2 and 3 are replaced by one distance, `hiding_catch_reach`, for a player in a hiding spot the entity watched them get into.
4. **The catch cooldown has run out.** It starts after every reset, so the player cannot be caught again the moment they respawn.

On a catch it switches to `CATCHING`, stands still facing the player, and emits `player_caught`. What happens next belongs to the level's `CatchHandler` (`src/level/scenes/catch_handler.tscn`):

1. The player's controls turn off, the camera shakes, and their view snaps to the entity's face in 0.15 s. At the same moment the entity leaps up and lunges in, so its face ends up just above the player's eyes and about 0.3 m closer (`catch_leap_time`, `catch_leap_above_eyes`, `catch_lunge_distance`); it is shorter than the player, and from standing height they would otherwise only see the top of its head. Its face is then held at that spot for the rest of the catch, even as the animation hunches down and leans in, so the player's view stays steady instead of drifting. The lunge never brings it closer than 0.45 m, so it cannot pass through the camera. They stare at it for 1.45 s while the shake fades. The view keeps following the face until the screen is black (`follow_speed` on the catch handler sets how tightly).
2. A life is lost (`GameSession`, an autoload).
3. The screen cuts to black in 0.2 s (`fade_out_time`) with "Caught. 2 lives left", then "Caught. 1 life left", then "Game Over".
4. With lives left: the player respawns at the handler's spawn point, every entity goes back to where it started, and the screen fades back in over 0.6 s (`fade_in_time`).
5. With no lives left: the handler emits `run_ended`. If its **Main Menu Scene** is set, a new run starts with 3 lives and the menu loads. The school level points it at `src/ui/scenes/main_menu.tscn`. The test levels leave it empty, so there the game quits instead; when playing from the editor, that just stops the running game.

A level with no `CatchHandler` leaves a caught entity standing in `CATCHING` and the player untouched.

## Uncovering it (the secret ending)

While the player's beam is white, is on the entity's chest, and the entity can see the player, a meter fills. It drains at the same rate whenever any of those stops being true. As it fills:

- the entity moves at `uncover_slowdown` times its usual speed (0.35), which is what gives the player time;
- its black fades toward the colors of its own texture, and they start to glow faintly.

After `uncover_time` (3 seconds) it stops, switches to `UNCOVERED`, and emits `uncovered`. It can still catch a player it reaches before then. Being reset after a catch empties the meter and turns it black again.

The body's material in `scenes/entity.tscn` is the model's texture tinted black, so at an empty meter it looks exactly as before.

## Settings

All are shown in the Inspector on the entity.

| Group | Setting | Default | Meaning |
|---|---|---|---|
| Roaming | `patrol_points` | empty | Markers the entity wanders between, in random order. Never the same one twice in a row. |
| Roaming | `roam_speed` | 1.8 m/s | Walking speed while roaming. |
| Roaming | `pause_time` | 2 s | Time spent standing at each patrol point. |
| Senses | `sight_range` | 12 m | How far it can see. |
| Senses | `sight_angle` | 60 degrees | Half the width of its view (120 degrees in total). Only matters for first spotting the player. |
| Senses | `awareness_radius` | 1.5 m | Distance within which it senses the player in any direction, even behind it. |
| Senses | `sight_memory` | 1 s | Time it keeps knowing where the player is after losing sight of them. |
| Investigating | `investigate_speed` | 3.8 m/s | Speed while heading to the spot it is checking. |
| Investigating | `search_time` | 3 s | Time spent looking around after arriving. |
| Investigating | `search_turn_speed` | 90 degrees/s | Turning speed while looking around. |
| Catching | `catch_reach` | 1.2 m | How close the player must be to be caught. |
| Catching | `catch_angle` | 45 degrees | How far off straight ahead the player may be and still be caught. |
| Catching | `hiding_catch_reach` | 2.2 m | How close it must get to drag out a player it watched get into a hiding spot. Sized to reach anywhere under a desk from any side. |
| Catching | `catch_cooldown` | 3 s | Time after a reset during which it cannot catch. |
| Movement | `turn_speed` | 240 degrees/s | How fast it turns to face where it is walking. |
| Movement | `speed_gain_per_hue` | 0.05 | How much faster it gets for each crayon the player has, as a fraction of its speeds. With all seven it moves 1.35 times as fast, which is still slower than the player. |
| Movement | `stuck_time` | 1.5 s | How long it may be blocked before giving up on a destination. |

For comparison, the player moves at 5.3 m/s standing and 1.5 m/s crouched, and cannot sprint. An investigating entity moves at 3.8 m/s with no crayons collected and 5.13 with all seven, so the player can always outrun it in the open, by less and less as the game goes on.

## Model and animations

The files are in `src/entity/models/`, all downloaded from Mixamo as FBX.

| File | What it is | Plays while |
|---|---|---|
| `entity.fbx` | The character mesh and skeleton | |
| `idle.fbx` | Thriller Idle | Pausing |
| `walk.fbx` | Walking | Roaming |
| `run.fbx` | Running | Investigating (chasing) |
| `search.fbx` | Nervously Look Around | Searching |
| `catch.fbx` | Zombie Scream | Catching |

How it is put together:

- **One skeleton, five animation files.** The character file holds the mesh. Each animation file was downloaded "without skin", so it holds movement only, and is imported as an animation library (Import dock, **Import As: Animation Library**). The entity scene's `AnimationPlayer` lists the five libraries by name.
- **The state picks the animation.** `STATE_ANIMATIONS` in `entity.gd` maps each state to a library. Whenever the state changes, the new animation fades in over `animation_blend_time` (0.25 s).
- **Looping** is set in each file's import settings: every animation loops except the catch, which plays once. The catch plays at twice normal speed (`catch_animation_speed`), so the 2.8 s scream takes 1.4 s; it then holds its last pose until the screen is black at 1.8 s.
- **In place.** The walk and run were downloaded with Mixamo's "In Place" box ticked. The script moves the body; an animation that also moved it would make it slide and snap back.
- **Solid black.** The mesh has a black material set over its own textures in the entity scene (`Model/Skeleton3D/Ch14`, Material Override). The material is pure black with a soft sheen (specular 0.3, roughness 0.6), so it is a flat silhouette in the dark but picks up a dull glow in the beam's color where the flashlight hits it, like wax crayon. Without the sheen the beam seemed to pass straight through it. The original colored textures are still in the file, for the ending where the black comes off.
- **Eyes.** Two white spheres sit under a `BoneAttachment3D` on the head bone, so they follow the head through every animation.
- **Size and facing.** The character is 1.33 m tall as downloaded and faces the opposite way to Godot's forward, so the `Model` node is scaled by 1.35 and turned half a circle.

To swap an animation: download the new one from Mixamo with the same settings (FBX Binary, Without Skin, 30 fps, In Place where offered), save it over the old file with the same name, and let Godot re-import it. To swap the character, the new one must use the standard Mixamo skeleton, and the eye positions under `Head` will need moving.

## Safe rooms

A room with a `SafeRoom` area over it (`src/level/scripts/safe_room.gd`) is closed to the entity until something calls the room's `open_to_entity()`, normally the room's puzzle being solved. While it is closed the entity:

- stops at the edge of the room instead of walking in, even when it has seen the player inside,
- never picks a patrol point inside it,
- cannot catch a player who is standing inside it, even from within reach across the doorway.

It will still come to the doorway and look in. How to set one up is in `src/interaction/README.md`.

## Movement notes

- It steps onto lips up to 0.3 m high, such as the side of a ramp or the foot of a door frame. The walkable area counts anything up to 0.25 m as passable, so the body has to manage the same.
- It slides along a wall it meets at any angle, so a path that brushes a corner does not stop it.
- It turns to face its direction before walking. Its speed is scaled by how closely it faces the way it wants to go, so it never slides sideways.
- It opens any closed door in its way, whatever the door's color, swinging it away from itself. It checks 0.8 m ahead at waist height while walking.
- While roaming, it closes the door behind itself once it is through and at least 1.3 m past it, clear of the swinging panel. If it stops closer than that, the door closes when it walks on.
- While investigating (chasing), it leaves doors open.
- It never closes a door while the player is within 1.5 m of it.
- It walks through the panel of any door that is fully open, whoever opened it. A panel left sticking out from the wall would otherwise block routes that the walkable area, which is baked without doors, says are clear. A door that is closed or still swinging is solid to it.
- If it barely moves for `stuck_time` while trying to walk, it gives up on that destination and picks another.

## Setting up a level

1. Add all solid level geometry (floors, walls, furniture) to the group `navigation_mesh_source_group`: select the nodes, open the **Node** dock, choose **Groups**, and add that name. Leave out doors and anything that moves.
2. Add a `NavigationRegion3D` and give it a new `NavigationMesh`. Under **Geometry**, set **Parsed Geometry Type** to Static Colliders and **Source Geometry Mode** to Group With Children. Under **Agents**, set **Height** to 2.0 and **Radius** to 0.25.
3. Select the `NavigationRegion3D` and click **Bake NavigationMesh** in the toolbar above the 3D view. Re-bake whenever walls or furniture move.
4. Add `Marker3D` nodes where the entity should wander.
5. Drag `scenes/entity.tscn` into the level and add those markers to **Patrol Points**.
6. Add a `Marker3D` where the player should respawn (the hub), facing the way the player should face.
7. Drag `src/level/scenes/catch_handler.tscn` into the level and set its **Spawn Point** to that marker. Set **Main Menu Scene** to `src/ui/scenes/main_menu.tscn`, or leave it empty in a test level.

The player scene must be in the level. The entity and the catch handler find the player through the `player` group, and the handler finds every entity through the `entity` group, so no other wiring is needed.

An agent radius of 0.25 is what keeps 1 m doorways walkable. A larger radius closes them off. The entity counts a path corner as reached from 0.35 m away (`path_desired_distance`); a larger value lets it turn while still inside a doorway and catch on the frame.

## Physics layers

| | Layer | Detects (mask) |
|---|---|---|
| Body | 4, `enemy` | 1, `world` |
| Sight ray | | 1 `world` and 2 `player` |

## Code interface

| Member | Kind | Use |
|---|---|---|
| `state` | variable | The current state. |
| `last_known_position` | variable | The last place it noticed the player or was told to check. |
| `investigate(spot)` | function | Sends it to check `spot`, for example after a noise. |
| `watch_player(rise)` | function | Makes it stand and stare at the player with its senses off; `rise` lifts it to a window. |
| `leave_to(spot)` | function | Sends it walking to `spot` with its senses off; it roams once it arrives. |
| `is_player_in_sight()` | function | Whether it can see the player right now. |
| `hear(spot, noise_range)` | function | Sends it to check a noise at `spot` if it is within `noise_range` and free to react. Normally called through `EntityHearing.make_noise()`. |
| `eye_position()` | function | Where its eyes are. The catch handler turns the player's view toward this. |
| `reset_after_catch()` | function | Moves it to a random patrol point at least `restart_clearance` from the player and outside safe rooms, pausing, unable to catch for `catch_cooldown`. |
| `state_changed(state)` | signal | Fires on every state change. Intended for animations. |
| `player_spotted` | signal | Fires at the moment it first notices the player. Intended for a sound sting. |
| `player_caught` | signal | Fires when it catches the player. The catch handler listens for it. |
| `uncovered` | signal | Fires when white light has been held on it for `uncover_time`. The ending director listens for it. |

The lit spot comes from `Flashlight.find_lit_spot()`, which returns where the center of the beam lands. Only the center is checked, so a spot where just the edge of the beam is in view does not count.

## Test level

`src/level/scenes/test_entity.tscn` is a brightly lit level for trying the entity: a hallway with four rooms, nine desks to hide under, crates that block its view, and a red and a blue door. The player starts at the west end of the hallway with every color unlocked, which is also where they respawn after a catch. Open the scene and press F6 to run it.

The desks there come from `src/environment/scenes/desk.tscn`. A desk has a back panel, so a player crouched under it is hidden from behind but visible from the open front if they move or have the light on.

The original test room (`test_room.tscn`) has no entity. Its navigation mesh and patrol markers are still there, unused.

## Open questions

None right now.
