// Use this script to override jquery file upload options.  Add method can also be defined here
// console.log('in ms_upload');

$( document ).ready(function() {

    // This file is the default initialization of the fileupload.  If you want to call
    // hyraxUploader with other options (like afterSubmit), then override this file.
    Blacklight.onLoad(function() {
      var options = {
          maxNumberOfFiles:10,
          maxFileSize: 50000000000,
          acceptFileTypes: /(\.|\/)(zip|ply|stl|obj|x3d|glb|gltf|bin|wrl|png|gif|bmp|dcm|dicom|jpe?g|jpeg2000|tif?f|mtl|pdf|wmv|mov|avi|mpe?g|m4v)$/i
      };
      $('#fileupload').hyraxUploader(options);
      $('#fileuploadlogo').hyraxUploader({downloadTemplateId: 'logo-template-download'});
    });    

});