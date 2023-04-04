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
extends Object

#---------------------------------------------------------------------------------------------------
# CONSTANTS
#---------------------------------------------------------------------------------------------------

const SphericalDeformer = preload("dm_spherical_deformer.gd")

#---------------------------------------------------------------------------------------------------
# PRIVATE VARIABLES
#---------------------------------------------------------------------------------------------------

var dm_vpos: PackedVector3Array
var dm_mesh_data: MeshDataTool = null

#---------------------------------------------------------------------------------------------------
# PRIVATE METHODS
#---------------------------------------------------------------------------------------------------

func dm_store_vpos():
	assert(dm_mesh_data)
	var vcount = dm_mesh_data.get_vertex_count()
	dm_vpos.resize(vcount)
	for vidx in range(vcount):
		dm_vpos[vidx] = dm_mesh_data.get_vertex(vidx)

#---------------------------------------------------------------------------------------------------
# PUBLIC METHODS
#---------------------------------------------------------------------------------------------------

## Uses specified surface of given mesh to pupulate data of SurfaceData
func create_from_surface(mesh: Mesh, surface_index: int):
	assert(mesh && surface_index >= 0)
	if(!self.dm_mesh_data): self.dm_mesh_data = MeshDataTool.new()
	else: self.dm_mesh_data.clear()
	dm_mesh_data.create_from_surface(mesh, surface_index)
	dm_store_vpos()

## Generates an unmodified mesh
func init(): 
	assert(dm_mesh_data)
	var vcount = dm_vpos.size()
	for vidx in range(vcount):
		dm_mesh_data.set_vertex(vidx, dm_vpos[vidx])

## Generate a deformed mesh from an array of deformers and 
## their origins local to the deformable node.
func update_all(deformers: Array[SphericalDeformer], local_origins: PackedVector3Array) -> void:
	assert(dm_mesh_data)
	var vcount = dm_vpos.size()
	var dcount = deformers.size()
	for vidx in range(vcount):
		var v = dm_vpos[vidx]
		for didx in range(dcount):
			var local_origin = local_origins[didx]
			var deformer = deformers[didx]
			if(!deformer.visible): continue
			var d = local_origin.distance_to(v)
			var delta = deformer.radius - d
			if(delta <= 0): continue
			var k = deformer.strength * ease(delta / deformer.radius, deformer.attenuation)  
			var n = (local_origin - v).normalized()
			v -= n * k
		dm_mesh_data.set_vertex(vidx, v)

## Adds a new surface to a specified mesh with edited data
func commit_to_surface(mesh: ArrayMesh):
	assert(mesh)
	if(!dm_mesh_data): return
	dm_mesh_data.commit_to_surface(mesh)
