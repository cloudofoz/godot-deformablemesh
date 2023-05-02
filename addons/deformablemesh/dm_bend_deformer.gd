# Copyright (C) 2023 Claudio Z. (cloudofoz)
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

@tool
extends "dm_deformer.gd"

#---------------------------------------------------------------------------------------------------
# CONSTANTS
#---------------------------------------------------------------------------------------------------

const dm_eps = 0.0001

const dm_rot_axis = [Vector3.RIGHT, Vector3.UP, Vector3.BACK]

const dm_adj_axis = [Vector3.UP, Vector3.BACK, Vector3.RIGHT]

#---------------------------------------------------------------------------------------------------
# PUBLIC VARIABLES
#---------------------------------------------------------------------------------------------------
@export_category("Bend Deformer")

## Main deformation axis.
@export_enum("X:0", "Y:1", "Z:2") 
var main_axis = 1:
	set(value):
		main_axis = value
		dm_update_deformables()

## Bending angles (degrees)
@export_group("Rotation", "rot_")

## Bending along the X axis
@export_range(-360, +360, 5, "degrees",  "or_greater", "or_less")
var rot_x: int = 35:
	set(value):
		rot_x = value
		dm_rotation.x = deg_to_rad(value)
		dm_update_deformables()

## Bending along the Y axis
@export_range(-360, +360, 5, "degrees",  "or_greater", "or_less")
var rot_y: int = 0:
	set(value):
		rot_y = value
		dm_rotation.y = deg_to_rad(value)
		dm_update_deformables()

## Bending along the Z axis
@export_range(-360, +360, 5, "degrees",  "or_greater", "or_less")
var rot_z: int = 0:
	set(value):
		rot_z = value
		dm_rotation.y = deg_to_rad(value)
		dm_update_deformables()

#---------------------------------------------------------------------------------------------------
# PRIVATE VARIABLES
#---------------------------------------------------------------------------------------------------

var dm_rotation: Vector3 = Vector3(deg_to_rad(rot_x), deg_to_rad(rot_y), deg_to_rad(rot_z))

var dm_local_pos: Vector3

var dm_diameter: float

#---------------------------------------------------------------------------------------------------
# STATIC METHODS
#---------------------------------------------------------------------------------------------------

static func dm_vsub(v1: Vector3, v2: Vector3, i: int) -> float:
	return abs(v1[i] - v2[i])

#---------------------------------------------------------------------------------------------------
# VIRTUAL METHODS
#---------------------------------------------------------------------------------------------------

func _on_begin_update(d: DeformableMeshInstance3D) -> void:
	var aabb = d.original_mesh.get_aabb()
	dm_local_pos = d.to_local(self.global_position)
	dm_diameter = max(dm_vsub(dm_local_pos, aabb.position, main_axis), \
					dm_vsub(dm_local_pos, aabb.end, main_axis),        \
					aabb.size[main_axis])
	if(main_axis < 0 || main_axis > 2): main_axis = 1

func _on_update_vertex(v: Vector3) -> Vector3:
	v[main_axis] -= dm_local_pos[main_axis]
	var f = min(v[main_axis] / dm_diameter, 1.0)
	var t = Transform3D.IDENTITY
	for i in range(3):
		var angle = dm_rotation[i] * f
		if(abs(angle) < dm_eps): continue
		var axis = dm_rot_axis[i].rotated(dm_rot_axis[(i+2)%3], self.rotation[i])
		t = t.rotated_local(axis, angle)
	v = v * t
	v[main_axis] += dm_local_pos[main_axis]
	return v
