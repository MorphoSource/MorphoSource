// Use this script to override jquery file upload options.  Add method can also be defined here
$( document ).ready(function() {
  if (location.href.indexOf("remote-file-section") > -1) {
    fileOrigin = "remote";
  } else {
    fileOrigin = "local";
  }

  justUploaded = 0;
  uploadStatusOK = true;
  isAutoSave = false;
  skipNoFileCheck = false;
  // This file is the default initialization of the fileupload.  If you want to call
  // hyraxUploader with other options (like afterSubmit), then override this file.
  // Check if the file upload widget exists
  if ($('#fileupload').length) {
    var options = {
        maxNumberOfFiles:1,
        maxFileSize: 100000000000,
        acceptFileTypes: /(\.|\/)(zip|ply|stl|obj|x3d|glb|gltf|bin|wrl|png|gif|bmp|dcm|dicom|jpe?g|jpeg2000|svg|tif?f|mtl|pdf|wmv|mov|avi|mpe?g|m4v|mp4|dng|nef|crw|cr2|cr3|iiq|arw|raw|rw2)$/i
    };
    $('#fileupload').hyraxUploader(options);
    $('#fileuploadlogo').hyraxUploader({downloadTemplateId: 'logo-template-download'});

    // show / hide file upload buttons
    // currently the fileupload widget is on media edit page and submission flow
    $('#fileupload')
      .bind('fileuploadstart', function (e, data) {
        $('[id="add-files"]').hide();
        $('[id="add-cloud-files"]').hide();
        $('.dropzone').hide();
        $('[id="file-upload-cancel-btn"]').show();
        uploadStatusOK = false;
      })
      .bind('fileuploadcompleted', function (e, data) {
        console.log('fileuploadcompleted');
        $('[id="add-files"]').hide();
        $('[id="add-cloud-files"]').hide();
        $('.dropzone').hide();
        uploadStatusOK = true;
        justUploaded = 1;
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
        $('[id="add-files"]').show();
        $('[id="add-cloud-files"]').show();
        $('.dropzone').show();
        $('[id="file-upload-cancel-btn"]').hide();
        uploadStatusOK = true;
        justUploaded = 0;
      })
      .bind('fileuploaddestroyed', function (e, data) {
        console.log('fileuploaddestroyed');
        $('[id="add-files"]').show();
        $('[id="add-cloud-files"]').show();
        $('.dropzone').show();
        uploadStatusOK = true;
        justUploaded = 0;
      });

  }

});