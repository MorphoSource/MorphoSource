from pydicom.dataset import Dataset

class TemplateFileMeta(Dataset):
    """docstring for TemplateFileMeta"""
    def __init__(self):
        super(TemplateFileMeta, self).__init__()
        self.FileMetaInformationGroupLength = 196
        self.FileMetaInformationVersion = b'\x00\x01'
        self.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.7'
        self.MediaStorageSOPInstanceUID = '1.2.276.0.45.45.2.51.4.84320313.20190102.1151272840'
        self.TransferSyntaxUID = '1.2.840.10008.1.2.1'
        self.ImplementationClassUID = '1.2.276.0.7230010.3.0.3.6.4'
        self.ImplementationVersionName = 'OFFIS_DCMTK_364'