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

## This base class is useful to create your own deformers for the deformable meshes.
##
## Basic usage: extend this class and override these two methods:
##
##        ## This method is called once before updating vertices.
##        ## It's useful if you want to capture some information from the mesh that is going to
##        ## to be modified. (for ex. the deformer position local to that istance)
##        func _on_begin_update(DeformableMeshInstance3D) -> void
##
##        ## This method is called for every vertex of the mesh. It takes the current vertex
##        ## position and returns the new vertex position
##        func _on_update_vertex(Vector3) -> Vector3
class_name DM_Deformer

#---------------------------------------------------------------------------------------------------
# CONSTANTS
#---------------------------------------------------------------------------------------------------

const DeformableMeshInstance3D = preload("dm_deformable_mesh.gd")

const DebugSphereMesh = preload("dm_debug_sphere_mesh.tres")

#---------------------------------------------------------------------------------------------------
# SIGNALS
#---------------------------------------------------------------------------------------------------

signal on_deformer_updated(deformer)

signal on_deformer_removed(deformer)

#---------------------------------------------------------------------------------------------------
# PUBLIC VARIABLES
#---------------------------------------------------------------------------------------------------
@export_category("Deformer")

## A debug mesh to show in the editor with this node
@export var debug_mesh: Mesh = DebugSphereMesh

## Draws the deformer mesh (only visible in editor mode)
@export var show_debug_mesh: bool = true:
	set(value):
		show_debug_mesh = value
		mesh = debug_mesh if value else null

#---------------------------------------------------------------------------------------------------
# CALLBACKS
#---------------------------------------------------------------------------------------------------

func _on_user_changed_mesh():
	if(show_debug_mesh && mesh != debug_mesh):
		mesh = debug_mesh

#---------------------------------------------------------------------------------------------------
# VIRTUAL METHODS
#---------------------------------------------------------------------------------------------------

## This method can be overrided to setup some initial parameters in the deformer
## It's called once before every deformable mesh update
func _on_begin_update(deformable: DeformableMeshInstance3D) -> void:
	pass

## This is the main method to override for every type of deformer.
## The default behaviour will leave the vertex unchanged.
## It's called for every vertex of the deformable mesh.
func _on_update_vertex(mesh_vertex: Vector3) -> Vector3:
	return mesh_vertex

func _init():
	set_notify_transform(true)	
	if(!self.visibility_changed.is_connected(dm_update_deformables)):
		self.visibility_changed.connect(dm_update_deformables)
	if(Engine.is_editor_hint()):
		if(!property_list_changed.is_connected(_on_user_changed_mesh)):
			property_list_changed.connect(_on_user_changed_mesh)

func _ready():
	if(Engine.is_editor_hint()):
		if(show_debug_mesh):
			mesh = debug_mesh
#			scale = Vector3(radius, radius, radius) #TODO: Fix
	else: 	show_debug_mesh = false
	dm_update_deformables()

func _notification(what):
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			dm_update_deformables()

func _exit_tree():
	on_deformer_removed.emit(self)

#---------------------------------------------------------------------------------------------------
# PRIVATE METHODS
#---------------------------------------------------------------------------------------------------

func dm_update_deformables():   
	if(!is_inside_tree()): return
	on_deformer_updated.emit(self)
