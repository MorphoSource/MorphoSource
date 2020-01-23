from __future__ import unicode_literals  # Only for python2.7 and save_as unicode filename

import argparse
from os.path import join
from sys import argv

import numpy as np
from PIL import Image

from template_dicom import TemplateDicom
from template_file_meta import TemplateFileMeta

class Alembic(object):
    """docstring for Alembic"""
    def __init__(self, instance_number, x_pixel_spacing, y_pixel_spacing, spacing_between_slices, slice_thickness, **kwargs):
        super(Alembic, self).__init__()
        self.instance_number = instance_number
        self.x_pixel_spacing = x_pixel_spacing
        self.y_pixel_spacing = y_pixel_spacing
        self.spacing_between_slices = spacing_between_slices
        self.slice_thickness = slice_thickness

        self.create_dataset()

    def create_dataset(self):
        self.ds = TemplateDicom()
        self.ds.file_meta = TemplateFileMeta()
        self.ds.InstanceNumber = self.instance_number
        self.ds.set_spacing_fields(self.x_pixel_spacing, self.y_pixel_spacing, self.spacing_between_slices, self.slice_thickness)

    def brew_dcm(self, input, output):
        try:
            im = Image.open(input)
            bit_depth = self.derive_bit_depth(im)
            pixel_data = np.asarray(im, dtype=self.dtype_var(bit_depth))
            self.ds.set_pixel_data(pixel_data, bit_depth)
        except Exception as e:
            raise ValueError('Error at image import: '+str(e))

        self.ds.save_as(output, write_like_original=False)
        print('Successfully converted')

    def brew_multi_dcm(self, input_list, output):
        pixel_data_list = []

        for idx, f in enumerate(input_list):
            #try:
            im = Image.open(f)
            bit_depth = self.derive_bit_depth(im)
            im_pix = np.asarray(im, dtype=self.dtype_var(bit_depth))
            pixel_data_list.append(im_pix)
            #except Exception as e:
                #raise ValueError('Error at image import: '+str(e))
        pixel_data = np.stack(pixel_data_list)
        self.ds.set_pixel_data(pixel_data, bit_depth)

        self.ds.save_as(output, write_like_original=False)
        print('Successfully converted')

    def dtype_var(self, bit_depth):
        if bit_depth == 8:
            dtype_var = 'uint8'
        elif bit_depth == 16:
            dtype_var = 'uint16'
        else:
            raise ValueError('Bit depth is neither 8 or 16 bits')

    def derive_bit_depth(self, image):
        mode_depth = {"1": 1, "L": 8, "P": 8, "RGB": 24, "RGBA": 32, "CMYK": 32,
            "YCbCr": 24, "LAB": 24, "HSV": 24, "I": 32, "F": 32, "I;16": 16,
            "I;16B": 16, "I;16L": 16, "I;16S": 16, "I;16BS": 16, "I;16LS": 16,
            "I;32": 32, "I;32B": 32, "I;32L": 32, "I;32S": 32, "I;32BS": 32,
            "I;32LS": 32}

        return mode_depth[image.mode]
 
def main(argv):
    if "--" not in argv:
        argv = [] # as if no args are passed
    else:
        argv = argv[argv.index("--") + 1:]
    parser = argparse.ArgumentParser(description='TIF to DCM conversion tool')
    parser.add_argument('-i', '--input', help='TIF image to be converted')
    parser.add_argument('-o', '--output', help='output DCM image')
    parser.add_argument('-n', '--instance_number', default=0, help='Instance number for slice')
    parser.add_argument('-x', '--x_pixel_spacing', default=1, help='X pixel spacing distance')
    parser.add_argument('-y', '--y_pixel_spacing', default=1, help='Y pixel spacing distance')
    parser.add_argument('-s', '--spacing_between_slices', default=0, help='Spacing distance between slices in Z direction')
    parser.add_argument('-t', '--slice_thickness', default=0, help='Slice Z direction thickness')
    args = parser.parse_args(argv)

    if args.spacing_between_slices == 0 and args.slice_thickness == 0:
        args.spacing_between_slices = 1

    alembic  = Alembic(**vars(args))
    alembic.brew_dcm(args.input, args.output)

if __name__ == '__main__':
    main(argv)