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

Use the default deformers of **v0.2**:
- `SphericalDeformer`
- `BendDeformer`

or **easily create your owns** by extending the base class and overriding just a couple of methods (*a tutorial will be available*).

## Getting Started

1. Download the [repository](https://github.com/cloudofoz/godot-curvemesh/archive/refs/heads/main.zip](https://github.com/cloudofoz/godot-deformablemesh/archive/refs/heads/main.zip)) or download the stable addon from the AssetLib in Godot ([link](https://godotengine.org/asset-library/asset/1794)).
2. Import the **addons** folder into your project.
3. Activate `DeformableMesh` under * *Project > Project Settings > Plugins.* *

![](media/dm_getting_started_00.jpg)

4. (*further steps will be available soon*)

## Changelog

v0.20

- add: bend deformers
- add: base class to easily create custom deformers
- code refactoring and minor improvements

![v0.10](https://github.com/cloudofoz/godot-deformablemesh/tree/v0.1)

- first release

## License

[MIT License](/LICENSE.md)
