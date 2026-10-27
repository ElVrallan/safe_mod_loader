# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2026 Estudio Eclipse. All rights reserved.

extends RefCounted
class_name SafeModSandbox

## SafeModSandbox
## Cargador de mods seguro con arquitectura Zero-Trust para Godot 4.x.
## Previene vulnerabilidades críticas de Ejecución Remota de Código (RCE) y sobrescritura
## de scripts del proyecto, bloqueando paquetes binarios (.pck) y cargando únicamente
## assets de datos puros (.zip) deserializados directamente en memoria.

const ALLOWED_EXTENSIONS: Array[String] = [
	"png", "jpg", "jpeg", "webp",
	"ogg", "wav",
	"glb", "gltf",
	"json"
]

const FORBIDDEN_EXTENSIONS: Array[String] = [
	"pck", "gd", "gdc", "cs", "dll", "so", "dylib", "exe", "bat", "sh"
]


static func load_mod_archive(zip_path: String) -> Dictionary:
	var result := {
		"textures": {},
		"audio": {},
		"models": {},
		"json": {}
	}

	if not FileAccess.file_exists(zip_path):
		push_error("[SafeModSandbox] Archivo de mod no encontrado: %s" % zip_path)
		return result

	var reader := ZIPReader.new()
	var err: Error = reader.open(zip_path)
	if err != OK:
		push_error("[SafeModSandbox] No se pudo abrir el archivo ZIP: %s" % error_string(err))
		return result

	var file_list: PackedStringArray = reader.get_files()
	for path in file_list:
		var ext: String = path.get_extension().to_lower()
		var base_name: String = path.get_file()

		if FORBIDDEN_EXTENSIONS.has(ext):
			push_warning("[SafeModSandbox] SEGURIDAD: Bloqueado script o ejecutable malicioso: %s" % path)
			continue

		if not ALLOWED_EXTENSIONS.has(ext):
			continue

		var data: PackedByteArray = reader.read_file(path)
		if data.is_empty():
			continue

		match ext:
			"png", "jpg", "jpeg", "webp":
				var img := Image.new()
				var img_err: Error = OK
				if ext == "png":
					img_err = img.load_png_from_buffer(data)
				elif ext == "webp":
					img_err = img.load_webp_from_buffer(data)
				else:
					img_err = img.load_jpg_from_buffer(data)

				if img_err == OK:
					result["textures"][base_name] = ImageTexture.create_from_image(img)

			"ogg":
				var ogg := AudioStreamOggVorbis.load_from_buffer(data)
				if ogg != null:
					result["audio"][base_name] = ogg

			"json":
				var json_str: String = data.get_string_from_utf8()
				var parsed: Variant = JSON.parse_string(json_str)
				if parsed != null:
					result["json"][base_name] = parsed

			"glb", "gltf":
				var gltf := GLTFDocument.new()
				var state := GLTFState.new()
				if gltf.append_from_buffer(data, "", state) == OK:
					var root: Node = gltf.generate_scene(state)
					if root != null:
						strip_scripts(root)
						result["models"][base_name] = root

	reader.close()
	return result


static func strip_scripts(node: Node) -> void:
	if node.get_script() != null:
		node.set_script(null)
	for child in node.get_children():
		strip_scripts(child)
