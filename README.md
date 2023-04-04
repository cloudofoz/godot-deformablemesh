![Version](https://img.shields.io/badge/Godot-v4.0.1-informational) ![License](https://img.shields.io/github/license/cloudofoz/godot-deformablemesh)

<img src="addons/deformablemesh/dm_icon_deformable_mesh.svg" width="64" align="left"/>

## godot-deformablemesh
**This addon allows to deform 3D meshes using customizable deformers at run-time. In this version SphericalDeformer nodes are provided.**

<br clear="left" />

<p align="center">
  <img src="media/dm_screen_1.gif" width="320" />
  <img src="media/dm_screen_3.gif" width="320" />
  <img src="media/dm_screen_2.gif" width="320" />
</p>

## Getting Started

1. Download the [repository]([https://github.com/cloudofoz/godot-curvemesh/archive/refs/heads/main.zip](https://github.com/cloudofoz/godot-deformablemesh/archive/refs/heads/main.zip)) ~~or download the (stable) addon from the AssetLib in Godot~~ ( *not yet* ).
2. Import the **addons** folder into your project.
3. Activate `DeformableMesh` under * *Project > Project Settings > Plugins.* *

![](media/dm_getting_started_00.jpg)

4. Add a `DeformableMeshInstance3D` node to the scene.

![](media/dm_getting_started_01.jpg)

5. Add the mesh resource you want to deform in the `Original Mesh` property.

![](media/dm_getting_started_02.jpg)

6. Add a `SphericalDeformer` node to the scene.

![](media/dm_getting_started_03.jpg)

7. Add the `DeformableMeshInstance3D` node you created before in the `Deformables` property.

![](media/dm_getting_started_04.jpg)

8. Tweak the `SphericalDeformer` parameters to adjust the deformation

![](media/dm_getting_started_05.jpg)

## Changelog

v0.10

- first release

## License

[MIT License](/LICENSE.md)
