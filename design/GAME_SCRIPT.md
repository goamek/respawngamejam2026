# Game Script

The full run of the game from the front door to the ending: where the player goes, what each crayon lets them do, how every puzzle works, and what the entity is doing meanwhile. The mechanics it is built from (flashlight colors, interaction, doors, the entity) are described in the README files under `respawn-game-jam-2026/`.

Draft of 2026-10-05. Items marked **Open** are not decided.

## The one rule

**What is drawn in a color only exists in that color's light.**

The school is black and grey. The crayon drawings, labels, and scribbles the player made here as a child are all over it, each in one color, and each invisible until the flashlight shines that color on it. Some drawings are only clues. Some are real: a drawn door opens, a drawn handle turns.

A crayon is never a key. Picking one up gives the flashlight a new color, and each color opens the next part of the school in a different way (grow something, find something hidden, trip a sensor, read a trail). No two colors gate progress the same way.

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
| 2 | Bio lab and greenhouse | Yellow grows the dead vines off the door | Indigo | Yellow is sunlight |
| 3 | Music room | Indigo shows a door drawn on the corridor wall | Green | Two colors, one message |
| 4 | Gym and locker room | Green on the door sensor ("green means go") | Blue | One object reads differently under each color |
| 5 | Cafeteria | Blue shows the code written on the kitchen order pad | Red | Find it by what stays dark |
| 6 | Darkroom and art studio | Red is the darkroom safelight; it develops the photo that shows the way in | Orange | Light tells identical things apart |
| 7 | Chemistry lab | Orange shows the hazard-marked shutter lever | Violet | Flame test |
| 8 | Main entry (false exit) | Violet | none | The first exit fails |
| 9 | Central courtyard | White shows the door drawn in white crayon | Ending | Everything in color at once |

Each crayon is used three times: to get into the next area, inside that area's puzzle, and again in later puzzles alongside newer colors.

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

**Access:** the bio lab door is choked with dead grey vines. Holding the yellow beam on them for a few seconds makes them green up and pull back. **Colors needed:** yellow.

1. Shelves of seed packets, all grey. Their labels only show under yellow. One is marked with their own childhood drawing of a flower.
2. Carry that packet to the empty pot on the potting bench.
3. Carry the watering can from the sink to the pot.
4. Hold the yellow beam on the pot. The plant grows and opens. The indigo crayon is inside the flower.

**Entity:** from here on it roams. It cannot enter a puzzle room until that room's puzzle is solved.

### 3. Music room (earn Green)

**Access:** the corridor wall by the music room looks blank. Under indigo, a door drawn in crayon appears, and it opens. **Colors needed:** yellow, indigo.

1. A sheet of music on the stand shows empty staves.
2. Under yellow, some notes appear. Under indigo, the rest appear. Neither half is a tune alone.
3. A child's xylophone has seven bars. The player strikes the bars in the order of the full tune.
4. A music box on the piano opens. The green crayon is inside.

**Entity:** playing a wrong note makes noise. The entity comes to check the door (it still cannot enter).

### 4. Gym and locker room (earn Blue)

**Access:** the gym doors have a small sensor panel. Shining green on it unlocks them. **Colors needed:** yellow, indigo, green.

1. A locker in the locker room has a three-digit lock, with three crayon dots above it: for example green, yellow, indigo. That is the order.
2. The gym scoreboard shows one large digit made of segments. Each segment is drawn in one color, so the digit reads differently under yellow, under indigo, and under green.
3. The player reads the three digits, takes them in the order of the dots, and enters them on the locker.
4. The blue crayon is in the locker.

**Entity:** the gym is the largest room, with long sight lines. It is the first place the entity can see the beam from far away. Once the locker opens, the gym stops being safe.

### 5. Cafeteria and kitchen (earn Red)

**Access:** the kitchen door has a keypad. An order pad on the serving counter has a number written in blue pen. **Colors needed:** yellow, indigo, green, blue.

1. A crate of fruit, all grey. A note in their childhood handwriting: "3 apples for teacher."
2. Under yellow the bananas show. Under green, the pears. Under blue, the blueberries. Under indigo, the plums.
3. Three pieces never light up under any color the player owns. Those are the apples, because the player has no red.
4. Carry the three dark fruit to the basket on the teacher's table. A wall hatch opens. The red crayon is inside.
5. Shining red on the basket shows the apples in color, confirming the answer.

**Entity:** stands at the hallway intersection outside when the player leaves, as in the team's outline.

### 6. Darkroom and art studio (earn Orange)

**Access:** the art studio door is jammed. The photo darkroom next to it has blank sheets hanging on a line. Red is a darkroom's safelight: under red, one photo develops and shows the supply closet with its back panel open. The player goes through the closet into the studio. **Colors needed:** red, yellow.

1. The studio walls are covered in the drawings of the entity the player made as a child, each signed "ME". Each color shows a different drawing in the same spot, and in each one the entity is closer.
2. A row of identical grey paint jars. Only light shows which is which.
3. An unfinished painting on the easel has two numbered patches and a note: "1 and 2 make the sun going down."
4. Carry the red jar and the yellow jar to the palette. They mix. The orange crayon sits in the paint.

### 7. Chemistry lab (earn Violet)

**Access:** an emergency shutter is down over the lab door. Under orange, hazard stripes appear along a pipe, leading to the release lever. **Colors needed:** red, blue, orange.

1. The periodic table poster is grey. Under red, one element lights up. Under blue, another.
2. The same two symbols are on bottles in the chem store.
3. Carry both bottles to the burner. The flame turns violet, and the violet crayon is left in the dish.
4. Easter egg: carrying water to the burner makes the Respawn mascot appear in the steam.

**Entity:** when the flame turns violet, it breaks into the lab. The player escapes through the door they came in by, or through the shared prep room into the physics lab. This is the one scripted chase.

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

## Replay value

In order of cost:

1. **Easy and hard mode.** Entity speed and sight range, 3 lives or 1, flickering light hints on or off.
2. **Three endings.**
3. **Shuffled answers on a fixed route.** Each run picks from a few presets: which book, which tune, which locker digits, which pair of elements, where the apples sit. The order of rooms never changes, so every run can be finished.

Not planned: shuffling the route or the crayon locations between rooms. It would need every access gate to work in any order.

## What needs building

Five new pieces cover every puzzle and gate above. Everything else (color reveal, color-gated interaction, carrying, doors, crayons, the entity, lives) exists.

| Piece | Used by |
|---|---|
| **Hold the light on it:** something happens after the right color has shone on an object for a set time | Vines, plant, green sensor, uncovering the entity |
| **Place an item:** a spot that accepts a carried object | Seed and can, apples, paint jars, element bottles |
| **Press in order:** a set of things that must be used in the right sequence | Xylophone, locker, kitchen keypad |
| **Safe room:** a zone the entity will not enter until told it may | Every puzzle room |
| **Ending trigger:** ends the run and shows an ending screen | White door, entity uncovered, caught |

Already possible with what exists: the hidden doors (indigo wall door, closet panel), the hidden lever, the violet trail, the seed labels, the fruit, the paint jars, the periodic table.

### Build order

Everything in this script is planned to be finished. Nothing is marked as optional. The order below is set by what depends on what, so that each step can be played and tested as soon as it is done.

| Step | Build | Which then allows |
|---|---|---|
| 1 | Flashlight starts with no color | The lobby and library tutorial |
| 2 | **Hold the light on it** | Vines, plant, green sensor, and later the secret ending |
| 3 | **Place an item** | Seed and can, apples, paint jars, element bottles |
| 4 | **Press in order** | Xylophone, locker, kitchen keypad |
| 5 | **Safe room** and the entity getting faster per crayon | The entity behaving correctly around every puzzle |
| 6 | **Ending trigger** and the three ending screens | White door, entity uncovered, caught |
| 7 | The two scripted entity moments | First sighting, chemistry break-in |
| 8 | Easy and hard mode, shuffled answers | Replay value |
| 9 | Flickering light hints, mascot easter egg | Polish |

Steps 2 to 4 are the mechanics every puzzle is assembled from. Once they exist, the seven rooms can be built in parallel by whoever owns the levels, in route order (library first, chemistry last), while steps 5 to 9 continue.

Each room is done when: its gate opens the intended way, its puzzle can be solved using only colors the player has by then, its crayon is collected, and the entity can enter only afterwards.

## Open

- Whether the central courtyard is the final room. It is the middle of the school and every hall circles it.
- Whether the ceiling lights can flicker as hints. They are currently a texture on the ceiling material, not real lights.
- Doorway 13 (the raised link hall) is still blocked for the player, so the route above avoids it.
- This replaces the earlier decision that the first color is unlocked at the start: the flashlight now starts with no color.
