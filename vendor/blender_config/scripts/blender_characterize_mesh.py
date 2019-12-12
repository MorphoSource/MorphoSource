import bpy
import re
import xml.etree.ElementTree as ET

from os import path
from statistics import mean
from sys import argv

import io
from contextlib import redirect_stdout

def dump(obj):
  for attr in dir(obj):
    if hasattr( obj, attr ):
      print( "obj.%s = %s" % (attr, getattr(obj, attr)))

def file_name(filepath):
  return path.split(filepath)[1]

def file_suffix(filepath):
  return path.splitext(file_name(filepath))[1].lower()

def mesh_import_wrapper(func, filepath):
  func(filepath=filepath)

def mesh_import(filepath):
  import_func = {
    '.obj': bpy.ops.import_scene.obj,
    '.ply': bpy.ops.import_mesh.ply,
    '.stl': bpy.ops.import_mesh.stl, 
    '.wrl': bpy.ops.import_scene.x3d,
    '.x3d': bpy.ops.import_scene.x3d,
    '.gltf': bpy.ops.import_scene.gltf
    # todo: gltf is not working yet.  It works for Blender 2.8 beta, but x3d imports failed using 2.8 beta.
    # will try again when blender 2.8 stable release is ready
  }

  stdout = io.StringIO()
  with redirect_stdout(stdout):
    mesh_import_wrapper(import_func[file_suffix(filepath)], filepath=filepath)
    stdout.seek(0) 
    return stdout.read()

mime_type = {
  '.gltf': 'model/gltf+json',
  '.obj': 'text/prs.wavefront-obj',
  '.ply': 'application/ply',
  '.stl': 'application/stl',
  '.wrl': 'model/vrml',
  '.x3d': 'model/x3d+xml'
}

filepath = argv[-1]
filename = path.split(filepath)[1]

isMesh = re.match('^\.(gltf|obj|ply|stl|wrl|x3d)$', file_suffix(filepath))
if isMesh:
  mimetype = mime_type[file_suffix(filepath)]
else:
  mimetype = ''

print('<?xml version="1.0" encoding="UTF-8"?>')
blender = ET.Element('blender', attrib={})
status = ET.SubElement(blender, 'status') # status can be displayed on UI
error = ET.SubElement(blender, 'error') # error should be shown internally only
statusMessage = errorMessage = ""

if mimetype == '':
  # for non mesh files, just return an empty xml with error message
  statusMessage = errorMessage = "There was a problem characterizing the file.  The file was not found or not a mesh."
else:
  try:
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    output = mesh_import(filepath)
    #print('len(bpy.data.objects)='+str(len(bpy.data.objects)))
    if len(bpy.data.objects) > 0: # x3d returns 2 objects, others return 1
      loadSuccess = True
    else:
      loadSuccess = False
      statusMessage = "There was a problem characterizing the file (Data object empty)."
      errorMessage = "Data.objects count is 0. " + output.replace("\n", "; ")
  except Exception as e:
    loadSuccess = False # likely file not found error
    statusMessage = "There was a problem characterizing the file (Exception)."
    errorMessage = "Exception: " + str(e).replace("\n", "; ")

  if loadSuccess == True:
    mesh_object = bpy.data.objects[0]
    mesh = mesh_object.data
    #dump(mesh)
    #exit()
    
    point_count = len(mesh.vertices)
    #print('vertices >>> ' + str(mesh.vertices))
    face_count = len(mesh.polygons)

    # derive edges per face
    edges_list = [len(p.vertices) for p in mesh.polygons]
    edge_num_set = set(edges_list)
    if len(edge_num_set) != 1:
      loadSuccess = False 
    else:
      edges_per_face = next(iter(edge_num_set))

    x_points = []
    y_points = []
    z_points = []

    for v in mesh.vertices:
      co = v.co
      x_points.append(co[0])
      y_points.append(co[1])
      z_points.append(co[2])

    # derive bounding box dimensions
    bounding_box_x = str(max(x_points) - min(x_points))
    bounding_box_y = str(max(y_points) - min(y_points))
    bounding_box_z = str(max(z_points) - min(z_points))

    # derive centroid info
    centroid_x = str(mean(x_points))
    centroid_y = str(mean(y_points))
    centroid_z = str(mean(z_points))

    # UV
    has_uv_space = False
    if hasattr(mesh, 'uv_textures'):
      if len(mesh.uv_textures) > 0:
        has_uv_space = True

    # Color
    vertex_color = False
    color_format = ""
    if hasattr(mesh, 'vertex_colors'):
      if len(mesh.vertex_colors) > 0:
        vertex_color = True
        color_format = "vertex color"

    identification = ET.SubElement(blender, 'identification')
    identity = ET.SubElement(identification, 'identity', attrib={"format":file_suffix(filepath)[1:], "mimetype":mimetype})
    fileinfo = ET.SubElement(blender, 'fileinfo')
    e = ET.SubElement(fileinfo, 'filepath')
    e.text = str(filepath)
    e = ET.SubElement(fileinfo, 'filename')
    e.text = str(filename)
    e = ET.SubElement(fileinfo, 'mimetype')
    e.text = str(mimetype)
    meta = ET.SubElement(blender, 'metadata')
    mesh = ET.SubElement(meta, 'mesh')
    e = ET.SubElement(mesh, 'pointCount')
    e.text = str(point_count)
    e = ET.SubElement(mesh, 'faceCount')
    e.text = str(face_count)  
    e = ET.SubElement(mesh, 'edgesPerFace')
    e.text = str(edges_per_face)  
    bbd = ET.SubElement(mesh, 'boundingboxdimensions')
    e = ET.SubElement(bbd, 'boundingBoxX')
    e.text = str(bounding_box_x)  
    e = ET.SubElement(bbd, 'boundingBoxY')
    e.text = str(bounding_box_y)
    e = ET.SubElement(bbd, 'boundingBoxZ')
    e.text = str(bounding_box_z)  
    cen = ET.SubElement(mesh, 'centroid')
    e = ET.SubElement(cen, 'centroidX')
    e.text = str(centroid_x)  
    e = ET.SubElement(cen, 'centroidY')
    e.text = str(centroid_y)
    e = ET.SubElement(cen, 'centroidZ')
    e.text = str(centroid_z)  
    e = ET.SubElement(mesh, 'hasUvSpace')
    e.text = str(has_uv_space)
    e = ET.SubElement(mesh, 'vertexColor')
    e.text = str(vertex_color)
    e = ET.SubElement(mesh, 'colorFormat')
    e.text = str(color_format)
    # todo: Not sure what to do with normals format yet.  Remove later if not needed 
    e = ET.SubElement(mesh, 'normalsFormat')
    e.text = str('')

  # end if loadSuccess == True

# end else (mimetype is not empty)
status.text = statusMessage
error.text = errorMessage
ET.dump(blender) 
