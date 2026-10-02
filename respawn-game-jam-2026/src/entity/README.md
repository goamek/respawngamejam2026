# Entity

The creature that hunts the player. It roams the level, notices the player when they give themselves away, and goes to check the last place it noticed them.

- Scene: `scenes/entity.tscn`
- Script: `scripts/entity.gd` (`class_name Entity`)

The current body is a placeholder: a black capsule with two white eyes, 1.8 m tall. A real model and animations will replace it.

## Status

| Part | Status |
|---|---|
| Walking around walls (navigation) | Built |
| Roaming between patrol points | Built |
| Seeing the player | Built |
| Investigating the last place it noticed the player | Built |
| Noticing the flashlight's lit spot when the player is out of view | Built |
| Catching the player | Not built. It currently walks through the player. |

## States

The entity is always in exactly one state.

| State | What it does | Moves to |
|---|---|---|
| `PAUSING` | Stands still for `pause_time`. Also the starting state. | `ROAMING` when the pause ends |
| `ROAMING` | Walks to a randomly chosen patrol point at `roam_speed`. | `PAUSING` on arrival or when blocked |
| `INVESTIGATING` | Hurries to `last_known_position` at `investigate_speed`. | `SEARCHING` on arrival or when blocked |
| `SEARCHING` | Turns on the spot for `search_time`, looking around. | `PAUSING` when the time runs out |

From any state, noticing the player switches it to `INVESTIGATING`.

```
            pause ends
 PAUSING ---------------> ROAMING
    ^   <---------------     |
    |    arrived / blocked   |
    |                        |  notices player (from any state)
    |                        v
 SEARCHING <------------ INVESTIGATING
   (time up -> PAUSING)    arrived / blocked
```

## Noticing the player

Checked every physics frame. The entity notices the player when all of these are true:

1. **The player gives themselves away:** they are moving faster than 0.5 m/s, or their flashlight is on.
2. **In range:** within `sight_range` of the entity's eyes.
3. **In view:** within `sight_angle` of straight ahead.
4. **Nothing in between:** a ray from the eyes reaches the player's head or body before hitting anything on the world layer. Walls, closed doors and the carry box block it. Pickups such as crayons do not.

It also notices the player through their light, even when the player themselves is out of view:

1. **The flashlight is on**, and the center of its beam lands on a surface.
2. **That lit spot is in range and in view**, by the same range and angle as above.
3. **Nothing blocks its view of the spot.**

The entity is smart enough to tell where the light comes from, so it heads for the player, not for the lit spot. Shining the beam past it, or onto a wall in front of it, gives the player away.

A player standing still with the flashlight off is never noticed, even in plain view. This is the main way to hide.

While the player stays noticed, `last_known_position` follows them every frame, so the entity effectively chases. Once they stop being noticed, it goes to the last place it saw them, not to where they are now, then searches.

## Settings

All are shown in the Inspector on the entity.

| Group | Setting | Default | Meaning |
|---|---|---|---|
| Roaming | `patrol_points` | empty | Markers the entity wanders between, in random order. Never the same one twice in a row. |
| Roaming | `roam_speed` | 1.8 m/s | Walking speed while roaming. |
| Roaming | `pause_time` | 2 s | Time spent standing at each patrol point. |
| Senses | `sight_range` | 12 m | How far it can see. |
| Senses | `sight_angle` | 60 degrees | Half the width of its view (120 degrees in total). |
| Investigating | `investigate_speed` | 3.8 m/s | Speed while heading to the spot it is checking. |
| Investigating | `search_time` | 3 s | Time spent looking around after arriving. |
| Investigating | `search_turn_speed` | 90 degrees/s | Turning speed while looking around. |
| Movement | `turn_speed` | 240 degrees/s | How fast it turns to face where it is walking. |
| Movement | `stuck_time` | 1.5 s | How long it may be blocked before giving up on a destination. |

For comparison, the player walks at 3.0 m/s and sprints at 5.5 m/s, so sprinting outruns an investigating entity.

## Movement notes

- It turns to face its direction before walking. Its speed is scaled by how closely it faces the way it wants to go, so it never slides sideways.
- It opens any closed door in its way, whatever the door's color, swinging it away from itself. It checks 0.8 m ahead at waist height while walking.
- While roaming, it closes the door behind itself once it is through and at least 1.3 m past it, clear of the swinging panel. If it stops closer than that, the door closes when it walks on.
- While investigating (chasing), it leaves doors open.
- It never closes a door while the player is within 1.5 m of it.
- If it barely moves for `stuck_time` while trying to walk, it gives up on that destination and picks another.

## Setting up a level

1. Add all solid level geometry (floors, walls, furniture) to the group `navigation_mesh_source_group`: select the nodes, open the **Node** dock, choose **Groups**, and add that name. Leave out doors and anything that moves.
2. Add a `NavigationRegion3D` and give it a new `NavigationMesh`. Under **Geometry**, set **Parsed Geometry Type** to Static Colliders and **Source Geometry Mode** to Group With Children. Under **Agents**, set **Height** to 2.0 and **Radius** to 0.25.
3. Select the `NavigationRegion3D` and click **Bake NavigationMesh** in the toolbar above the 3D view. Re-bake whenever walls or furniture move.
4. Add `Marker3D` nodes where the entity should wander.
5. Drag `scenes/entity.tscn` into the level and add those markers to **Patrol Points**.

The player scene must be in the level. The entity finds it through the `player` group, so no wiring is needed.

An agent radius of 0.25 is what keeps 1 m doorways walkable. A larger radius closes them off.

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
| `sees_player()` | function | Whether it can see the player right now. |
| `state_changed(state)` | signal | Fires on every state change. Intended for animations. |
| `player_spotted` | signal | Fires at the moment it first notices the player. Intended for a sound sting. |

The lit spot comes from `Flashlight.find_lit_spot()`, which returns where the center of the beam lands. Only the center is checked, so a spot where just the edge of the beam is in view does not count.

## Test level

`src/level/scenes/test_entity.tscn` is a brightly lit level for trying the entity: a hallway with four rooms, nine desks to hide under, crates that block its view, and a red and a blue door. The player starts at the west end of the hallway with every color unlocked. Open the scene and press F6 to run it.

The desks there come from `src/environment/scenes/desk.tscn`. A desk has a back panel, so a player crouched under it is hidden from behind but visible from the open front if they move or have the light on.

## Open questions

- What happens when it reaches the player (catching, lives, respawn)?
