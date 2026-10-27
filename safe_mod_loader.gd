# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2026 Estudio Eclipse. All rights reserved.

@tool
extends EditorPlugin
## Safe Mod Loader Plugin for Godot 4.x

func _enter_tree() -> void:
	print("[SafeModLoader] Plugin activado.")


func _exit_tree() -> void:
	print("[SafeModLoader] Plugin desactivado.")
