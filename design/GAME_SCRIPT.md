# Game Script

The full run of the game from the front door to the ending: where the player goes, what each crayon lets them do, how every puzzle works, and what the entity is doing meanwhile. The mechanics it is built from (flashlight colors, interaction, doors, the entity) are described in the README files under `respawn-game-jam-2026/`.

Draft of 2026-10-05. Items marked **Open** are not decided.

## The one rule

**What is drawn in a color only exists in that color's light.**

The school is black and grey. The crayon drawings, labels, and scribbles the player made here as a child are all over it, each in one color, and each invisible until the flashlight shines that color on it. Some drawings are only clues. Some are real: a drawn door opens, a drawn handle turns.

Picking up a crayon gives the flashlight a new color. Each room's door only opens under the color earned in the room before it, so the crayons set the order of the game. The creative use of each color is inside the rooms, in the puzzles, not at the doors.

## Story

**The player is the child, grown up.** There is one person in this story, at two ages.

- As a child, the player went to this school and filled a coloring book with drawings of it. The book and its seven crayons were left behind.
- The entity is one of those drawings. The player drew it in every color, got scared of it, and scribbled over it in black crayon until only the eyes were left as bare paper. That is why it is solid black with white eyes.
- Years later the player comes back. The school is grey because they have forgotten it. Each crayon they find brings back one color of how they saw it then.
- With all seven the flashlight turns white, the school shows as they remembered it, and the way out appears.

How the player learns this, with no dialogue:

- **Library:** the coloring book in the nook has a drawing on its cover of a child holding a flashlight, labeled "ME".
- **Every room:** the notes and drawings are in the same handwriting, and they are always exactly where the player needs them. They are following their own trail.
- **Art studio:** the drawings of the entity are signed "ME" as well. This is where it becomes clear who made it.
- **Endings:** each one says it outright (see below).

## Route at a glance

The flashlight starts with no color. Order of rooms follows the building: start in the south-west, loop north, east, back along the south, and finish in the middle.

| # | Room | How you get in | Crayon earned | The idea |
|---|---|---|---|---|
| 0 | Entry lobby | Start here | none (flashlight) | Tutorial: move, look, pick up |
| 1 | Library | Open | Yellow | Solve a puzzle with no color, to learn the basics |
| 2 | Bio lab and greenhouse | Yellow door | Indigo | Yellow is sunlight |
| 3 | Music room | Indigo door | Green | Two colors, one message |
| 4 | Gym and locker room | Green door | Blue | One object reads differently under each color |
| 5 | Cafeteria | Blue door | Red | Find it by what stays dark |
| 6 | Art studio | Red door | Orange | Light tells identical things apart |
| 7 | Chemistry lab | Orange door | Violet | Flame test |
| 8 | Main entry (false exit) | Violet door | none | The first exit fails |
| 9 | Central courtyard | White door | Ending | Everything in color at once |

Each crayon is used three times: to open the next room's door, inside that room's puzzle, and again in later puzzles alongside newer colors. A door is black like everything else until its color shines on it, and it only opens while lit.

## Beat by beat

### 0. Entry lobby (tutorial, no entity)

- The front door shuts behind the player. The lobby is nearly black.
- A flashlight lies on the reception counter. Picking it up teaches interact. It gives a weak grey beam and reveals nothing.
- The ceiling light panels flicker one after another toward the library. This is the hint system for the whole game: when the player is stuck, the lights lead.

### 1. Library (earn Yellow)

**Access:** open. **Colors needed:** none.

1. A check-out slip on the librarian's desk lists books and dates. One book was never returned.
2. A wall calendar has one date circled. That date matches one line on the slip, which gives the book's title.
3. The player finds that title on the shelves and pulls it. The shelf swings open onto a small nook.
4. In the nook: the yellow crayon and the player's old coloring book ("ME" on the cover). Picking up the crayon turns the beam yellow.
5. Yellow crayon arrows now show on the floor, leading out through the archive and office.

**Teaches:** reading a clue, interacting, and that a crayon changes what the player can see.

**Entity:** on leaving through the office door, the player sees it for the first time, crossing the corridor by the art studio. It does not chase. A desk stands beside the door: turn the light off, crouch under it, stay still. This is the hiding tutorial. The entity does not roam yet.

### 2. Bio lab and greenhouse (earn Indigo)

**Access:** yellow door. **Colors needed:** yellow.

1. Shelves of seed packets, all grey. Their labels only show under yellow. One is marked with their own childhood drawing of a flower.
2. Carry that packet to the empty pot on the potting bench.
3. Carry the watering can from the sink to the pot.
4. Hold the yellow beam on the pot. The plant grows and opens. The indigo crayon is inside the flower.

**Entity:** from here on it roams. It cannot enter a puzzle room until that room's puzzle is solved.

### 3. Music room (earn Green)

**Access:** indigo door. **Colors needed:** yellow, indigo.

1. A sheet of music on the stand shows empty staves.
2. Under yellow, some notes appear. Under indigo, the rest appear. Neither half is a tune alone.
3. A child's xylophone has seven bars. The player strikes the bars in the order of the full tune.
4. A music box on the piano opens. The green crayon is inside.

**Entity:** playing a wrong note makes noise. The entity comes to check the door (it still cannot enter).

### 4. Gym and locker room (earn Blue)

**Access:** green door. **Colors needed:** yellow, indigo, green.

1. A locker in the locker room has a three-digit lock, with three crayon dots above it: for example green, yellow, indigo. That is the order.
2. The gym scoreboard shows one large digit made of segments. Each segment is drawn in one color, so the digit reads differently under yellow, under indigo, and under green.
3. The player reads the three digits, takes them in the order of the dots, and enters them on the locker.
4. The blue crayon is in the locker.

**Entity:** the gym is the largest room, with long sight lines. It is the first place the entity can see the beam from far away. Once the locker opens, the gym stops being safe.

### 5. Cafeteria and kitchen (earn Red)

**Access:** blue door. **Colors needed:** yellow, indigo, green, blue.

1. A crate of fruit, all grey. A note in their childhood handwriting: "3 apples for teacher."
2. Under yellow the bananas show. Under green, the pears. Under blue, the blueberries. Under indigo, the plums.
3. Three pieces never light up under any color the player owns. Those are the apples, because the player has no red.
4. Carry the three dark fruit to the basket on the teacher's table. A wall hatch opens. The red crayon is inside.
5. Shining red on the basket shows the apples in color, confirming the answer.

**Entity:** stands at the hallway intersection outside when the player leaves, as in the team's outline.

### 6. Art studio (earn Orange)

**Access:** red door. **Colors needed:** red, yellow.

1. The studio walls are covered in the drawings of the entity the player made as a child, each signed "ME". Each color shows a different drawing in the same spot, and in each one the entity is closer.
2. A row of identical grey paint jars. Only light shows which is which.
3. An unfinished painting on the easel has two numbered patches and a note: "1 and 2 make the sun going down."
4. Carry the red jar and the yellow jar to the palette. They mix. The orange crayon sits in the paint.

### 7. Chemistry lab (earn Violet)

**Access:** orange door. **Colors needed:** red, blue, orange.

1. The periodic table poster is grey. Under red, one element lights up. Under blue, another.
2. The same two symbols are on bottles in the chem store.
3. Carry both bottles to the burner. The flame turns violet, and the violet crayon is left in the dish.
4. Easter egg: carrying water to the burner makes the Respawn mascot appear in the steam.

**Entity:** when the flame turns violet, it breaks into the lab. The player has to get past it and out through the lab's one door. This is the one scripted chase. The floor plan shows a shared prep room linking this lab to the physics lab as a second way out, but that room has no doors in the level; adding two would give the player the escape route in the team's outline.

### 8. The false exit

- Violet works like a blacklight: it shows the entity's handprints and footprints along the walls and floor, old and new.
- The prints lead to the main entry. The front door now opens under violet, onto a bricked-up wall with "NOT THIS WAY" written across it in violet.
- With all seven crayons, the beam turns white.

### 9. Central courtyard (ending)

- White shows every drawing in the school at once, in full color.
- In the courtyard, a door is drawn on the wall in white crayon. It is the way out.

## Endings

| Ending | How | What happens |
|---|---|---|
| Escape | Go through the white door | The player leaves with the coloring book. The school goes grey behind them, and the entity is still inside: they got out, but never faced it. |
| Uncovered (secret) | Hold the white beam on the entity for a few seconds while it comes at the player | The black scribble flakes away and the colors the player first drew show through. It was never a monster, only a drawing they were scared of. It stops, and walks them to the door. This is the true ending. |
| Caught | Lose every life | A new drawing appears on the art studio wall: the child labeled "ME", scribbled over in black. The player has done to themselves what they did to their drawing. |

## The entity through the run

- **Rooms 0 and 1:** absent, then one scripted sighting.
- **From room 2:** roams, investigates light and noise, opens doors.
- **Safe rooms:** it cannot enter a puzzle room until that puzzle is solved. After that the room is open to it.
- **Gets faster:** a small speed increase with each crayon collected.
- **Scripted moments:** only two (first sighting, chemistry break-in). The other moments in the team's outline, such as the entity waiting at a corner, come from roaming.

## Replay value (strictly optional)

**Nothing in this section is required for the game to be finished.** The game is complete with the route, the seven puzzles, all three endings and the game over screen. Everything below is extra, and is only started once every room is built, tested and playable.

In order of cost:

1. **Easy and hard mode.** Entity speed and sight range, 3 lives or 1, flickering light hints on or off.
2. **Shuffled answers on a fixed route.** Each run picks from a few presets: which book, which tune, which locker digits, which pair of elements, where the apples sit. The order of rooms never changes, so every run can be finished. The three endings are not part of this list; they are part of the base game. This is the most expensive item, since it multiplies the authoring for every puzzle, so it is last.

Not planned: shuffling the route or the crayon locations between rooms. It would need every door to work in any order.

## Unused rooms are locked

The school is about 120 by 91 m and the route only uses part of it. Every room the route does not use is shut off, so the playable area is smaller, the entity finds the player faster, and nobody has to build, light or test rooms nobody will visit.

**Rooms in use** (everything else is locked):

- The entry lobby and the vestibule
- The library, with its archive and office
- The bio lab, potting room and greenhouse
- The music room
- The gym and the locker room (the other locker room only if the puzzle needs it)
- The cafeteria and kitchen
- The art studio
- The chemistry lab (and the physics lab, if the prep room between them is given doors for the chase)
- The hallways between them, and the central courtyard

**Locked:** the classrooms, the seminar rooms, the computer lab, the tech workshop, the PE rooms, the fitness room, and the other storerooms and offices.

**How:** a locked room's doorway is closed with a plain wall piece, not a door. A door marked "locked" would not be enough, because the entity opens any door and would walk in. A solid wall also removes the room from the entity's walkable area once the navigation mesh is re-baked, so it never tries to patrol there. Six rooms are already sealed this way (see below).

**Checked on 2026-10-05:** with every door open, every room this script uses can be walked to from the lobby: library, bio lab, greenhouse, music room, gym, locker rooms, cafeteria, kitchen, art studio, chemistry lab and the courtyard. Six rooms have no doorway: the soil store, the tech workshop, the PE equipment and office block, the chem store with its prep room, the shared class prep room between classrooms 101 and 102, and the security office. Four of them are rooms the floor plan marks as closed; the two prep rooms are drawn with doors on the plan but have none in the level. Doorway 13 (link hall into the music room) is the only door the player cannot pass, because the hall floor is 0.79 m higher than the room; the music room's other door works.

## Objects to make

Every different object the puzzles and story beats need, room by room. "Shows under" is the flashlight color that makes it visible; "always" means it is a normal grey object, lit by any beam.

Types:

- **Model:** a 3D object. "Carried" means the player picks it up and moves it.
- **Image:** a flat picture placed on a surface (a wall, a floor, a sheet of paper).
- **Image with text:** the same, but the player has to read it, so it needs to be sharp up close.
- **Furniture:** set dressing the puzzle objects sit on. It can be simple.

There are 61 different objects in total. The two marked optional belong to the easter egg.

### Entry lobby

| Object | Type | Shows under | Notes |
|---|---|---|---|
| Flashlight | Model | always | Picked up off the counter. A placeholder exists. |
| Reception counter | Furniture | always | The flashlight sits on it. |

### Library (yellow)

| Object | Type | Shows under | Notes |
|---|---|---|---|
| Check-out slip | Image with text | always | A list of book titles and dates. Must be readable up close. |
| Wall calendar | Image with text | always | One date circled. |
| Bookshelves with books | Furniture | always | Spines need readable titles on at least one shelf. |
| The pullable book | Model | always | One book that tips out when used. |
| Swinging shelf section | Model | always | A piece of shelf that opens like a door onto the nook. |
| Coloring book | Model | always | "ME" and a drawing of a child with a flashlight on the cover. |
| Floor arrows | Image | yellow | Crayon arrows on the floor leading out. |

### Bio lab and greenhouse (indigo)

| Object | Type | Shows under | Notes |
|---|---|---|---|
| Seed packet | Model, carried | label under yellow | Several on a shelf. One has a drawing of a flower; that is the right one. |
| Seed shelf | Furniture | always |  |
| Plant pot | Model | always | Empty, on the potting bench. The seed and the water go here. |
| Potting bench | Furniture | always |  |
| Watering can | Model, carried | always |  |
| Sink | Furniture | always | Where the watering can starts. |
| Plant | Model, 3 stages | always | Sprout, stem, open flower. Swapped as it grows. |

### Music room (green)

| Object | Type | Shows under | Notes |
|---|---|---|---|
| Music stand | Furniture | always |  |
| Sheet music, blank | Image | always | Empty staves. |
| Sheet music, first half of the notes | Image | yellow | Laid over the blank sheet. |
| Sheet music, second half of the notes | Image | indigo | Laid over the blank sheet. |
| Xylophone frame | Model | always |  |
| Xylophone bar | Model, 7 of them | always | Each bar is used separately, so each is its own object. |
| Music box | Model, closed and open | always | Opens when the tune is right. |
| Piano | Furniture | always | The music box sits on it. |

### Gym and locker room (blue)

| Object | Type | Shows under | Notes |
|---|---|---|---|
| Scoreboard frame | Model | always |  |
| Scoreboard segment | Image, 7 of them | yellow, indigo or green each | The seven bars of one large digit. Each is one color, so the digit changes with the light. |
| Locker with a door that opens | Model | always | The crayon is inside. |
| Three-digit lock | Model | always | Three dials or buttons the player sets. |
| Order dots | Image | always | Three crayon dots above the lock, in the three colors. |
| Rows of plain lockers | Furniture | always | Set dressing around the real one. |

### Cafeteria and kitchen (red)

| Object | Type | Shows under | Notes |
|---|---|---|---|
| Fruit crate | Model | always |  |
| Banana | Model, carried | yellow | Decoy. |
| Pear | Model, carried | green | Decoy. |
| Blueberries | Model, carried | blue | Decoy. A small punnet, so it can be carried. |
| Plum | Model, carried | indigo | Decoy. |
| Apple | Model, carried, 3 of them | red | The answer. Dark until the player has red. |
| Note | Image with text | always | "3 apples for teacher." |
| Basket | Model | always | Accepts the fruit. |
| Teacher's table | Furniture | always |  |
| Wall hatch | Model | always | Opens when the basket is right. |

### Art studio (orange)

| Object | Type | Shows under | Notes |
|---|---|---|---|
| Paint jar | Model, carried, about 6 | one color each | All look the same unlit. One red, one yellow, the rest decoys in other colors. |
| Easel | Furniture | always |  |
| Unfinished painting | Image with text | always | Two numbered patches and the note "1 and 2 make the sun going down." |
| Palette | Model | always | Accepts the two jars. |
| Mixed orange paint | Model | always | Appears on the palette when both jars are placed. |
| Drawings of the entity | Image, 6 of them | one color each | Same spot on the wall, one per color, the entity closer in each. Signed "ME". |

### Chemistry lab (violet)

| Object | Type | Shows under | Notes |
|---|---|---|---|
| Periodic table poster | Image with text | always | Grey. |
| Highlighted element, first | Image | red | One cell of the poster. |
| Highlighted element, second | Image | blue | Another cell of the poster. |
| Element bottle | Model, carried, about 6 | always | Each labeled with a symbol. Two are the answer. |
| Bottle shelf | Furniture | always |  |
| Bunsen burner | Model | always | Accepts the two bottles. |
| Flame | Effect, 2 colors | always | Plain, then violet. |
| Dish | Model | always | The crayon is left in it. |
| Beaker of water | Model, carried | always | Optional, for the easter egg. |
| Mascot in steam | Image or effect | always | Optional, for the easter egg. |

### False exit and ending

| Object | Type | Shows under | Notes |
|---|---|---|---|
| Handprints and footprints | Image, several | violet | A trail along walls and floor to the front door. |
| Bricked-up wall | Model | always | Behind the front door. |
| "NOT THIS WAY" | Image with text | violet | Written across the bricks. |
| White crayon door | Image on a working door | white | Drawn on the courtyard wall. |
| Children's drawings for the halls | Image, a handful | one color each | What white light shows everywhere at the end. Can be reused around the school. |

### Already made, or not a puzzle object

- **Crayons:** one scene, `src/pickup/scenes/crayon.tscn`, set to any color. It is a placeholder shape; it needs a real crayon model once.
- **Doors:** `src/environment/scenes/school_door.tscn`, set to any color.
- **Desk to hide under:** `src/environment/scenes/desk.tscn`.
- **The entity:** still a placeholder capsule. It needs its model, and a colored version for the secret ending.
- **Ending screens:** three pictures (escape, uncovered, caught) plus the game over screen. These are menus, not objects in the level.

## What needs building

Five new pieces cover every puzzle and gate above. Everything else (color reveal, color-gated interaction, carrying, doors, crayons, the entity, lives) exists.

| Piece | Used by |
|---|---|
| **Hold the light on it:** something happens after the right color has shone on an object for a set time | Plant, uncovering the entity |
| **Place an item:** a spot that accepts a carried object | Seed and can, apples, paint jars, element bottles |
| **Press in order:** a set of things that must be used in the right sequence | Xylophone, locker |
| **Safe room:** a zone the entity will not enter until told it may | Every puzzle room |
| **Ending trigger:** ends the run and shows an ending screen | White door, entity uncovered, caught |

Already possible with what exists: every color-locked door, the violet trail, the seed labels, the fruit, the paint jars, the periodic table.

### Build order

Steps 1 to 7 are the base game and are all required. Steps 8 and 9 are strictly optional and only start once every room is built and tested. The order is set by what depends on what, so that each step can be played and tested as soon as it is done.

| Step | Build | Which then allows |
|---|---|---|
| 1 | Flashlight starts with no color | The lobby and library tutorial |
| 2 | **Hold the light on it** | The plant, and later the secret ending |
| 3 | **Place an item** | Seed and can, apples, paint jars, element bottles |
| 4 | **Press in order** | Xylophone, locker |
| 5 | **Safe room** and the entity getting faster per crayon | The entity behaving correctly around every puzzle |
| 6 | **Ending trigger** and the three ending screens | White door, entity uncovered, caught |
| 7 | The two scripted entity moments, and locking the unused rooms (see below) | First sighting, chemistry break-in, a smaller school |
| 8 | **Optional:** easy and hard mode, shuffled answers | Replay value |
| 9 | **Optional:** flickering light hints, mascot easter egg | Polish |

Steps 2 to 4 are the mechanics every puzzle is assembled from. Once they exist, the seven rooms can be built in parallel by whoever owns the levels, in route order (library first, chemistry last), while steps 5 to 7 continue.

Each room is done when: its door is set to the right color, its puzzle can be solved using only colors the player has by then, its crayon is collected, and the entity can enter only afterwards.

## Open

- Cut for time on 2026-10-05: a different way into each room per color (sunlight on vines, a door drawn on a wall, a color sensor, a code in blue pen, a darkroom photo, a hazard lever). Rooms now use color-locked doors. These can come back as polish if time allows.
- The exact list of rooms to lock. The reachability check is done; what is left is choosing which of the reachable, unused rooms get walled off.
- Whether the central courtyard is the final room. It is the middle of the school and every hall circles it.
- Whether the ceiling lights can flicker as hints. They are currently a texture on the ceiling material, not real lights.
- Doorway 13 (the raised link hall) is still blocked for the player, so the route above avoids it.
- This replaces the earlier decision that the first color is unlocked at the start: the flashlight now starts with no color.
