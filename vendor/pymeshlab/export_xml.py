from importlib.metadata import PackageNotFoundError, version

import xml.etree.ElementTree as ET

def add_element_with_text(parent, element_name, element_value):
  if element_value is not None:
    element = ET.SubElement(parent, element_name)
    element.text = str(element_value)
    return element
  else:
    return None

def export_xml(data, status_msg, error_msg):
  try:
    pymeshlab_version = version('pymeshlab')
  except PackageNotFoundError:
    pymeshlab_version = "unknown"  

  root = ET.Element('blender', attrib={})
  status = ET.SubElement(root, 'status') # status can be displayed on UI
  status.text = status_msg
  error = ET.SubElement(root, 'error') # error should be shown internally only
  error.text = error_msg

  identification = ET.SubElement(root, 'identification')
  identity = ET.SubElement(identification, 'identity', attrib={"format": data['filesuffix'], "mimetype": data['mimetype']})
  tool = ET.SubElement(identity, 'tool')
  add_element_with_text(tool, 'pymeshlabVersion', pymeshlab_version)

  
  fileinfo = ET.SubElement(root, 'fileinfo')
  add_element_with_text(fileinfo, 'filepath', data['filepath'])
  add_element_with_text(fileinfo, 'filename', data['filename'])
  add_element_with_text(fileinfo, 'mimetype', data['mimetype'])
  
  meta = ET.SubElement(root, 'metadata')
  mesh = ET.SubElement(meta, 'mesh')

  add_element_with_text(mesh, 'pointCount', data['point_count'])
  add_element_with_text(mesh, 'faceCount', data['face_count'])

  bbd = ET.SubElement(mesh, 'boundingboxdimensions')
  add_element_with_text(bbd, 'boundingBoxX', data['bounding_box_dimensions']['bounding_box_x'])
  add_element_with_text(bbd, 'boundingBoxY', data['bounding_box_dimensions']['bounding_box_y'])
  add_element_with_text(bbd, 'boundingBoxZ', data['bounding_box_dimensions']['bounding_box_z'])

  cen = ET.SubElement(mesh, 'centroid')
  add_element_with_text(cen, 'centroidX', data['centroid']['centroid_x'])
  add_element_with_text(cen, 'centroidY', data['centroid']['centroid_y'])
  add_element_with_text(cen, 'centroidZ', data['centroid']['centroid_z'])
  add_element_with_text(cen, 'centroidMethod', data['centroid']['centroid_method'])

  add_element_with_text(mesh, 'hasUvSpace', data['has_uv_space'])
  add_element_with_text(mesh, 'vertexColor', data['vertex_color'])
  add_element_with_text(mesh, 'faceColor', data['face_color'])

  # Print XML to stdout, will be received by upstream tools
  print('<?xml version="1.0" encoding="UTF-8"?>')
  ET.dump(root) 

