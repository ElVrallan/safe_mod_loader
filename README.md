# Safe Mod Loader (Zero-Trust Sandbox) for Godot 4.x

A battle-hardened runtime mod loader for Godot 4.x games that prevents Arbitrary Code Execution and malware injection from third-party community mods.

## Why Godot's Default `.pck` Loading is Vulnerable

Godot's native `ProjectSettings.load_resource_pack()` allows any `.pck` file to shadow and overwrite existing engine scripts (`res://...`). A malicious mod author can replace gameplay or UI scripts to execute arbitrary system code on player computers.

## The Zero-Trust Solution

- **Prohibits Executables & Scripts**: Completely discards `.pck`, `.gd`, `.cs`, `.dll`, and executables.
- **In-Memory Deserialization**: Uses `ZIPReader` to inspect and load textures, audio, and models directly in memory.
- **GLTF Script Stripping**: Cleans 3D models of any embedded scripts prior to adding them to the scene tree.
- **Clean Whitelist**: Only permits sanitized multimedia data: `.png`, `.jpg`, `.webp`, `.ogg`, `.wav`, `.glb`, `.gltf`, `.json`.

## Usage

```gdscript
var mod_data: Dictionary = SafeModSandbox.load_mod_archive("user://mods/custom_skin.zip")
var custom_texture = mod_data["textures"].get("albedo.png")
```

## ⚖️ Licencia y Uso Comercial
Este plugin está licenciado bajo la **Mozilla Public License 2.0 (MPL-2.0)** por **Estudio Eclipse**.

### ¿Puedo usar este plugin en mi videojuego comercial cerrado (Steam, Consolas, Móviles)?
**SÍ.** La licencia MPL-2.0 permite explícitamente compilar e integrar este plugin dentro de obras comerciales propietarias (*Larger Works*) sin que tengas que liberar el código de tu juego ni tus recursos artísticos.

### ¿Qué obligaciones tengo?
1. Si realizas cambios o mejoras directamente sobre los archivos de este plugin (por ejemplo, optimizaciones o correcciones de bugs en sus scripts), debes poner a disposición de la comunidad esas modificaciones bajo la misma licencia MPL-2.0.
2. Mantener los avisos de copyright y autoría original de **Estudio Eclipse**.
