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
extends Object

#---------------------------------------------------------------------------------------------------
# CONSTANTS
#---------------------------------------------------------------------------------------------------

const Deformer = preload("dm_deformer.gd")

const DeformableMeshInstance3D = preload("dm_deformable_mesh.gd")

#---------------------------------------------------------------------------------------------------
# PRIVATE VARIABLES
#---------------------------------------------------------------------------------------------------

var dm_vpos: PackedVector3Array
var dm_uvcoords: PackedVector2Array
var dm_indices: PackedInt32Array
var dm_st: SurfaceTool = null

#---------------------------------------------------------------------------------------------------
# PRIVATE METHODS
#---------------------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------------------
# PUBLIC METHODS
#---------------------------------------------------------------------------------------------------

## Uses specified surface of given mesh to pupulate data of SurfaceData
func create_from_surface(mesh: Mesh, surface_index: int):
	assert(mesh && surface_index >= 0)
	if(!self.dm_st): self.dm_st = SurfaceTool.new()
	else: self.dm_mesh_data.clear()
	var dm_arrays = mesh.surface_get_arrays(surface_index)
	dm_vpos = dm_arrays[Mesh.ARRAY_VERTEX]
	dm_indices = dm_arrays[Mesh.ARRAY_INDEX]
	dm_uvcoords = dm_arrays[Mesh.ARRAY_TEX_UV]

## Generate a deformed mesh surface from an array of deformers
func update_surface(deformers: Array[Deformer], deformable: DeformableMeshInstance3D) -> void:
	assert(dm_st)
	for deformer in deformers:
		deformer._on_begin_update(deformable)
	var vcount = dm_vpos.size()
	var icount = dm_indices.size()
	dm_st.clear()
	dm_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for vidx in range(vcount):
		var v = dm_vpos[vidx]
		for deformer in deformers:
			if(!deformer.visible): continue
			v = deformer._on_update_vertex(v)
		dm_st.set_uv(dm_uvcoords[vidx])
		dm_st.add_vertex(v)
	for idx in range(icount):
		dm_st.add_index(dm_indices[idx])

## Adds a new surface to a specified mesh with edited data
func commit_to_surface(mesh: ArrayMesh):
	assert(mesh && dm_st)
	dm_st.generate_normals()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, dm_st.commit_to_arrays())
