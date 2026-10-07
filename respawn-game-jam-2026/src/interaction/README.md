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

Example, the greenhouse: the pot is a socket with one slot, taking the four seed packets, with the flower packet as its solution. Its `solved` goes to the sensor's `enable()`. The sensor sits on the pot, yellow, 3 seconds. Its `charged` goes to the flower's `show()`, both crayons' `appear()`, and the safe room's `open_to_entity()`.

## A crayon that is a reward

Drag in `pickup/scenes/crayon.tscn`, set its **Hue**, and tick **Starts Hidden**. It is invisible and cannot be picked up until something calls its `appear()`.

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

## A level where the flashlight is found

1. Select the `Player` in the level and untick **Starts With Flashlight**. The player begins with an empty hand.
2. Drag in `pickup/scenes/flashlight_pickup.tscn` and place it where the flashlight should lie. It is switched on, so its beam helps the player spot it.

Aiming at it shows "Pick up". Using it puts the flashlight in the player's hand.

## The flashlight with no color

A flashlight whose **Unlocked Hues** list is empty shines a dim grey beam. It lights the way and reveals nothing. The first crayon gives it its first color.
