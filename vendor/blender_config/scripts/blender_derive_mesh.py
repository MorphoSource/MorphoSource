from os import path
from contextlib import redirect_stdout
from sys import argv
import argparse
import io
import bpy
import bpy_types

def file_name(filepath):
    return path.split(filepath)[1]

def dir_path(filepath):
    return path.split(filepath)[0]

def file_suffix(filepath):
    return path.splitext(file_name(filepath))[1]

def import_func_wrapper(func, filepath):
    func(filepath=filepath)

def import_mesh(filepath):
    import_func = {
        '.obj': bpy.ops.import_scene.obj,
        '.ply': bpy.ops.import_mesh.ply,
        '.stl': bpy.ops.import_mesh.stl,
        '.wrl': bpy.ops.import_scene.x3d,
        '.x3d': bpy.ops.import_scene.x3d,
        '.glb': bpy.ops.import_scene.gltf,
        '.gltf': bpy.ops.import_scene.gltf
    }

    stdout = io.StringIO()
    with redirect_stdout(stdout):
        import_func_wrapper(import_func[file_suffix(filepath)], filepath=filepath)
        stdout.seek(0)
        return stdout.read()

def get_scale_factor(unit):
    factors = {
        'mm': 0.001,
        'cm': 0.01,
        'm': 1.0,
        'km': 1000,
        'in': 0.025400050800102,
        'ft': 0.304785126485827,
        'mi': 1609.34
    }
    return factors[unit]

def clean_decimate_modifiers(obj):
    for m in obj.modifiers:
        if(m.type=="DECIMATE"):
            obj.modifiers.remove(modifier=m)

if "--" not in argv:
    argv = [] # as if no args are passed
else:
    argv = argv[argv.index("--") + 1:]
parser = argparse.ArgumentParser(description='Blender mesh file to GLB conversion tool')
parser.add_argument('-i', '--input', help='mesh file to be converted')
parser.add_argument('-o', '--output', help='output GLB file')
parser.add_argument('-u', '--unit', 
    help='Unit of input mesh file, one of mm, cm, m, km, in, ft, or mi')
args = parser.parse_args(argv)

target_faces = 100000

if (args.input and args.output and args.unit and 
    args.unit in ['mm','cm','m', 'km', 'in', 'ft', 'mi']):

    ifile = args.input
    ofile = args.output
    unit = args.unit

    err_msg = ''
    try: 
        bpy.ops.object.select_all(action='SELECT')
        bpy.ops.object.delete()
        if len(bpy.data.objects) == 0:
            stdout = import_mesh(ifile)
            if len(bpy.data.objects) != 0:
                for obj in bpy.data.objects:
                    if type(obj.data) == bpy_types.Mesh:
                        # Apply material (only works in Blender 2.8)
                        # if not obj.data.materials:
                        #     mat = bpy.data.materials.new(name="Material")
                        #     mat.use_nodes = True
                        #     obj.data.materials.append(mat)

                        bpy.context.scene.objects.active = obj

                        # Decimate mesh
                        if len(obj.data.polygons) > target_faces:
                            clean_decimate_modifiers(obj)
                            modifier = obj.modifiers.new('DecimateMod','DECIMATE')
                            modifier.ratio = target_faces/len(obj.data.polygons)
                            modifier.use_collapse_triangulate=True

                bpy.ops.object.convert(target='MESH')

                for obj in bpy.data.objects:
                    if type(obj.data) == bpy_types.Mesh:
                        # Rescale mesh coordinates
                        if unit != 'm':
                            sf = get_scale_factor(unit)
                            for v in obj.data.vertices:
                                v.co = v.co * sf
               
                bpy.ops.object.origin_set()
                bpy.ops.export_scene.gltf(filepath=ofile)
            else:
                # likely invalid file error, not an easy way to capture this from Blender
                err_msg = stdout.replace("\n", "; ")
        else:
            err_msg = 'Error deleting Blender scene objects'
    except Exception as e:
        err_msg = str(e).replace("\n", "; ")
else:
    err_msg = 'Command line arguments not supplied or inappropriate'

if err_msg:
    raise ValueError(err_msg)
else:
    print('Successfully converted')
