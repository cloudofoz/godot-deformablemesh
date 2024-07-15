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
# PUBLIC VARIABLES
#---------------------------------------------------------------------------------------------------
@export_category("Spherical Deformer")

## Radius of the deformation sphere.
@export var radius: float = 1.5:
	set(value):
		radius = value
		dm_update_deformables()
		self.scale = Vector3(radius, radius, radius)

## Strength of the deformation.
@export var strength: float = 1.5:
	set(value):
		strength = value
		dm_update_deformables()

## Falloff of the deformation, based on distance from the center.
@export_exp_easing("attenuation") var attenuation: float = 1.0:
	set(value):
		attenuation = value
		dm_update_deformables()

#---------------------------------------------------------------------------------------------------
# PRIVATE VARIABLES
#---------------------------------------------------------------------------------------------------

var dm_deformable_local_pos: Vector3

#---------------------------------------------------------------------------------------------------
# VIRTUAL METHODS
#---------------------------------------------------------------------------------------------------

func _on_begin_update(d: DeformableMeshInstance3D) -> void:
	dm_deformable_local_pos = d.to_local(self.global_position)

func _on_update_vertex(v: Vector3) -> Vector3:
	var d = dm_deformable_local_pos.distance_to(v)
	var delta = radius - d
	if(delta <= 0): return v
	var k = strength * ease(delta / radius, attenuation)  
	var n = (dm_deformable_local_pos - v).normalized()
	v -= n * k
	return v
