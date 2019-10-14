from pydicom.dataset import Dataset

class TemplateDicom(Dataset):
    """docstring for TemplateDicom"""
    def __init__(self):
        super(TemplateDicom, self).__init__()
        self.SpecificCharacterSet = 'ISO_IR 100'
        self.ImageType = 'DERIVED/SECONDARY'
        self.SOPClassUID = '1.2.840.10008.5.1.4.1.1.7'
        self.SOPInstanceUID = '1.2.276.0.45.45.2.51.4.84320313.20190102.1151272840'
        self.StudyDate = '20190102'
        self.SeriesDate = '20190102'
        self.ContentDate = '20190102'
        self.StudyTime = '104551'
        self.SeriesTime = '105127'
        self.ContentTime = '104711'
        self.AccessionNumber = '1'
        self.Modality = 'CT'
        self.ConversionType = 'SYN'
        self.ReferringPhysicianName = 'Julie Winchester'
        self.StudyDescription = 'Test Study'
        self.SeriesDescription = 'Test Series'
        self.PerformingPhysicianName = 'JMW'
        self.PatientName = 'MorphoSource Derivative'
        self.PatientID = '12345'
        self.PatientBirthDate = '20000102'
        self.SpacingBetweenSlices = "1"
        self.SecondaryCaptureDeviceManufacturer = 'Thermo Fisher Scientific'
        self.SecondaryCaptureDeviceSoftwareVersions = 'Avizo'
        self.StudyInstanceUID = '1.2.276.0.45.45.2.51.2.84320313.20190102.114711001'
        self.SeriesInstanceUID = '1.2.276.0.45.45.2.51.3.84320313.20190102.1151272839'
        self.StudyID = '12345'
        self.SeriesNumber = "1"
        self.InstanceNumber = "0"
        self.ImagePositionPatient = ['0', '0', '0']
        self.ImageOrientationPatient = ['1', '0', '0', '0', '1', '0']
        self.SamplesPerPixel = 1
        self.PhotometricInterpretation = 'MONOCHROME2'
        self.PixelRepresentation = 0
        self.WindowCenter = "125"
        self.WindowWidth = "250"
        self.RescaleIntercept = "0.0"
        self.RescaleSlope = "1.0"
        self.WindowCenterWidthExplanation = 'Standard'
        self.is_implicit_VR = False
        self.is_little_endian = True

    def set_pixel_data(self, pixel_data, bit_depth=16):
        if pixel_data.ndim == 2:
            self.PixelData = pixel_data.tobytes()
            self.set_pixel_dim_fields(1, pixel_data.shape[0], pixel_data.shape[1])
            self.set_bit_depth_fields(bit_depth)
        elif pixel_data.ndim == 3:
            self.PixelData = pixel_data.tobytes()
            self.set_pixel_dim_fields(pixel_data.shape[0], pixel_data.shape[1], pixel_data.shape[2])
            self.set_bit_depth_fields(bit_depth)

    def set_bit_depth_fields(self, bit_depth=16):
        self.BitsAllocated = bit_depth
        self.BitsStored = bit_depth
        self.HighBit = bit_depth - 1

    def set_pixel_dim_fields(self, number_of_frames, rows, columns):
        self.NumberOfFrames = number_of_frames
        self.Rows = rows
        self.Columns = columns

    def set_spacing_fields(self, x_pixel_spacing, y_pixel_spacing, spacing_between_slices, slice_thickness):
        self.PixelSpacing = [x_pixel_spacing, y_pixel_spacing]
        self.SpacingBetweenSlices = spacing_between_slices
        self.SliceThickness = slice_thickness