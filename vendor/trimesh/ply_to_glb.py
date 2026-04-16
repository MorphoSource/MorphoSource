#!/usr/bin/env python3
# Convert a PLY mesh to GLB using trimesh, applying sRGB->linear vertex color
# conversion when the PLY has uchar (0-255) color properties.
#
# Trimesh exports FLOAT vertex colors to GLB by dividing uint8 by 255 without
# gamma-correcting. GLTF FLOAT vertex colors are expected to be linear, so this
# script converts uchar sRGB colors to linear uint8 before handing off to
# trimesh's exporter, resulting in correct linear float values in the GLB.

from sys import argv
import argparse
import numpy as np

COLOR_PROP_NAMES = {'red', 'green', 'blue', 'r', 'g', 'b'}
UCHAR_TYPES = {'uchar', 'uint8'}


def ply_has_uchar_colors(ply_path):
    """
    Read the PLY text header (always ASCII, even in binary PLYs) and return
    True only if vertex color properties are present and all typed as uchar/uint8.
    Returns False if no color properties exist, or if any are a non-uchar type.
    """
    found_uchar = False
    found_non_uchar = False
    in_vertex = False

    with open(ply_path, 'rb') as f:
        for _ in range(500):
            raw = f.readline()
            if not raw:
                break
            line = raw.decode('ascii', errors='replace').strip()
            if line == 'end_header':
                break
            parts = line.split()
            if not parts:
                continue
            if parts[0] == 'element':
                in_vertex = len(parts) > 1 and parts[1] == 'vertex'
            elif in_vertex and parts[0] == 'property' and len(parts) >= 3:
                prop_type = parts[1]
                prop_name = parts[-1].lower()
                if prop_name in COLOR_PROP_NAMES:
                    if prop_type in UCHAR_TYPES:
                        found_uchar = True
                    else:
                        found_non_uchar = True

    return found_uchar and not found_non_uchar


def srgb_uint8_to_linear_uint8(colors_uint8):
    """
    Convert sRGB uint8 RGBA vertex colors to linear uint8.
    Applies the IEC 61966-2-1 sRGB transfer function to RGB channels only;
    alpha is left unchanged (it is an opacity value, not a color channel).
    """
    result = colors_uint8.copy()
    rgb = result[:, :3].astype(np.float32) / 255.0
    linear = np.where(
        rgb <= 0.04045,
        rgb / 12.92,
        ((rgb + 0.055) / 1.055) ** 2.4
    )
    result[:, :3] = np.clip(linear * 255.0, 0, 255).round().astype(np.uint8)
    return result


def apply_color_correction(mesh, ply_path):
    """Apply sRGB->linear conversion to vertex colors if the PLY used uchar colors."""
    import trimesh.visual.color as tvc

    if not isinstance(mesh.visual, tvc.ColorVisuals):
        return
    colors = mesh.visual.vertex_colors
    if colors is None or len(colors) == 0:
        return
    mesh.visual.vertex_colors = srgb_uint8_to_linear_uint8(colors)


def apply_color_correction_to_pointcloud(cloud, ply_path):
    """Apply sRGB->linear conversion to PointCloud vertex colors if the PLY used uchar colors."""
    if cloud.colors is None or len(cloud.colors) == 0:
        return
    cloud.colors = srgb_uint8_to_linear_uint8(cloud.colors)


def convert(ply_path, glb_path):
    import trimesh

    mesh = trimesh.load(ply_path, process=False)
    correct_colors = ply_has_uchar_colors(ply_path)

    if isinstance(mesh, trimesh.Scene):
        if correct_colors:
            for geom in mesh.geometry.values():
                if isinstance(geom, trimesh.Trimesh):
                    apply_color_correction(geom, ply_path)
                elif isinstance(geom, trimesh.points.PointCloud):
                    apply_color_correction_to_pointcloud(geom, ply_path)
        mesh.export(glb_path)
    elif isinstance(mesh, trimesh.Trimesh):
        if correct_colors:
            apply_color_correction(mesh, ply_path)
        trimesh.Scene(geometry={'mesh': mesh}).export(glb_path)
    elif isinstance(mesh, trimesh.points.PointCloud):
        if correct_colors:
            apply_color_correction_to_pointcloud(mesh, ply_path)
        trimesh.Scene(geometry={'pointcloud': mesh}).export(glb_path)
    else:
        raise ValueError(f"Unsupported trimesh type for PLY input: {type(mesh)}")


def main():
    if "--" not in argv:
        args_list = []
    else:
        args_list = argv[argv.index("--") + 1:]

    parser = argparse.ArgumentParser(
        description='Convert PLY to GLB via trimesh with sRGB->linear vertex color correction.'
    )
    parser.add_argument('-i', '--input', required=True, help='Input PLY file path')
    parser.add_argument('-o', '--output', required=True, help='Output GLB file path')
    args = parser.parse_args(args_list)

    convert(args.input, args.output)
    print(f"Exported {args.input} -> {args.output}")


if __name__ == '__main__':
    main()
