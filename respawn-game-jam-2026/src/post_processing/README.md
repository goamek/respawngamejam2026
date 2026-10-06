# Post-processing

Full-screen effects drawn over the 3D view. The HUD (hearts, crosshair, color swatches) is drawn afterwards and is not affected.

## Crayon effect

Gives the game a hand-drawn, coloring-book look:

- **Outlines:** dark lines along the edges of objects and along creases where surfaces meet at an angle.
- **Crayon grain:** a waxy texture with diagonal strokes over everything.
- **Wobble:** optional, off by default to avoid motion sickness. When on, the lines and grain shift slightly a few times a second, like hand-drawn animation.

Files:

- `shaders/crayon.gdshader`: the effect.
- `resources/crayon_material.tres`: the material holding its settings.
- `scenes/crayon_effect.tscn`: a screen-covering quad that applies it.

The effect is part of the player scene, as `Player/Head/Camera3D/CrayonEffect`, so every level with the player gets it. To switch it off, hide that node (the eye icon in the Scene dock).

### Settings

Edit them on `resources/crayon_material.tres`, under **Shader Parameters**. Changes apply everywhere.

| Group | Setting | Default | Meaning |
|---|---|---|---|
| Outlines | `outline_color` | black | Line color. Lower its alpha to make lines fainter. |
| Outlines | `line_thickness` | 1.5 px | Thickness of the lines. |
| Outlines | `depth_threshold` | 0.08 | How big a jump in distance counts as an object's edge. Lower finds more edges. |
| Outlines | `normal_threshold` | 0.35 | How sharp a corner counts as a crease. Lower finds more creases. |
| Crayon | `grain_strength` | 0.3 | How strongly the grain shows. 0 turns it off. |
| Crayon | `grain_scale` | 3 px | Size of the grain. |
| Crayon | `stroke_angle` | 35 degrees | Direction of the crayon strokes. |
| Wobble | `wobble_amount` | 0 px | How far lines and grain shift. 0 keeps the image completely still. |
| Wobble | `wobble_rate` | 8 per second | How often they shift. Lower looks choppier and more hand-drawn. |

### How it works

The quad sits in front of the camera and covers the whole screen. Its shader reads three pictures Godot has already rendered for the frame: the image itself, the depth (how far away each pixel is), and the normals (which way each surface faces). Where depth or normal changes sharply between neighboring pixels, there is an edge, and the shader draws a line there. It then multiplies the image by a procedural noise pattern to make the grain. The colors themselves are not changed, so the flashlight's colors stay easy to tell apart.

It needs the Forward+ renderer, which the project already uses.
