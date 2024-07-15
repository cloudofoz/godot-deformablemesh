# Copyright (C) 2023-2024 Claudio Z. (cloudofoz)
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

const dm_ref_axis = [Vector3.MODEL_LEFT, Vector3.MODEL_TOP, Vector3.MODEL_FRONT]

#---------------------------------------------------------------------------------------------------
# PUBLIC VARIABLES
#---------------------------------------------------------------------------------------------------
@export_category("Standard Deformer")

## Deformer Type
@export_enum("Bend:0", "Twist:1", "Taper:2") 
var type = 0:
	set(value):
		type = value
		dm_update_deformables()

## Main deformation axis.
@export_enum("X:0", "Y:1", "Z:2") 
var main_axis = 1:
	set(value):
		if value != second_axis:
			main_axis = value
		else:
			push_warning("Main axis has to be different from the secondary axis")
			main_axis = ( value + 1 ) % 3
		dm_third_axis = dm_find_third_axis(main_axis, second_axis)
		dm_update_deformables()

# Secondary axis.
@export_enum("X:0", "Y:1", "Z:2") 
var second_axis = 0:
	set(value):
		if value != main_axis:
			second_axis = value
		else:
			push_warning("Secondary axis has to be different from the main axis")
			second_axis = ( value + 1 ) % 3
		dm_third_axis = dm_find_third_axis(main_axis, second_axis)
		dm_update_deformables()

@export_subgroup("Blend - Twist", "bending_")

## Bending / Twisting angle
@export_range(-360, +360, 5, "degrees",  "or_greater", "or_less")
var bending_angle: int = 35:
	set(value):
		bending_angle = value
		dm_bending_angle = deg_to_rad(value) if abs(value) >= dm_eps else dm_eps
		dm_update_deformables()

@export_subgroup("Taper", "taper_")

# Taper Factor
@export_range(-2.0, 2.0, 0.25, "or_greater", "or_less")
var taper_factor: float = 0:
	set(value):
		taper_factor = value
		dm_update_deformables()

#---------------------------------------------------------------------------------------------------
# PRIVATE VARIABLES
#---------------------------------------------------------------------------------------------------

var dm_third_axis: float    = 2

var dm_bending_angle: float = deg_to_rad(bending_angle)

var dm_radius: float

var dm_local_pos: Vector3

var dm_length: float

#---------------------------------------------------------------------------------------------------
# STATIC METHODS
#---------------------------------------------------------------------------------------------------

static func dm_vsub(v1: Vector3, v2: Vector3, i: int) -> float:
	return abs(v1[i] - v2[i])
	
static func dm_find_third_axis(a: int, b: int) -> int:
	for c in range(3):
		if c != a && c != b: 
			return c
	return -1

#---------------------------------------------------------------------------------------------------
# VIRTUAL METHODS
#---------------------------------------------------------------------------------------------------

func _on_begin_update(d: DeformableMeshInstance3D) -> void:
	var aabb = d.original_mesh.get_aabb()
	dm_local_pos = d.to_local(self.global_position)
	
	dm_length = aabb.size[main_axis]
	dm_radius = dm_length / dm_bending_angle

func _on_update_vertex(v: Vector3) -> Vector3:
	match(type):
		0: return dm_bend_deform(v)
		1: return dm_twist_deform(v)
		2: return dm_taper_deform(v)
	return v

#---------------------------------------------------------------------------------------------------
# PRIVATE METHODS
#---------------------------------------------------------------------------------------------------

func dm_bend_deform(v: Vector3) -> Vector3:
	var p = v.rotated(dm_ref_axis[main_axis], self.rotation[main_axis])
	var alpha = dm_bending_angle * ( p[main_axis] - dm_local_pos[main_axis] ) / dm_length
	var r = dm_radius + p[second_axis]
	var out: Vector3
	out[main_axis] = r * sin(alpha) + dm_local_pos[main_axis]
	out[second_axis] = r * cos(alpha) - dm_radius
	out[dm_third_axis] = p[dm_third_axis]
	return out

func dm_twist_deform(v: Vector3) -> Vector3:
	var alpha = dm_bending_angle * ( v[main_axis] - dm_local_pos[main_axis] ) / dm_length
	var p = v.rotated(dm_ref_axis[main_axis], alpha)
	return p

func dm_taper_deform(v: Vector3) -> Vector3:
	var h = dm_length - dm_local_pos[main_axis] if v[main_axis] >= dm_local_pos[main_axis] else dm_local_pos[main_axis]
	var f = taper_factor * (v[main_axis]- dm_local_pos[main_axis]) / h
	
	var sec_axis_pos = v[second_axis] + v[second_axis] * f
	if sign(sec_axis_pos) != sign(v[second_axis]): sec_axis_pos = 0
	var trd_axis_pos = v[dm_third_axis] + v[dm_third_axis] * f
	if sign(trd_axis_pos) != sign(v[dm_third_axis]): trd_axis_pos = 0
	
	v[second_axis] = sec_axis_pos
	v[dm_third_axis] = trd_axis_pos
	return v
