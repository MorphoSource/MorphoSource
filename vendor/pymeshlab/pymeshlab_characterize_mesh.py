from os import path
from sys import argv, exit

from export_xml import export_xml

import argparse
import pymeshlab
import re

def file_name(filepath):
  return path.split(filepath)[1]

def file_suffix(filepath):
  return path.splitext(file_name(filepath))[1].lower()

if "--" not in argv:
    argv = [] # as if no args are passed
else:
    argv = argv[argv.index("--") + 1:]
parser = argparse.ArgumentParser(description='PyMeshLab mesh characterizer tool')
parser.add_argument('-i', '--input', help='mesh file to be characterized', required=True)
args = parser.parse_args(argv)

mime_type = {
  '.gltf': 'model/gltf+json',
  '.glb': 'model/gltf+json',
  '.obj': 'text/prs.wavefront-obj',
  '.ply': 'application/ply',
  '.stl': 'application/stl',
  '.wrl': 'model/vrml',
  '.x3d': 'model/x3d+xml'
}

data = {
    'filepath': None,
    'filename': None,
    'file_suffix': None,
    'mimetype': None,
    'point_count': None,
    'face_count': None,
    'edges_count': None,
    'edges_per_face': None,
    'bounding_box_dimensions': {
      'bounding_box_x': None,
      'bounding_box_y': None,
      'bounding_box_z': None
    },
    'centroid': {
      'centroid_x': None,
      'centroid_y': None,
      'centroid_z': None,
      'centroid_method': None
    },
    'has_uv_space': None,
    'vertex_color': None,
    'face_color': None,
    'color_format': None
  }

status_msg = error_msg = ""

data['filepath'] = args.input

if not path.exists(data['filepath']):
  status_msg = error_msg = "There was a problem characterizing the file.  The file was not found."
  export_xml(data, status_msg, error_msg)
  exit()

data['filename'] = file_name(data['filepath'])
data['filesuffix'] = file_suffix(data['filepath'])

isMesh = re.match(r"^\.(gltf|glb|obj|ply|stl|wrl|x3d)$", data['filesuffix'])
if isMesh:
  data['mimetype'] = mime_type[data['filesuffix']]

if data['mimetype'] is None:
  loadSuccess = False
  status_msg = error_msg = "There was a problem characterizing the file.  The file was not found or not a mesh."
else:
  try:
    mesh_set = pymeshlab.MeshSet()
    mesh_set.load_new_mesh(data['filepath'])
    if mesh_set.mesh_number() > 0:
      loadSuccess = True
    else:
      loadSuccess = False
      status_msg = "There was a problem characterizing the file (Data object empty)."
      error_msg = "Mesh number in file is 0." 
  except Exception as e:
    loadSuccess = False # likely file not found error
    status_msg = "There was a problem characterizing the file (Exception)."
    error_msg = "Exception: " + str(e).replace("\n", "; ")

if loadSuccess == True:
  topologic_measures = mesh_set.get_topological_measures()
  geometric_measures = mesh_set.get_geometric_measures()

  data['point_count'] = topologic_measures.get('vertices_number')
  data['face_count'] = topologic_measures.get('faces_number')
  data['edges_count'] = topologic_measures.get('edges_number')
  # deprecating edges per face in this script compared to the blender version

  if geometric_measures.get('bbox'):
    bbox = geometric_measures.get('bbox')
    data['bounding_box_dimensions']['bounding_box_x'] = bbox.dim_x()
    data['bounding_box_dimensions']['bounding_box_y'] = bbox.dim_y()
    data['bounding_box_dimensions']['bounding_box_z'] = bbox.dim_z()
    bbox_center = bbox.center()
    if len(bbox_center) == 3:
      data['centroid']['centroid_x'] = bbox_center[0]
      data['centroid']['centroid_y'] = bbox_center[1]
      data['centroid']['centroid_z'] = bbox_center[2]
      data['centroid']['centroid_method'] = 'Bounding Box'

  meshes_have_uv_coords = []
  meshes_have_vertex_color = []
  meshes_have_face_color = []

  for i in range(mesh_set.mesh_number()):
    mesh = mesh_set.mesh(i)
    meshes_have_uv_coords.append(mesh.has_vertex_tex_coord() or mesh.has_wedge_tex_coord())
    meshes_have_vertex_color.append(mesh.has_vertex_color())
    meshes_have_face_color.append(mesh.has_face_color())
    
  data['has_uv_space'] = any(meshes_have_uv_coords)
  data['vertex_color'] = any(meshes_have_vertex_color)
  data['face_color'] = any(meshes_have_face_color)
  # deprecating color format in this script compared to the blender version

export_xml(data, status_msg, error_msg)
