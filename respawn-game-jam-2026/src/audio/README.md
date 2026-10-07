# Audio

How sound gets into the game. The first half is for anyone adding or swapping audio; the second half is for anyone writing scripts.

## How it fits together

| Piece | Where | What it is |
|---|---|---|
| Audio files | `assets/music/`, `assets/sounds/` | The recordings themselves. |
| Sound list | `src/audio/resources/game_sound_library.tres` | Gives every sound a name and says which file plays for that name. |
| Audio controller | `src/autoload/audio_controller.tscn` | Plays sounds by name. Always loaded, so music carries on between screens. |
| Sound test screen | `src/audio/scenes/sound_test.tscn` | A screen for listening to everything in the list. Not part of the game. |

Scripts never point at an audio file. They ask the controller for a name, such as `door_creak`, and the sound list decides which file that is. To change what the game sounds like, edit the sound list, not the code.

The list has two parts:

- **Cues** are sound effects: short, played once.
- **Tracks** are music and ambience: long, and they loop.

## Working on the sound list

Open `src/audio/resources/game_sound_library.tres` by double-clicking it in the FileSystem panel. It opens in the Inspector.

### Listen to what is there

Open `src/audio/scenes/sound_test.tscn` and press **F6** (Run Current Scene). Every cue has a button. Every track can be started as music or as ambience, so you can hear two layered. The sliders set the volume of each group.

The screen builds itself from the sound list, so anything you add shows up there the next time you run it.

### Swap the file behind a name

1. In the Inspector, open **Cues** and find the name.
2. Click its entry to open it, then drag the new audio file from the FileSystem panel onto **Stream**.
3. Save with Ctrl+S.

Tracks work the same way, under **Tracks**, except the file goes straight onto the entry.

### Add a new sound

1. Put the file in the matching folder under `assets/sounds/` or `assets/music/`. Name it in `snake_case`: lowercase, underscores, no spaces, for example `door_slam.wav`.
2. In the Inspector, open **Cues** and choose **Add Key/Value Pair**.
3. Type the name as the key. Use `snake_case` here too; it is the name scripts will ask for.
4. For the value, choose **New SoundCue**, open it, and drag your file onto **Stream**.
5. Save.

### Settings on a cue

| Setting | What it does |
|---|---|
| Stream | The audio file. |
| Volume Db | Makes this one sound louder or quieter. 0 leaves it as recorded; -6 is about half as loud. |
| Pitch Variation | Random pitch change on each play, so a repeated sound such as a footstep does not sound identical every time. 0.1 means up to 10 percent higher or lower. |
| Max Distance | How far away the sound can be heard when it is played in the world, in meters. |

### Several versions of one sound

When a sound has variations, such as three scrapes, give the cue an **AudioStreamRandomizer** as its Stream and add each file to it. The cue then plays one at random. `entity_drag` and `entity_scrape` are set up this way.

### Volume groups

Every sound belongs to one of three groups, called buses: **Music**, **Ambience**, and **SFX**. They are set up in `default_bus_layout.tres` and all feed into **Master**. Cues play on SFX. A track plays on Music or Ambience depending on how the game starts it.

## For scripts

`AudioController` is an autoload, so any script can call it directly.

| Function | What it does |
|---|---|
| `play_sound(cue_name)` | Plays a cue with no position: the same loudness wherever the player is. For menus and things in the player's hands. |
| `play_sound_at(cue_name, position)` | Plays a cue at a point in the world. It gets quieter with distance and comes from the correct side. |
| `play_sound_on(cue_name, node)` | Plays a cue from a node and follows it as it moves. |
| `play_loop(cue_name)` | Starts a cue repeating with no position, until `stop_loop` is called. For a long recording such as a run of footsteps. |
| `stop_loop(cue_name)` | Fades a repeating cue out. |
| `play_music(track_name, fade_time)` | Fades to a track on the Music bus and loops it. |
| `stop_music(fade_time)` | Fades the music out. |
| `play_ambience(track_name, fade_time)` | Fades to a track on the Ambience bus and loops it. |
| `stop_ambience(fade_time)` | Fades the ambience out. |
| `stop_all_sounds()` | Cuts off every cue at once. Music and ambience keep playing. |
| `set_volume(bus, amount)` | Sets a bus volume, from 0 for silent to 1 for full. |
| `get_volume(bus)` | Returns a bus volume, from 0 to 1. |

Fade times are in seconds and default to 1. Buses are named with `AudioController.Bus`: `MASTER`, `MUSIC`, `AMBIENCE`, `SFX`.

```gdscript
AudioController.play_sound(&"pickup")
AudioController.play_sound_at(&"door_creak", global_position)
AudioController.play_sound_on(&"entity_step", self)
AudioController.play_music(&"background_music_loop", 2.0)
AudioController.set_volume(AudioController.Bus.MUSIC, 0.5)
```

Things to know:

- **A name that is not in the list plays nothing** and prints one warning in the Output panel. It never stops the game.
- **An empty name plays nothing and prints no warning.** That is how a sound slot in the Inspector is switched off.
- **Asking for the track that is already playing does nothing**, so a level can call `play_music` every time it loads without restarting the song.
- **Tracks loop** whatever their file format; the controller restarts a track when it ends.
- **Music and ambience are separate**, so one of each can play together.
- **At most 8 cues with no position and 12 cues in the world play at once.** One more than that replaces the cue that started longest ago.
- **Everything keeps playing while the game is paused.**

## What is hooked up

Each of these has a slot in the Inspector, under **Sound**, holding the name of the cue it plays. Change the name to use a different cue, or clear it for silence.

| Moment | Cue | Where the slot is |
|---|---|---|
| A door starts to open | `door_creak` | `Open Sound` on the door (`src/environment/scenes/school_door.tscn`) |
| A door starts to swing shut | `door_close` | `Close Sound` on the door |
| The entity takes a step | `entity_step` | `Step Sound` on the entity; `Stride Length` sets how far apart the steps are |
| The player takes a step | `player_step` | `Step Sound` on the player; `Stride Length` sets how far apart the steps are |
| The player crouches down | `player_crouch` | `Crouch Sound` on the player |
| The flashlight is switched on or off | `flashlight_switch` | `Switch Sound` on the flashlight (`src/flashlight/scenes/flashlight.tscn`) |
| The entity is a threat | `heartbeat_pair` | `Beat Sound` on the level's `Heartbeat` node |

Door and entity sounds are played in the world, so they come from where the door or the entity is. The player's own sounds have no position.

Music is started by a `LevelMusic` node (`src/level/scripts/level_music.gd`). Add one to a level and type a track name into `Music Track`, `Ambience Track`, or both. The tracks fade in when the level loads and fade out when it is left. The school level plays `background_music_loop_quiet`.

The heartbeat is played by a `Heartbeat` node (`src/level/scripts/heartbeat.gd`), one per level, given the level's entity and its first sighting. It beats every `Tense Interval` (0.9 s) during the first sighting's stare and while the entity searches, and every `Chase Interval` (0.55 s) while the entity is running to the player or a noise, or catching. It is silent while the entity roams, pauses, walks away after the player hides, or is asleep.

Not hooked up yet: the door slam, unlocking, pickups, the entity's voice and catch, the puzzles, and the endings. Most of those moments already announce themselves with a signal, such as `slammed` on a door or `player_caught` on the entity, so adding a sound is one call in the function that handles the signal.
