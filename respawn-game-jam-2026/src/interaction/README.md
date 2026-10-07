# Puzzle Pieces

The parts a puzzle room is assembled from, and how to wire them together in the editor. None of this needs code: every step is adding a node, setting values in the Inspector, or connecting a signal in the **Node** dock.

| Piece | Script | What it does |
|---|---|---|
| Interactable | `interaction/scripts/interactable.gd` | Makes an object usable; can require a color to be shining on it. |
| Carryable | `interaction/scripts/carryable.gd` | Makes a rigid body something the player picks up and carries. |
| Item socket | `interaction/scripts/item_socket.gd` | A spot that takes carried items and checks whether they are the right ones. |
| Light sensor | `flashlight/scripts/light_sensor.gd` | Reacts when the right color has been held on a spot for long enough. |
| Revealable | `flashlight/scripts/revealable.gd` | Makes an object show its color only under that color of light. |
| Crayon | `pickup/scenes/crayon.tscn` | Gives the flashlight a color. Can start hidden as a puzzle's reward. |
| Door | `environment/scenes/school_door.tscn` | Opens only under its color. |
| Safe room | `level/scripts/safe_room.gd` | Keeps the entity out of a room until its puzzle is solved. |
| Note | `environment/scenes/note.tscn` | Paper with writing the player reads by flashlight. |
| Wall calendar | `environment/scenes/wall_calendar.tscn` | A month with one day circled. |
| Choice | `interaction/scripts/choice.gd` | One right answer among several things to take. |
| Book | `environment/scenes/book.tscn` | A choice with a title, for a shelf. |
| Player trigger | `level/scripts/player_trigger.gd` | An invisible region that reports the player walking in. |
| Door lock trigger | `level/scripts/door_lock_trigger.gd` | A region that slams and locks a door behind the player. |
| First sighting | `level/scripts/first_sighting.gd` | The scripted first meeting with the entity, and what keeps it asleep until then. |
| Exit door | `environment/scenes/exit_door.tscn` | The white door that appears once the beam turns white; using it ends the game. |
| Ending director | `level/scenes/ending_director.tscn` | Fades out of the level and shows an ending screen. |

To add one of the script-only pieces, add a node of the type given below, then drag the script onto it (or search for its class name in the **Create New Node** window).

## Physics layers

Anything the player aims at must be on layers **1 and 3** (world and interactable). Crayons use layer 3 only, so the player walks through them.

## An item the player carries

1. Add a `RigidBody3D` on layers 1 and 3, with a mesh and a `CollisionShape3D`.
2. Add a child `Node` with the `Carryable` script. Set **Prompt** to "Pick up".
3. Set **Item Id** to a short name for what it is, such as `apple`. Items of the same kind share one id.

To make it show only under a color, give its mesh the reveal material and add a `Revealable` child, as for any colored object.

## A spot that takes items (item socket)

Used for the plant pot, the fruit basket and the paint palettes.

1. Make the object the items go on or in: a `StaticBody3D` on layers 1 and 3 with a collision shape.
2. Add one `Marker3D` child for each item it holds, placed where that item should sit. Keep them clear of the object's own collision shape.
3. Add a child `Node` with the `ItemSocket` script.
4. In the Inspector:
   - **Slots:** add the markers, in the order they should fill.
   - **Accepted Ids:** every item id the player is allowed to set down here, right or wrong. Leave empty to take anything.
   - **Solution Ids:** the ids that count as correct, one per slot, in any order. Leave empty if anything accepted is correct.

How it plays: while carrying an accepted item and aiming at the object, the hint reads "Place". Each item jumps to the next free slot and cannot be taken back. When the last slot fills:

- **Right items:** the `solved` signal fires and they stay for good.
- **Wrong items:** the `rejected` signal fires, and after a moment they all return to where the player first picked them up.

Why accept wrong items at all: if the basket only took apples, the player could find the apples by trying every fruit and seeing which the basket takes. Letting them commit a wrong answer keeps it a puzzle.

Example, the cafeteria basket: three slots, **Accepted Ids** `apple, banana, pear, blueberries, plum`, **Solution Ids** `apple, apple, apple`.

## A spot the light must be held on (light sensor)

Used for the plant growing, and for uncovering the entity.

1. Add a `Node3D` with the `LightSensor` script, positioned exactly where the light must land.
2. In the Inspector:
   - **Hue:** the color needed. White light counts for every color.
   - **Hold Time:** how many seconds the light must stay on it. Time off it drains at the same rate.
   - **Is Enabled:** turn this off if an earlier step has to happen first.

Signals: `charged` fires once when it is full. `progress_changed` fires as it fills and drains, with a number from 0 to 1, for anything that should grow or glow along with it.

## Writing the player reads (note)

Drag in `environment/scenes/note.tscn`. It is a sheet of pale paper with dark writing.

- **Text:** what it says. Press Enter for a new line.
- **Paper Size:** width and height of the sheet, in meters.
- **Text Height:** height of one line, in meters. About 0.04 reads comfortably from a meter away.

The paper is dim until the flashlight is on it, and the ink never glows, so the player needs a light to read it. The sheet faces along its blue arrow (Z). Turn and tilt it to lean it on a desk or hang it on a wall; it updates in the editor as you type.

Keep its label on **Alpha Cut: Discard**, which is how it ships. The crayon screen effect only sees solid surfaces, so ordinary see-through text does not show up in the game at all. The same goes for any `Label3D` you add yourself.

## A wall calendar

Drag in `environment/scenes/wall_calendar.tscn` and set **Month Name**, **Day Count**, **First Weekday** (0 is Sunday), **Circled Day**, and **Circle Note** (the words under the grid). It draws itself, in the editor too.

## One right answer among several (choice, and books)

`interaction/scripts/choice.gd` is an interactable with a right or wrong answer. Tick **Is Correct** on the right ones.

- A right pick fires `chosen_right`.
- A wrong pick fires `chosen_wrong`, leaves the object where it is, and swaps its hint for **Wrong Prompt** ("Not this one") for **Wrong Prompt Time** seconds.

`environment/scenes/book.tscn` is a book built on it. Set its **Title**, which shows in the hint as `Take "Title"`, and tick **Is Correct** on the one the player is after. The right book fires `taken` and comes off the shelf; connect `taken` to whatever it reveals.

Example, the library: four books on `environment/scenes/bookshelf.tscn`. The right one's `taken` goes to the hidden coloring book's `show()` and to the hidden yellow crayon's `appear()`.

## Chaining steps with signals

Select the node that sends the signal, open the **Node** dock, double-click the signal, pick the node that should react, and choose the method.

| When this happens | Connect | To this |
|---|---|---|
| The right items are placed | socket `solved` | crayon `appear()` |
| The right items are placed | socket `solved` | sensor `enable()` |
| The light has been held long enough | sensor `charged` | crayon `appear()` |
| The light has been held long enough | sensor `charged` | any `Node3D`'s `show()` |
| The puzzle is finished | socket `solved` or sensor `charged` | safe room `open_to_entity()` |

The greenhouse uses this chain, packed into one ready-made object; see **The greenhouse puzzle** below.

## Writing that shows under one color (hidden text)

Drag in `environment/scenes/hidden_text.tscn`. It is a small dark tag with writing on it that only shows under a beam of its **Hue**, or a white beam. Set **Text**, **Hue**, **Text Height** and **Tag Size** (both in meters).

The tag is there on purpose. Hidden things are drawn near black, so hidden writing straight on pale paper would be readable as black letters. On a tag of the same black it cannot be made out until the right light is on it.

Used for the names on the seed sacks and the missing word on the greenhouse note. The same piece will do for locker numbers and jar labels.

## The greenhouse puzzle

Three ready-made pieces, all in `environment/scenes/`:

| Piece | What it is | Settings |
|---|---|---|
| `seed_sack.tscn` | A sack the player carries, with its name on a hidden-text tag (yellow). The hint is "Pick up" for every sack, so only the light tells them apart. | **Plant Name**, in lowercase: `flower`, `carrot`, `tree` or `weed`. It is both the name on the tag and the id the pot checks. |
| `plant_pot.tscn` | The pot, with a socket, a light sensor, and the flower inside it. | **Alarm Spot**, **Alarm Range**, and three sound names. |
| `bench.tscn` | A plain grey placeholder bench, 2.2 m long and 0.9 m high. | None. |

How the pot plays:

1. It takes any of the four sacks. A wrong one sits in it for a moment and is sent back to where it was picked up, with a thud and a noise the entity can hear.
2. The `flower` sack is planted: it disappears into the pot, and from then on yellow light counts.
3. While yellow light is on the pot the flower grows, reaching full size after 3 seconds. Move the beam away and it shrinks back at the same rate.
4. At full size the pot emits `bloomed`. Connect that to each reward crayon's `appear()`.

**Alarm Spot** is where the noise of a wrong sack seems to come from. The entity ignores noise from inside a safe room it is kept out of, and the pot is inside one, so give it a `Marker3D` placed just outside the room's door. The entity runs there, looks around, and leaves.

In the school: the bench, the four sacks and the note are in the potting room; the pot is on the greenhouse floor; the alarm marker is in the hall outside the bio lab's yellow door. The green and indigo crayons sit in the flower, hidden until `bloomed`. Taking both opens the wing to the entity, through the safe room.

After moving the bench or the pot, re-bake the navigation mesh, since the entity walks round them once the wing is open.

## A crayon that is a reward

Drag in `pickup/scenes/crayon.tscn`, set its **Hue**, and tick **Is Hidden At Start**. It is invisible and cannot be picked up until something calls its `appear()`.

## A room the entity stays out of (safe room)

1. Add an `Area3D` with the `SafeRoom` script.
2. Give it one or more `CollisionShape3D` children with **box** shapes that together cover the room, wall to wall and floor to ceiling. Stop the boxes at the doorway, on the room's side.
3. In the Inspector, add the room's reward crayon or crayons to **Crayons**. The room opens to the entity the moment the player has taken all of them. (With no crayons listed, connect the puzzle's last signal to the room's `open_to_entity()` instead.)

While the room is safe, the entity will not step into it, will not pick patrol points inside it, and cannot catch a player who is inside it. It will still come to the doorway and stare in. Only box shapes are read.

## Doors

Select a door in the level and set its **Hue** in the Inspector.

- **A color:** the door is black until that color shines on it, and only opens while it is lit. White light opens every colored door.
- **None:** a plain door. It opens for anyone, with or without a flashlight, and wears the wood material so it reads as an ordinary door.
- **White:** only the white beam opens it.

The entity opens every door, whatever its hue, unless the door is locked.

**Is Locked** shuts a door for good. Aiming at it shows "Locked", no beam opens it (white included), it stays flat black, and the entity will not open it. Use it on every door that is not on the route. After locking or unlocking doors, re-bake the navigation mesh (`src/level/scripts/navigation_baker.gd`, File > Run), which treats locked doors as walls so the entity does not try to path through them.

**Can Lock During Play** is for a door that starts usable, locks later (see the next section), and is still locked while the entity is roaming. The navigation bake treats such a door as a wall, so the entity never plans a route through it. Re-bake after ticking or unticking it. The library's main door does not need it: it is only locked while the entity is asleep.

## A door that locks behind the player

1. Add an `Area3D` with the `DoorLockTrigger` script, and give it a `CollisionShape3D` child covering the strip of floor the player must cross. Keep it at least 1.8 m past the door, so the panel does not swing shut on them.
2. Set **Door Path** to the door. Doors sit inside the school scene, which the node picker cannot open, so type the path by hand; copy the pattern from `Library/EntryLock` in the school level.
3. Tick **Is Flashlight Required** if it should only happen once the player is holding the flashlight.
4. If the door will still be locked while the entity roams, tick **Can Lock During Play** on the door itself and re-bake the navigation mesh.

When the player walks in, the door slams shut, turns black and shows "Locked". The door's `slammed` signal fires at that moment; connect a sound to it.

To let the player back through later, connect any signal to the trigger's `unlock_door()`. The door goes back to how it was set up (plain wood, or its color) and fires `unlocked`. In the school level, the first sighting's `ended` signal does this for the library.

Plain `PlayerTrigger` regions work the same way without the door: they emit `triggered` when the player walks in, once by default. Connect that to anything.

## The first sighting of the entity

One `FirstSighting` node per level. It hides the entity and switches it off when the level starts, so nothing roams until the meeting happens.

| Setting | What to give it |
|---|---|
| **Entity** | The level's entity. |
| **Arrival Trigger** | A `PlayerTrigger` the player crosses before they can see the watch spot. The entity appears there at that moment, out of view. |
| **Stare Door Path** | The door that shows the watch spot when it opens, typed by hand as above. The countdown and the hint start when it has finished swinging open (the door's `fully_opened` signal). |
| **Stare Trigger** | Only for a level with no such door: a `PlayerTrigger` that starts the stare instead. Otherwise leave it empty. |
| **Watch Spot** | A `Marker3D` where the entity stands. |
| **Leave Spot** | Where it walks to after the player hides; a patrol point works. |
| **Hiding Spots** | The hiding spots that count for this meeting, normally the one under each nearby desk. See the next section for how to make one. |
| **Watch Door Path** | The door it watches through, typed by hand as above. Optional. |

What the player does decides how it ends:

- **Crouches inside a hiding spot** for **Hide Time** (1.5 s): the entity walks to the leave spot, noticing nothing on the way, and then roams as normal.
- **Stays in the open** for **Patience** (8 s; 0 waits forever), **comes within Alarm Distance** (2 m), or **opens the door**: the entity comes for them, opening the door itself.

**Watch Rise** lifts the entity so its face lines up with a door window. **Head Tilt** tips its head sideways while it stares; positive leans the top of its head to the player's left, and 70 reads as about 10:30 on a clock because the idle pose already leans the other way. **Hint** is the line shown on screen during the stare. Signals `started`, `player_hid` and `entity_attacked` are there for sounds and music, and `ended` fires when the meeting is over either way.

To test puzzles with no entity at all, untick **Is Enabled**: it then stays asleep for the whole game.

## A place to hide (hiding spot)

A hiding spot is an invisible region, usually under a desk. A player crouched inside it cannot be spotted by the entity, unless the entity was already chasing them when they got in.

1. Add an `Area3D` as a child of the piece of furniture and attach `src/level/scripts/hiding_spot.gd`.
2. Give it a `CollisionShape3D` with a box that covers the space underneath. Keep the box inside the furniture, so that standing next to it does not count.

That is all: it sets its own collision layers and the entity finds it by itself. The player has to be crouching, so make sure there is room to crouch in. The full rules are in `src/entity/README.md`.

The two desks used by the first sighting, in the office and the archive, are hiding spots.

## Ending the game

There are three endings, and `GameSession.ending` remembers which one was reached so the ending screen (`ui/scenes/ending_screen.tscn`) can show the right card.

| Ending | What triggers it | Wired by |
|---|---|---|
| Escape | Using the exit door under the white beam | The exit door's `used` signal, connected to the ending director's `play_escape()` |
| Uncovered | Holding the white beam on the entity for 3 seconds while it can see the player | The entity's `uncovered` signal, connected to the ending director's `play_uncovered()` |
| Caught | Losing the last life | The catch handler's **Run End Scene**, set to the ending screen |

**Setting up a level:**

1. Drag in `level/scenes/ending_director.tscn`. One per level.
2. Drag in `environment/scenes/exit_door.tscn` and place it. It is invisible and not solid until the flashlight turns white (all seven crayons), then it appears. It is black until the white beam is on it, and shows "Leave" while lit. Its `appeared` signal is there for a sound.
3. Connect the two signals in the table above in the **Node** dock.
4. On the catch handler, set **Run End Scene** to `ui/scenes/ending_screen.tscn`. Leave it empty in a test level, which then quits when the last life is lost.
5. Re-bake the navigation mesh so the entity walks round the door.

To end the game from something else, connect it to the ending director's `play_escape()`, or call `play(ending, delay)`.

**Ending pictures:** open `ui/scenes/ending_screen.tscn`, select the root, and drop an image into **Escape Picture**, **Uncovered Picture** or **Caught Picture**. With none set, the card shows text only. The titles and story text are at the top of `ui/scripts/ending_screen.gd`.

Only one flashlight should exist in a level at a time. Each one sends its beam to the reveal shader, so a second one (for example a pickup left lying about while the player already holds one) stops colored objects lighting up.

## On-screen hints

Call `show_hint("text")` on the player to put a line of guidance in the lower part of the screen, and `clear_hint()` to remove it. It is separate from the Open / Take hint under the crosshair.

## A level where the flashlight is found

1. Select the `Player` in the level and untick **Has Flashlight At Start**. The player begins with an empty hand.
2. Drag in `pickup/scenes/flashlight_pickup.tscn` and place it where the flashlight should lie. It is switched off, so it needs to lie somewhere the player can see without it.

Aiming at it shows "Pick up". Using it puts the flashlight in the player's hand, still off, and shows a hint on how to switch it. The hint stays until the player first switches the light, and its wording is the pickup's **Hint** setting; clear that for no hint.

## The flashlight's grey beam

Every flashlight has a dim grey beam that lights the way and reveals nothing. It is always there, first in the row of colors, and is never replaced: each crayon adds a color after it, and the player can cycle back to grey at any time.

A flashlight whose **Unlocked Hues** list is empty has grey and nothing else, which is how the one in the lobby starts. A flashlight given colors there still gets grey, and starts on its first color.

Grey does not count as a crayon: it does not speed the entity up, and it is not one of the seven that unlock white.
