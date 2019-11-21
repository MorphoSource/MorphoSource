import argparse
from os import listdir
from os.path import basename, normpath, isfile, join, splitext
from sys import argv

from alembic import Alembic

def acceptable_file_formats():
    return ['.tif', '.tiff', '.dcm', '.dicom', '.1', '.bmp', '.png', '.jpg', '.jpeg']

def is_acceptable_file(f):
    if splitext(basename(f))[1].lower() in acceptable_file_formats():
        return True
    else:
        return False

def derive_input_list(l):
    return sorted([join(l, x) for x in listdir(l) if isfile(join(l, x)) and is_acceptable_file(x)])

def main(argv):
    if "--" not in argv:
        argv = [] # as if no args are passed
    else:
        argv = argv[argv.index("--") + 1:]

    parser = argparse.ArgumentParser(description='TIF directory to multi-frame DCM conversion tool')
    parser.add_argument('-i', '--input', required=True, help='directory of TIF images to be converted')
    parser.add_argument('-o', '--output', required=True, help='DCM output file name')
    parser.add_argument('-x', '--x_pixel_spacing', default=1, help='X pixel spacing distance')
    parser.add_argument('-y', '--y_pixel_spacing', default=1, help='Y pixel spacing distance')
    parser.add_argument('-s', '--spacing_between_slices', default=0, help='Spacing distance between slices in Z direction')
    parser.add_argument('-t', '--slice_thickness', default=0, help='Slice Z direction thickness')
    args = parser.parse_args(argv)

    args.instance_number = 0
    if args.spacing_between_slices == 0 and args.slice_thickness == 0:
        args.spacing_between_slices = 1

    input_list = derive_input_list(args.input)
    
    alembic = Alembic(**vars(args))
    alembic.brew_multi_dcm(input_list, args.output)

if __name__ == '__main__':
    main(argv)