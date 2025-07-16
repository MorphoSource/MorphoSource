# convert mesh files to obj format

from os import path
from sys import argv, exit

from export_xml import export_xml

import argparse
import pymeshlab
import re

if "--" not in argv:
  argv = [] # as if no args are passed
else:
  argv = argv[argv.index("--") + 1:]
parser = argparse.ArgumentParser(description='PyMeshLab mesh to OBJ converter tool')
parser.add_argument('-i', '--input', help='mesh file to be converted', required=True)
parser.add_argument('-o', '--output', help='output destination obj file', required=True)
args = parser.parse_args(argv)

input_path = args.input
output_path = args.output

mesh_set = pymeshlab.MeshSet()
mesh_set.load_new_mesh(input_path)
mesh_set.save_current_mesh(output_path)