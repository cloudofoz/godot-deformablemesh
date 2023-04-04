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
extends MeshInstance3D

#---------------------------------------------------------------------------------------------------
# CONSTANTS
#---------------------------------------------------------------------------------------------------

const SurfaceData = preload("dm_surface_data.gd")

const SphericalDeformer = preload("dm_spherical_deformer.gd")

#---------------------------------------------------------------------------------------------------
# PUBLIC VARIABLES
#---------------------------------------------------------------------------------------------------
@export_category("Deformable Mesh")

## Original mesh resource to be deformed
@export var original_mesh: Mesh = null:
	set(value):
		if(original_mesh):
			original_mesh.changed.disconnect(dm_init_surfaces)
		original_mesh = value
		if(!original_mesh): return
		original_mesh.changed.connect(dm_init_surfaces)
		dm_init_surfaces()

#---------------------------------------------------------------------------------------------------
# PRIVATE VARIABLES
#---------------------------------------------------------------------------------------------------

var dm_surfaces = [SurfaceData];
var dm_need_update: bool = false
var dm_deformers: Array[SphericalDeformer]
var dm_deformers_local_orgins: PackedVector3Array

#---------------------------------------------------------------------------------------------------
# VIRTUAL METHODS
#---------------------------------------------------------------------------------------------------

func _init():
	set_notify_transform(true)
	dm_deformers.clear()
	dm_deformers_local_orgins.clear()
	dm_need_update = true

func _process(_delta):
	if(dm_need_update):
		dm_update()
		dm_need_update = false

func _notification(what):
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			dm_update_deformer_origins()

#---------------------------------------------------------------------------------------------------
# PRIVATE METHODS
#---------------------------------------------------------------------------------------------------

func dm_init_surfaces():
	if(!original_mesh): return
	dm_surfaces.clear()
	mesh = ArrayMesh.new()
	if not(original_mesh is PrimitiveMesh):
		var surface_count = original_mesh.get_surface_count()
		for i in range(surface_count):
			var s = SurfaceData.new()
			s.create_from_surface(original_mesh, i)
			dm_surfaces.push_back(s)
	else:
		var temp_mesh = ArrayMesh.new()
		temp_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,original_mesh.get_mesh_arrays())
		var s = SurfaceData.new()
		s.create_from_surface(temp_mesh, 0)
		dm_surfaces.push_back(s)
	dm_update()

func dm_update():
	if(dm_surfaces.size() < 1): return
	if(!mesh): return
	mesh.clear_surfaces()
	for sidx in range(dm_surfaces.size()):
		var s = dm_surfaces[sidx] 
		if(!s): continue
		s.update_all(dm_deformers, dm_deformers_local_orgins)
		s.commit_to_surface(mesh)

func dm_update_deformer_origins():
	var dcount = dm_deformers.size()
	for i in range(dcount):
		dm_deformers_local_orgins[i] = self.to_local(dm_deformers[i].global_position)
	dm_need_update = true

#---------------------------------------------------------------------------------------------------
# PUBLIC METHODS
#---------------------------------------------------------------------------------------------------

func notify_deformer_updated(deformer: SphericalDeformer):
	var i = dm_deformers.find(deformer)
	var local_origin = self.to_local(deformer.global_position)
	if( i == -1 ):
		dm_deformers.push_back(deformer)
		dm_deformers_local_orgins.push_back(local_origin)
	else:
		dm_deformers_local_orgins[i] = local_origin
	dm_need_update = true

func notify_deformer_removed(deformer: SphericalDeformer):
	var i = dm_deformers.find(deformer)
	if(i == -1): return
	dm_deformers.remove_at(i)
	dm_deformers_local_orgins.remove_at(i)
	dm_need_update = true

#---------------------------------------------------------------------------------------------------
# KNOWN BUGS / LIMITATIONS
#---------------------------------------------------------------------------------------------------

#BUG: Error message when deleting node referenced through NodePath property or metadata #75168 
#	  https://github.com/godotengine/godot/issues/75168

#LIMITATION: A spherical deformer is currently only selectable from the scene tree
