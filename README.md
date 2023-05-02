![Version](https://img.shields.io/badge/Godot-v4.0.2%20stable-informational) ![License](https://img.shields.io/github/license/cloudofoz/godot-deformablemesh)

<img src="addons/deformablemesh/dm_icon_deformable_mesh.svg" width="64" align="left"/>

## godot-deformablemesh
**This addon allows to deform 3D meshes using customizable deformers at run-time**

<br clear="left" />

<p align="center">
  <img src="media/dm_screen_1.gif" width="320" />
  <img src="media/dm_screen_3.gif" width="320" />
  <img src="media/dm_screen_2.gif" width="320" />
</p>

## Main features

Use the default deformers:
- `SphericalDeformer` <img src="addons/deformablemesh/dm_icon_spherical_deformer.svg" width="20"/>
- `BendDeformer` <img src="addons/deformablemesh/dm_icon_bend_deformer.svg" width="20"/>

or **easily create your owns** by extending the base class and overriding just a couple of methods (*a tutorial will be available*).

## Getting Started

1. Download the [repository](https://github.com/cloudofoz/godot-curvemesh/archive/refs/heads/main.zip](https://github.com/cloudofoz/godot-deformablemesh/archive/refs/heads/main.zip)) or download the stable addon from the AssetLib in Godot ([link](https://godotengine.org/asset-library/asset/1794)).

2. Import the **addons** folder into your project.

3. Activate `DeformableMesh` under *Project > Project Settings > Plugins.*

<p align="center">
  <img src="media/dm_getting_started_00.jpg" />
</p>

4. Add a *deformer* node to the scene.

<p align="center">
  <img src="media/dm_getting_started_01.jpg" />
</p>

5. Add a `DeformableMeshInstance3D` node to the scene.

<p align="center">
  <img src="media/dm_getting_started_02.jpg" />
</p>

6. Set the *mesh resource* you want to deform in the **Original Mesh** property.

<p align="center">
  <img src="media/dm_getting_started_03.jpg" />
</p>

7. Link the *deformer node* you created before to the list of **Deformers** that will affect this mesh in the property panel.

<p align="center">
  <img src="media/dm_getting_started_04.jpg" />
</p>

7. Tweak the *deformer* properties to achieve the desired result.

<p align="center">
  <img src="media/dm_getting_started_05.jpg" />
</p>

## Changelog

v0.20

- add: bend deformers
- add: base class to easily create custom deformers
- code refactoring and minor improvements

[v0.10](https://github.com/cloudofoz/godot-deformablemesh/tree/v0.1)

- first release

## License

[MIT License](/LICENSE.md)
