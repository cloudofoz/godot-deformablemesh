# Copyright (C) 2024 Claudio Z. (cloudofoz)
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
@export_category("Drag Deformer")

## Radius of the sphere affecting the mesh deformation.
@export var radius: float = 1.5:
	set(value):
		radius = value
		dm_update_deformables()
		self.scale = Vector3(radius, radius, radius)

## Falloff of the deformation effect, decreasing with distance from the center.
@export_exp_easing("attenuation") var attenuation: float = 1.0:
	set(value):
		attenuation = value
		dm_update_deformables()

## Strength of the deformation effect.
@export_range(0, 2.0, 0.1, "or_greater") var strength: float = 1:
	set(value):
		strength = value
		dm_update_deformables()

## Toggle the Rest Pose Mode.
## Enables setting the deformer position at which there is no deformation.
## When disabled, deformation is calculated from the rest pose.
@export var rest_pose: bool = true:
	set(value):
		if value == rest_pose:
			return
		rest_pose = value
		if not rest_pose:
			dm_compute_rest_distances = true
			dm_update_deformables()
		# Move the deformer to its rest position
		elif is_instance_valid(dm_active_deformable):
			self.global_position = dm_active_deformable.to_global(dm_rest_pos)
	get:
		return rest_pose


#---------------------------------------------------------------------------------------------------
# PRIVATE VARIABLES
#---------------------------------------------------------------------------------------------------

var dm_delta_translation: Vector3

var dm_rest_pos: Vector3

var dm_rest_distances: PackedFloat32Array

var dm_active_deformable: DeformableMeshInstance3D

var dm_active_mesh: Mesh

var dm_compute_rest_distances: bool = false

var dm_vertex_index: int


#---------------------------------------------------------------------------------------------------
# PRIVATE METHODS
#---------------------------------------------------------------------------------------------------

func dm_needs_computation(d: DeformableMeshInstance3D) -> bool:
	# Check if the active deformable is different from the current one.
	if dm_active_deformable != d:
		# If the current deformer is associated with a different mesh, remove it.
		if dm_active_deformable != null and dm_active_deformable.deformers.find(self) != -1:
			d.deformers.remove_at(d.deformers.find(self))
			d.dm_find_deformers()
			push_warning("A DragDeformer can support only one mesh at a time.")
		return true
	
	# Check if the active mesh has changed.
	if dm_active_mesh != d.original_mesh:
		return true
	
	# Check if rest distances need initialization.
	if dm_rest_distances.is_empty():
		return true
	
	# No recomputation is needed.
	return false


#---------------------------------------------------------------------------------------------------
# VIRTUAL METHODS
#---------------------------------------------------------------------------------------------------

func _ready():
	dm_rest_pos = self.get_meta("dm_rest_pos", Vector3(0,0,0))
	super._ready()


func _on_end_update() -> void:
	# If the rest distances were computed during this frame, force a refresh.
	# This ensures the meshes are correctly deformed immediately after loading
	# a scene, avoiding the need to move the deformer to trigger the update.
	if dm_compute_rest_distances:
		dm_compute_rest_distances = false
		dm_update_deformables()


func _on_begin_update(d: DeformableMeshInstance3D) -> void:
	# When rest pose is active, only the rest position is stored,
	# and no deformation occurs.
	if rest_pose:
		dm_rest_pos = d.to_local(self.global_position)
		self.set_meta("dm_rest_pos", dm_rest_pos)
		return
		
	# Clear previous data if recomputation of distances is needed.
	if dm_compute_rest_distances or dm_needs_computation(d):
		dm_active_deformable = d
		dm_active_mesh = d.original_mesh
		dm_rest_distances.clear()
		dm_compute_rest_distances = true
		return
		
	# Otherwise, compute the deformation translation vector.
	dm_vertex_index = 0
	dm_delta_translation = d.to_local(self.global_position) - dm_rest_pos


func _on_update_vertex(v: Vector3) -> Vector3:
	# If in rest pose mode, return the vertex unchanged.
	if rest_pose:
		return v	

	# Compute and store rest distances if needed, without deforming the vertex.
	if dm_compute_rest_distances:
		var d = dm_rest_pos.distance_to(v)
		dm_rest_distances.push_back(d)
		return v

	# Retrieve the rest distance for the current vertex.
	var rest_distance = dm_rest_distances[dm_vertex_index]
	dm_vertex_index += 1

	var delta_radius = radius - rest_distance
	if delta_radius > 0.0:
		# Apply deformation using an eased interpolation factor.
		var t = strength * ease(delta_radius / radius, attenuation)
		v += dm_delta_translation * t
	
	return v
