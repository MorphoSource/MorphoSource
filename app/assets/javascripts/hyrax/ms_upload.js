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
    $('#fileupload').on('click', 'button.resume-file-upload', function (e) {
      e.preventDefault();

      let that = this;
      // Only initiate resume if can connect to server, otherwise do nothing
      $.getJSON(
        '/uploads', 
        {
          file: $("#fileupload").find("input#upload-hash").val(),
          upload_hash: $("#fileupload").find("input#upload-hash").val()
        },
        function () {
          $("#resume-add-files").addClass('ready-for-resume');
          // delete file entry, trigger fileuploaddestroyed, do resume there
          $(that).parent().children('button.delete').trigger('click');
        }
      );
    });

    var options = {
      maxChunkSize: 50000000,
      maxFileSize: 100000000000,
      maxNumberOfFiles: 1,
      maxRetries: 5,
      retryTimeout: 500,
      acceptFileTypes: /(\.|\/)(zip|tar|ply|stl|obj|x3d|glb|gltf|bin|wrl|png|gif|bmp|dcm|dicom|jpe?g|jpeg2000|svg|tif?f|mtl|pdf|wmv|mov|avi|mpe?g|m4v|mp4|dng|nef|crw|cr2|cr3|iiq|arw|raw|rw2)$/i,
      add: function (e, data) {
        let add_files_async = function(that, e, data) {
          $.getJSON(
            '/uploads', 
            {
              file: data.files[0].name,
              upload_hash: $("#fileupload").find("input#upload-hash").val()
            },
            function (result) {
              if (result.size && result.size < data.files[0].size) {
                data.uploadedBytes = result.size;
              }
              $.blueimp.fileupload.prototype
              .options.add.call(that, e, data);
            }
          );
        }
        
        let that = this;

        // Create event for triggering this dynamically
        $("#resume-add-files").off('click').on('click', function () {
          add_files_async(that, e, data);
        });

        // Default behavior
        add_files_async(that, e, data)
      },
      fail: function (e, data) {
        var fu = $(this).data('blueimp-fileupload') || $(this).data('fileupload');
        retries = data.context.data('retries') || 0;
        retry = function () {
          $.getJSON(
            '/uploads', 
            {
              file: data.files[0].name,
              upload_hash: $("#fileupload").find("input#upload-hash").val()
            }
          ).done(function (result) {
            if (result.size && result.size < data.files[0].size) {
              data.uploadedBytes = result.size;
              data.data = null;
              data.submit();
            } else {
              fu._trigger('fail', e, data);
            }
          }).fail(function () {
              fu._trigger('fail', e, data);
          });
        };

        if (
          data.errorThrown !== 'abort' &&
          data.uploadedBytes < data.files[0].size &&
          retries < fu.options.maxRetries
        ) {
          retries += 1;
          data.context.data('retries', retries);
          window.setTimeout(retry, retries * fu.options.retryTimeout);
          return;
        }
        data.context.removeData('retries');
        $.blueimp.fileupload.prototype.options.fail.call(this, e, data);
      }
    };
    $('#fileupload').hyraxUploader(options);
    $('#fileuploadlogo').hyraxUploader({downloadTemplateId: 'logo-template-download'});

    // show / hide file upload buttons
    // currently the fileupload widget is on media edit page and submission flow
    $('#fileupload')
      .bind('fileuploadstart', function (e, data) {
        $('[id="add-files"]').hide();
        $('[id="add-cloud-files"]').hide();
        $('.fileupload-progress').show();
        $('.dropzone').hide();
        uploadStatusOK = false;
      })
      .bind('fileuploadcompleted', function (e, data) {
        console.log('fileuploadcompleted');
        $('[id="add-files"]').hide();
        $('[id="add-cloud-files"]').hide();
        $('.fileupload-progress').hide();
        $('.dropzone').hide();
        uploadStatusOK = true;
        justUploaded = 1;
        if (isAutoSave) {
          console.log('auto saving ...');          
          $.loader.close();
          $('.btn-save-media').trigger('click');
        }
      })
      .bind('fileuploadfail', function (e, data) {
        console.log('fileuploadfail');
        if (data.errorThrown == 'abort') {
          // user cancel, enable re-upload of new file
          $('[id="add-files"]').show();
          $('[id="add-cloud-files"]').show();
          $('.dropzone').show();
        } else {
          // download failure, user must resume or delete download to re-upload new file
          $('[id="add-files"]').hide();
          $('[id="add-cloud-files"]').hide();
          $('.dropzone').hide();
        }
        
        $('.fileupload-progress').hide();
        uploadStatusOK = true;
        justUploaded = 0;

        if (data.uploadedBytes && data.total) {
          data.files[0].uploadedBytes = data.uploadedBytes;
          data.files[0].progress = parseInt(data.uploadedBytes / data.total * 100, 10);
        }
      })
      .bind('fileuploaddestroyed', function (e, data) {
        console.log('fileuploaddestroyed');
        $('[id="add-files"]').show();
        $('[id="add-cloud-files"]').show();
        $('.fileupload-progress').hide();
        $('.dropzone').show();
        uploadStatusOK = true;
        justUploaded = 0;

        // was this part of an upload resume?
        if ($('#resume-add-files').hasClass('ready-for-resume')) {
          $('#resume-add-files').removeClass('ready-for-resume');
          console.log('initiating resume');
          $('#resume-add-files').trigger('click');
        }
      });
  }

});