# Respawn Game Jam 2026

First-person horror game for PC. Godot 4.7 project.

## Inputs

The game supports keyboard and mouse, and any connected controller.

| Action | Keyboard / mouse | Controller (Xbox / PlayStation) |
|---|---|---|
| `move_forward` | W | Left stick up |
| `move_back` | S | Left stick down |
| `move_left` | A | Left stick left |
| `move_right` | D | Left stick right |
| `look_up` | Mouse | Right stick up |
| `look_down` | Mouse | Right stick down |
| `look_left` | Mouse | Right stick left |
| `look_right` | Mouse | Right stick right |
| `interact` | E or left click | A / Cross |
| `sprint` | Shift | Left stick click |
| `crouch` | Ctrl (hold) | B / Circle (hold) |
| `flashlight` | F or right click | RT / R2 |
| `color_next` | R or mouse wheel down | RB / R1 |
| `color_prev` | Q or mouse wheel up | LB / L1 |
| `pause` | Escape | Start |

### Menus

| Action | Keyboard / mouse | Controller (Xbox / PlayStation) |
|---|---|---|
| Move between buttons | Arrow keys, or hover with the mouse | D-pad or left stick |
| Press the highlighted button | Enter, Space, or left click | A / Cross |

The ending screen is a menu too: its one button, **Main Menu**, is highlighted when the screen appears.

Moving between buttons uses Godot's built-in `ui_up` and `ui_down` actions. `ui_accept` is overridden in the project settings to add the controller button, which Godot does not include by default.
## Audio

Every sound is played by name through the `AudioController` autoload. The names, and the audio file behind each one, are listed in `src/audio/resources/game_sound_library.tres`. To hear everything in the list, run `src/audio/scenes/sound_test.tscn` on its own. How to add or swap a sound, and the functions scripts can call, are in [src/audio/README.md](src/audio/README.md).
