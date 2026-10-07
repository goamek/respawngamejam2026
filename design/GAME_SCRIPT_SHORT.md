# Game Script, Short Version

A five-room version of `GAME_SCRIPT.md`, cut down to what is quickest to make and get working. The story, the one rule and the endings are the same. The full script is kept as it was, for reference.

Draft of 2026-10-05. Items marked **Open** are not decided.

## What changed from the full script

| | Full script | This version |
|---|---|---|
| Puzzle rooms | 7 | 5 |
| Crayons | 7, one per room | 7, but two rooms give two each |
| Different objects to make | 61 | 29 |
| New mechanics to build | 5 | 4 |

**Rooms cut:** the music room and the chemistry lab. They had the hardest objects (a playable xylophone, layered sheet music, a music box, a readable periodic table, a flame that changes color) and the chemistry lab had the scripted break-in.

**Cut from the rooms that stay:**

- The swinging bookshelf, the watering can and sink, the plant's middle growth stage, the wall hatch, the locker's three-digit lock, the mixed-paint blob.
- The false exit: the violet trail of prints, the bricked-up wall and its writing.

**Mechanic cut:** "press in order". Nothing needs it any more.

**Kept:** written clues. Notes, labels and titles tell the player what to do in plain words, the same as in the full script. Every puzzle room has at least one note in the player's childhood handwriting that says what the room wants.

## The one rule

**What is drawn in a color only exists in that color's light.**

The school is black and grey. The crayon drawings and marks the player made here as a child are all over it, each in one color, and each invisible until the flashlight shines that color on it.

Picking up a crayon gives the flashlight a new color. Each room's door only opens under a color earned earlier, so the crayons set the order of the game. The creative use of each color is inside the rooms, in the puzzles.

## Story

**The player is the child, grown up.** There is one person in this story, at two ages.

- As a child, the player went to this school and filled a coloring book with drawings of it. The book and its seven crayons were left behind.
- The entity is one of those drawings. The player drew it in every color, got scared of it, and scribbled over it in black crayon until only the eyes were left as bare paper. That is why it is solid black with white eyes.
- Years later the player comes back. The school is grey because they have forgotten it. Each crayon they find brings back one color of how they saw it then.
- With all seven the flashlight turns white, the school shows as they remembered it, and the way out appears.

How the player learns this, with no dialogue:

- **Library:** the coloring book has a drawing on its cover of a child holding a flashlight, labeled "ME".
- **Art studio:** the drawings of the entity are signed "ME" as well.
- **Endings:** each one says it outright.

## Route at a glance

The flashlight starts with no color, only a grey beam that reveals nothing. It keeps that grey beam for the whole game, alongside the colors it gains. The route is one loop of the school that ends beside where it began.

| # | Room | Door | Crayons earned | The idea |
|---|---|---|---|---|
| 0 | Entry lobby | Start here | none (flashlight) | Tutorial: move, look, pick up |
| 1 | Library | Open | Yellow | Solve a puzzle with no color |
| 2 | Greenhouse | Yellow | Green and Indigo | Yellow is sunlight |
| 3 | Gym and locker room | Green | Blue | One object reads differently under each color |
| 4 | Cafeteria | Blue | Red | Find it by what stays dark |
| 5 | Art studio | Red | Orange and Violet | Mixing colors |
| 6 | Central courtyard | White | Ending | Everything in color at once |

Every puzzle can be solved with only the colors the player has when they reach it.

## Beat by beat

### 0. Entry lobby (tutorial, no entity)

- The front door shuts behind the player. The lobby is nearly black.
- A flashlight lies on the reception counter, switched off. Picking it up teaches interact, and a hint then teaches the on and off switch. It gives a weak grey beam.

### 1. Library (earn Yellow)

**Door:** open. **Colors needed:** none.

1. A check-out slip on the desk lists four book titles, each with a date. A note across the top reads "ONE NEVER CAME BACK".
2. A wall calendar has one date circled, with "book due!" written beside it. That date is on the slip, next to one title.
3. The shelf has a row of books with their titles on the spines. The player takes the one that matches.
4. It is their old coloring book, with "ME" on the cover. The yellow crayon is tucked inside. Picking it up turns the beam yellow.

Taking a wrong book does nothing.

**Teaches:** reading a clue, interacting, and that a crayon changes the flashlight.

**Locked in:** once the player walks into the library holding the flashlight, the main door slams shut behind them and locks. It unlocks again once the entity sighting below is over. Until then the only way out is through the two small rooms on the east side (archive, then office), whose doors need yellow.

**Entity:** on the way out, the player opens the office door and sees it for the first time, staring at them through the window of the door to the main hall. A hint reads "Crouch under a desk to hide"; there is a desk in the office and one in the archive behind them. Crouching under either makes it walk away, and from then on it roams the school. Waiting about 8 seconds, walking up to the window, or opening that door makes it come in after the player instead. This is the hiding tutorial, and the only scripted entity moment in the game.

### 2. Greenhouse (earn Green and Indigo)

**Door:** yellow. **Colors needed:** yellow.

1. A note on the bench reads "Flowers need a seed and SUN." The word SUN is written in yellow, so it only shows under the yellow beam.
2. A handful of seed packets, all grey. Each has a name and a small picture on it that only show under yellow: carrot, tree, weed, flower.
3. Carry the flower packet to the empty pot.
4. Hold the yellow beam on the pot. Yellow is sunlight: after a few seconds a flower stands in the pot.
5. Two crayons are in it: green among the leaves, indigo in the bloom.

**Entity:** from here on it roams. It cannot enter a puzzle room until that room's puzzle is solved.

### 3. Gym and locker room (earn Blue)

**Door:** green. **Colors needed:** yellow, green, indigo.

1. The gym scoreboard shows one large digit made of seven bars. Each bar is drawn in one color, so the digit reads as a different number under yellow, under green, and under indigo.
2. Three crayon dots on the scoreboard's frame give the order: for example green, yellow, indigo. A note under it reads "my locker number, don't forget".
3. The three digits in that order are a locker number.
4. The locker room has a row of numbered lockers. The player opens that one. The blue crayon is inside.

Opening a wrong locker makes a loud clang, which brings the entity to the door.

**Entity:** the gym is the largest room, with long sight lines. Once the right locker is open, it is no longer safe.

### 4. Cafeteria (earn Red)

**Door:** blue. **Colors needed:** yellow, green, indigo, blue.

1. A pile of fruit on a table, all grey. Beside an empty basket is a note in childhood handwriting: "3 apples for teacher."
2. Under yellow the bananas show. Under green, the pears. Under blue, the blueberries. Under indigo, the plums.
3. Three pieces never light up under any color the player owns. Those are the apples, because the player has no red.
4. Carry the three dark fruit to the basket. The red crayon appears among them.
5. With red, the apples show in color, confirming the answer.

### 5. Art studio (earn Orange and Violet)

**Door:** red. **Colors needed:** red, yellow, blue.

1. The walls have three drawings of the entity the player made as a child, each signed "ME". Each shows under a different color, and in each the entity is closer.
2. A shelf of identical grey paint jars. Only light shows which color each one is.
3. Two palettes, each under an unfinished painting with a note. One reads "red and yellow make the sun going down." The other reads "red and blue make grapes."
4. Red and yellow jars on the first palette make the orange crayon appear.
5. Red and blue jars on the second palette make the violet crayon appear.

There are two red jars, so the player does not have to move one back.

With all seven crayons, the beam turns white.

### 6. Central courtyard (ending)

- White shows everything at once, in full color.
- A door stands alone in the middle of the courtyard. It was not there before: it appears the moment the beam turns white. It is black until the white beam is on it, and using it is the way out.

## Endings

All three are part of the base game.

| Ending | How | What happens |
|---|---|---|
| Escape | Use the white door in the courtyard | The player leaves with the coloring book. The school goes grey behind them, and the entity is still inside: they got out, but never faced it. |
| Uncovered (secret) | Hold the white beam on the entity for 3 seconds while it comes at the player; the light slows it, and its colors show through as the time builds | The black scribble flakes away and the colors the player first drew show through. It was never a monster, only a drawing they were scared of. This is the true ending. |
| Caught | Lose every life | A new drawing appears on the art studio wall: the child labeled "ME", scribbled over in black. |

## The entity through the run

- **Lobby and library:** absent, then one scripted sighting at the office door on the way out.
- **From that sighting on:** roams, investigates light and noise, opens doors.
- **Safe rooms:** it cannot enter a puzzle room until that puzzle is solved.
- **Gets faster:** a small speed increase with each crayon collected.

## Unused rooms are locked

**Rooms in use:** the entry lobby, the library, the bio lab and greenhouse, the gym and one locker room, the cafeteria, the art studio, the central courtyard, and the hallways between them.

**Locked:** everything else, now including the music room, the chemistry and physics labs, and the kitchen. A locked room's doorway is closed with a plain wall piece, not a door, because the entity opens any door. The navigation mesh is re-baked afterwards.

All of the rooms in use were checked on 2026-10-05 and can be walked to from the lobby.

## Objects to make

29 different objects. "Shows under" is the flashlight color that makes it visible; "always" means a normal grey object.

- **Model:** a 3D object. "Carried" means the player picks it up and moves it.
- **Image:** a flat picture placed on a surface.
- **Image with text:** the same, but the player has to read it, so it needs to be sharp up close.
- **Furniture:** set dressing. The existing desk scene can stand in for most of it.

### Entry lobby

| Object | Type | Shows under | Notes |
|---|---|---|---|
| Flashlight | Model | always | A placeholder exists. |
| Reception counter | Furniture | always | |

### Library

| Object | Type | Shows under | Notes |
|---|---|---|---|
| Check-out slip | Image with text | always | Four titles, each beside a date, and "ONE NEVER CAME BACK". |
| Wall calendar | Image with text | always | One date circled, with "book due!". |
| Bookshelf | Furniture | always | |
| Book | Model, about 4 | always | One model, with a different title on each spine. |
| Coloring book | Model | always | "ME" and a child with a flashlight on the cover. It is the right book. |

### Greenhouse

| Object | Type | Shows under | Notes |
|---|---|---|---|
| Seed packet | Model, carried, about 4 | always | One model. |
| Packet label | Image with text, about 4 | yellow | One per packet: a name and a small picture. Flower, carrot, tree, weed. |
| Bench note | Image with text | always, with one word in yellow | "Flowers need a seed and SUN." |
| Plant pot | Model | always | Accepts the packet. |
| Flower | Model | always | Appears in the pot. One stage only. |

### Gym and locker room

| Object | Type | Shows under | Notes |
|---|---|---|---|
| Scoreboard frame | Model | always | A plain box. |
| Scoreboard bar | Image, 7 | yellow, green or indigo each | Seven plain rectangles. |
| Order dots and note | Image with text | always | Three crayon dots on the frame, and "my locker number, don't forget". |
| Locker | Model, about 8 | always | One model with a door that opens. |
| Locker number | Image, about 8 | always | A three-digit number on each door. |

### Cafeteria

| Object | Type | Shows under | Notes |
|---|---|---|---|
| Banana | Model, carried | yellow | Decoy. |
| Pear | Model, carried | green | Decoy. |
| Blueberries | Model, carried | blue | Decoy. |
| Plum | Model, carried | indigo | Decoy. |
| Apple | Model, carried, 3 | red | The answer. |
| Basket | Model | always | Accepts the fruit. |
| Note | Image with text | always | "3 apples for teacher." |

Simple rounded shapes are enough for the fruit. Under the crayon effect they only need to read by color and outline.

### Art studio

| Object | Type | Shows under | Notes |
|---|---|---|---|
| Paint jar | Model, carried, 5 | one color each | One model: two red, one yellow, one blue, one green decoy. |
| Palette | Model, 2 | always | One model. Each accepts two jars. |
| Unfinished paintings with notes | Image with text, 2 | always | "red and yellow make the sun going down." and "red and blue make grapes." |
| Drawings of the entity | Image, 3 | one color each | Signed "ME". |

### Ending

| Object | Type | Shows under | Notes |
|---|---|---|---|
| White door | Free-standing door and frame | white | In the middle of the courtyard; appears when the beam turns white. A placeholder made of boxes is in. |

### Already made, or not a level object

- **Crayons, doors, the hiding desk:** these scenes exist.
- **The entity:** still a placeholder capsule. It needs its model, and a colored version for the secret ending.
- **Ending screens:** three pictures (escape, uncovered, caught) plus the game over screen.

## What needs building

Four new mechanics. Everything else exists.

| Piece | Used by |
|---|---|
| **Hold the light on it:** something happens after the right color has shone on an object for a set time | The flower, uncovering the entity |
| **Place an item:** a spot that accepts a carried object | Seed packet, apples, paint jars |
| **Safe room:** a zone the entity will not enter until told it may | Every puzzle room |
| **Ending trigger:** ends the run and shows an ending screen | White door, entity uncovered, caught |

Already possible with what exists: every color-locked door, the written clues, the books, the scoreboard bars, the lockers, the fruit and the jars (as carried objects that show under one color).

### Build order

Steps 1 to 6 are the base game and are all required. Step 7 is strictly optional.

| Step | Build | Which then allows |
|---|---|---|
| 1 | Flashlight starts with no color | The lobby and library, playable end to end |
| 2 | **Place an item** | Greenhouse, cafeteria, art studio |
| 3 | **Hold the light on it** | The flower, and later the secret ending |
| 4 | **Safe room**, the entity getting faster per crayon, and the first sighting | The entity behaving correctly around every room |
| 5 | **Ending trigger** and the three ending screens | White door, entity uncovered, caught |
| 6 | Locking the unused rooms and re-baking the navigation mesh | A smaller school |
| 7 | **Optional:** easy and hard mode, shuffled answers, light hints | Replay value |

The library needs none of the new mechanics, so it can be built first, while steps 2 and 3 are in progress.

Each room is done when: its door is set to the right color, its puzzle can be solved using only colors the player has by then, its crayons are collected, and the entity can enter only afterwards.

## Open

- Which of the two locker rooms the gym puzzle uses.
- Whether the central courtyard is the final room.
- If time allows, the music room and the chemistry lab can be added back from the full script. The greenhouse and the art studio would then give one crayon each again, with green moving to the music room and violet to the chemistry lab.
