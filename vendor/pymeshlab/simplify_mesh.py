"""This script uses PyMeshLab to simplify an input mesh and produce an output mesh."""

import argparse
from sys import argv

import pymeshlab

def has_vertex_tex_coords(mesh):
    """Check if a mesh has vertex texture coords, since PyMeshLab throws an exception retrieving the vertex texture coords if they aren't present"""
    try:
        mesh.vertex_tex_coord_matrix()
        return True
    except:
        return False

def has_wedge_tex_coords(mesh):
    """Check if a mesh has wedge texture coords, since PyMeshLab throws an exception retrieving the vertex texture coords if they aren't present"""
    try:
        mesh.wedge_tex_coord_matrix()
        return True
    except:
        return False

def main(argv):
    """Main script logic"""

    # Set up input parameter arguments
    if "--" not in argv:
        argv = [] # as if no args are passed
    else:
        argv = argv[argv.index("--") + 1:]
    parser = argparse.ArgumentParser(description='Simplify mesh using PyMeshLab')
    parser.add_argument('-i', '--input', help='Input mesh')
    parser.add_argument('-o', '--output', help='Output mesh')
    parser.add_argument('-n', '--number_target_faces', default=0, help='Number of target faces for simplification')
    args = parser.parse_args(argv)

    # Set up mesh and related variables
    ms = pymeshlab.MeshSet()
    ms.load_new_mesh(args.input)
    mesh = ms.current_mesh()
    face_num = int(args.number_target_faces)

    # Should simplification be applied?
    if mesh.face_number() < face_num:
        print('Mesh has fewer faces than target number, returning original mesh')
        ms.save_current_mesh(args.output)
        return

    # Apply simplification
    if has_vertex_tex_coords(mesh) or has_wedge_tex_coords(mesh):
        filter_name = 'simplification_quadric_edge_collapse_decimation_with_texture'
    else:
        filter_name = 'simplification_quadric_edge_collapse_decimation'

    ms.apply_filter(filter_name, targetfacenum=face_num)

    # Save simplified mesh
    ms.save_current_mesh(args.output)

if __name__ == '__main__':
    main(argv)
