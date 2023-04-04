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

const DeformableMeshInstance3D = preload("dm_deformable_mesh.gd")

const DebugSphereMesh = preload("dm_debug_sphere_mesh.tres")

#---------------------------------------------------------------------------------------------------
# PUBLIC VARIABLES
#---------------------------------------------------------------------------------------------------
@export_category("Spherical Deformer")

## Array of DeformableMeshInstance3D nodes
## that are affected by this spherical deformer.
@export var deformables: Array[NodePath]:
	set(value):
		dm_clean_deformables()
		deformables = value
		dm_find_deformables()
		dm_update_deformables()

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

## Draws the deformer sphere (only visible in editor mode)
@export var show_debug_sphere: bool = true:
	set(value):
		show_debug_sphere = value
		mesh = DebugSphereMesh if value else null

#---------------------------------------------------------------------------------------------------
# PRIVATE VARIABLES
#---------------------------------------------------------------------------------------------------

var dm_deformable_nodes = [DeformableMeshInstance3D]

#---------------------------------------------------------------------------------------------------
# CALLBACKS
#---------------------------------------------------------------------------------------------------

func _on_user_changed_mesh():
	if(show_debug_sphere && mesh != DebugSphereMesh):
		mesh = DebugSphereMesh

#---------------------------------------------------------------------------------------------------
# VIRTUAL METHODS
#---------------------------------------------------------------------------------------------------

func _init():
	set_notify_transform(true)
	if(!self.visibility_changed.is_connected(dm_update_deformables)):
		self.visibility_changed.connect(dm_update_deformables)
	if(Engine.is_editor_hint()):
		if(!property_list_changed.is_connected(_on_user_changed_mesh)):
			property_list_changed.connect(_on_user_changed_mesh)
	dm_deformable_nodes.clear()

func _ready():
	dm_find_deformables()
	dm_update_deformables()
	if(Engine.is_editor_hint()):
		if(show_debug_sphere):
			mesh = DebugSphereMesh
			scale = Vector3(radius, radius, radius)
	else: 	show_debug_sphere = false

func _notification(what):
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			dm_update_deformables()

func _exit_tree():
	dm_clean_deformables()

#---------------------------------------------------------------------------------------------------
# PRIVATE METHODS
#---------------------------------------------------------------------------------------------------

func dm_clean_deformables():
	if(!is_inside_tree()): return
	for d in dm_deformable_nodes:
		d.notify_deformer_removed(self)
	dm_deformable_nodes.clear()

func dm_find_deformables():
	if(!is_inside_tree()): return
	dm_deformable_nodes.clear()
	for path in deformables:
		var n = get_node_or_null(path)
		if(!n): continue
		var d = n as DeformableMeshInstance3D
		if(d && !dm_deformable_nodes.has(d)):
			dm_deformable_nodes.push_back(d)
		else:
			deformables[deformables.find(path)] = NodePath()
			notify_property_list_changed()

func dm_update_deformables():   
	if(!is_inside_tree()): return
	for d in dm_deformable_nodes:
		d.notify_deformer_updated(self)
