// Use this script to override jquery file upload options.  Add method can also be defined here
$( document ).ready(function() {
  uploadStatusOK = true;
  isAutoSave = false;
  // This file is the default initialization of the fileupload.  If you want to call
  // hyraxUploader with other options (like afterSubmit), then override this file.
  // Check if the file upload widget exists
  if ($('#fileupload').length) {
    var options = {
        maxNumberOfFiles:1,
        maxFileSize: 100000000000,
        acceptFileTypes: /(\.|\/)(zip|ply|stl|obj|x3d|glb|gltf|bin|wrl|png|gif|bmp|dcm|dicom|jpe?g|jpeg2000|svg|tif?f|mtl|pdf|wmv|mov|avi|mpe?g|m4v|dng|nef|crw|cr2|cr3|iiq|arw|raw|rw2)$/i
    };
    $('#fileupload').hyraxUploader(options);
    $('#fileuploadlogo').hyraxUploader({downloadTemplateId: 'logo-template-download'});

    // show / hide file upload buttons
    // currently the fileupload widget is on media edit page and submission flow
    $('#fileupload')
      .bind('fileuploadstart', function (e, data) {
        uploadStatusOK = false;
      })
      .bind('fileuploadcompleted', function (e, data) {
        console.log('fileuploadcompleted');
        $('.fileinput-button').hide();
        $('.dropzone').hide();
        uploadStatusOK = true;
        if (isAutoSave) {
          console.log('auto saving ...');          
          $.loader.close();
          $('.btn-save-media').trigger('click');
        }
      })
      /* .bind('fileuploadstop', function (e, data) {
        console.log('fileuploadstop');
        $('[id="file-upload-cancel-btn"]').hide();
        uploadStatusOK = true;
      }) */
      .bind('fileuploadfail', function (e, data) {
        console.log('fileuploadfail');
        $('[id="file-upload-cancel-btn"]').hide();
        uploadStatusOK = true;
      })
      .bind('fileuploaddestroyed', function (e, data) {
        console.log('fileuploaddestroyed');
        $('.fileinput-button').show();
        $('.dropzone').show();
        uploadStatusOK = true;
      });

  }

});