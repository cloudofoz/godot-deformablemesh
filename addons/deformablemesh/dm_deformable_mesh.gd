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
extends MeshInstance3D

#---------------------------------------------------------------------------------------------------
# CONSTANTS
#---------------------------------------------------------------------------------------------------

const SurfaceData = preload("dm_surface_data.gd")

const Deformer = preload("dm_deformer.gd")

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

## Array of deformer node paths that affects this mesh.
@onready @export var deformers: Array[NodePath]:
	set(value):
		deformers = value
		dm_find_deformers()

#---------------------------------------------------------------------------------------------------
# PRIVATE VARIABLES
#---------------------------------------------------------------------------------------------------

var dm_surfaces = [SurfaceData];
var dm_need_update: bool = false
var dm_deformers: Array[Deformer]

#---------------------------------------------------------------------------------------------------
# VIRTUAL METHODS
#---------------------------------------------------------------------------------------------------

func _init():
	set_notify_transform(true)
	dm_clean_deformers()

func _ready():
	dm_find_deformers()

func _process(_delta):
	if(dm_need_update):
		dm_update()
		dm_need_update = false

func _notification(what):
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			dm_need_update = true
		NOTIFICATION_ENTER_WORLD:
			dm_find_deformers()

#---------------------------------------------------------------------------------------------------
# PRIVATE METHODS
#---------------------------------------------------------------------------------------------------

func dm_init_surfaces():
	if(!original_mesh): return
	mesh = ArrayMesh.new()
	var surface_count = original_mesh.get_surface_count()
	dm_surfaces.clear()
	for i in range(surface_count):
		var s = SurfaceData.new()
		s.create_from_surface(original_mesh, i)
		dm_surfaces.push_back(s)
	dm_update()

func dm_update():
	if(dm_surfaces.size() < 1): return
	if(!mesh): return
	mesh.clear_surfaces()
	for sidx in range(dm_surfaces.size()):
		var s = dm_surfaces[sidx] 
		if(!s): continue
		s.update_surface(dm_deformers, self)
		s.commit_to_surface(mesh)
		mesh.surface_set_material(sidx, original_mesh.surface_get_material(sidx))

func dm_clean_deformers():
	dm_deformers.clear()

func dm_add_deformer(deformer: Deformer) -> void:
	dm_deformers.push_back(deformer)
	if(!deformer.on_deformer_updated.is_connected(_on_deformer_updated)):
		deformer.on_deformer_updated.connect(_on_deformer_updated)
	if(!deformer.on_deformer_removed.is_connected(_on_deformer_removed)):
		deformer.on_deformer_removed.connect(_on_deformer_removed)

func dm_rem_deformer(deformer: Deformer) -> void:
	var didx = dm_deformers.find(deformer)
	if(didx > -1): dm_deformers.remove_at(didx)
	if(deformer.on_deformer_updated.is_connected(_on_deformer_updated)):
		deformer.on_deformer_updated.disconnect(_on_deformer_updated)
	if(deformer.on_deformer_removed.is_connected(_on_deformer_removed)):
		deformer.on_deformer_removed.disconnect(_on_deformer_removed)

func dm_find_deformers():
	if(!is_inside_tree()): return
	dm_clean_deformers()
	for path in deformers:
		var n = get_node_or_null(path)
		if(!n): continue
		var d = n as Deformer
		if(d && !dm_deformers.has(d)):
			dm_add_deformer(d)
		else:
			var didx = deformers.find(path)
			deformers[didx] = NodePath()
			notify_property_list_changed()
	dm_need_update = true

#---------------------------------------------------------------------------------------------------
# CALLBACKS
#---------------------------------------------------------------------------------------------------

func _on_deformer_updated(deformer: Deformer):
	var i = dm_deformers.find(deformer)
	if( i == -1 ): dm_add_deformer(deformer)
	dm_need_update = true

func _on_deformer_removed(deformer: Deformer):
	dm_rem_deformer(deformer)
	dm_need_update = true

#---------------------------------------------------------------------------------------------------
# KNOWN BUGS / LIMITATIONS
#---------------------------------------------------------------------------------------------------

#BUG:        Error message when deleting node referenced through NodePath property or metadata #75168 
#	         https://github.com/godotengine/godot/issues/75168
#LIMITATION: A deformer is currently only selectable from the scene tree
#LIMITATION: A deformable mesh is currently limited by one UV set
