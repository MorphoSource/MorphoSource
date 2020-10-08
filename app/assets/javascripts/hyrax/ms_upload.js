// Use this script to override jquery file upload options.  Add method can also be defined here
$( document ).ready(function() {
  // This file is the default initialization of the fileupload.  If you want to call
  // hyraxUploader with other options (like afterSubmit), then override this file.
  // Check if the file upload widget exists
  if ($('#fileupload').length) {
    var options = {
        maxNumberOfFiles:1,
        maxFileSize: 50000000000,
        acceptFileTypes: /(\.|\/)(zip|ply|stl|obj|x3d|glb|gltf|bin|wrl|png|gif|bmp|dcm|dicom|jpe?g|jpeg2000|tif?f|mtl|pdf|wmv|mov|avi|mpe?g|m4v|dng|nef|crw|cr2|cr3|iiq|arw|raw|rw2)$/i
    };
    $('#fileupload').hyraxUploader(options);
    $('#fileuploadlogo').hyraxUploader({downloadTemplateId: 'logo-template-download'});
  }

});