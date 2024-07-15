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
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("SphericalDeformer", "MeshInstance3D", preload("dm_spherical_deformer.gd"), preload("dm_icon_spherical_deformer.svg"))
	add_custom_type("StandardDeformer", "MeshInstance3D", preload("dm_std_deformer.gd"), preload("dm_icon_std_deformer.svg"))
	add_custom_type("DeformableMeshInstance3D", "MeshInstance3D", preload("dm_deformable_mesh.gd"), preload("dm_icon_deformable_mesh.svg"))


func _exit_tree() -> void:
	remove_custom_type("SphericalDeformer")
	remove_custom_type("StandardDeformer")
	remove_custom_type("DeformableMeshInstance3D")
