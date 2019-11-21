import argparse
from os import listdir
from os.path import basename, normpath, isfile, join, splitext
from sys import argv

from alembic import Alembic

def main(argv):
    if "--" not in argv:
        argv = [] # as if no args are passed
    else:
        argv = argv[argv.index("--") + 1:]

    parser = argparse.ArgumentParser(description='TIF directory to DCM conversion tool')
    parser.add_argument('-i', '--input', required=True, help='directory of TIF images to be converted')
    parser.add_argument('-o', '--output', required=True, help='directory to output DCM images')
    parser.add_argument('-n', '--assign_instance_numbers', default=True, help='Whether instance numbers should be assigned based on file name order')
    parser.add_argument('-x', '--x_pixel_spacing', default=1, help='X pixel spacing distance')
    parser.add_argument('-y', '--y_pixel_spacing', default=1, help='Y pixel spacing distance')
    parser.add_argument('-s', '--spacing_between_slices', default=0, help='Spacing distance between slices in Z direction')
    parser.add_argument('-t', '--slice_thickness', default=0, help='Slice Z direction thickness')
    args = parser.parse_args(argv)

    if args.spacing_between_slices == 0 and args.slice_thickness == 0:
        args.spacing_between_slices = 1

    input_list = [x for x in listdir(args.input) if isfile(join(args.input, x))]
    if args.assign_instance_numbers:
        input_list = sorted(input_list)

    for idx, f in enumerate(input_list):
        f_path = join(args.input, f)
        o_path = join(args.output, splitext(basename(f))[0]+'.dcm')
        alembic_args = {
            'x_pixel_spacing': args.x_pixel_spacing,
            'y_pixel_spacing': args.y_pixel_spacing,
            'spacing_between_slices': args.spacing_between_slices,
            'slice_thickness': args.slice_thickness
        }
        if args.assign_instance_numbers:
            alembic_args['instance_number'] = idx
        alembic = Alembic(**alembic_args)
        alembic.brew_dcm(f_path, o_path)

if __name__ == '__main__':
    main(argv)