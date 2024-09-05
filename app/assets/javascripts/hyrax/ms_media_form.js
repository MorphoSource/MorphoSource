/* Media Share tab specific */
document.addEventListener("share-tab-loaded", function(event) {

  var transferToSelect = $('#proxy_deposit_request_transfer_to');
  transferToSelect.dataManagerSearch(); // returns a list of users & organization collections

  $('#btn-transfer-submit').click(function() {
    if (transferToSelect.val().length == 0) {
      alert('Please select a user or organization');
    } else if (confirm('Are you sure you want to transfer ownership of this work to another user or organization? Click Ok to transfer or Cancel to return to the transfer screen')) {
        disablePage();
        $('#new_proxy_deposit_request').submit();
    }
  });
});

$( document ).ready(function() {
  if ($('form[id*="edit_media_list"]').length) { return }
  if ($('form[id*="new_media_list"]').length) { return }

  if ( $('form[id*="edit_media"]').length ||
       $('form[id*="new_media"]').length ) {

    setCustomTitlePlaceholder();
    $(document).on('change', 'input[name="media[part][]"]', function() {
      setCustomTitlePlaceholder();
    });
    $(document).on('click', 'button.remove', function() {
      setCustomTitlePlaceholder();
    });
    $(document).on('change', 'select#imaging_event_ie_modality', function() {
      setCustomTitlePlaceholder();
    });

    IsImagingEventOK = false;
    IsProcessingEventOK = false;

    if ($('form[id*="related_form_imaging_event"]').length)
      HasEditImagingEventForm = true;
    else
      HasEditImagingEventForm = false; // this means no edit IE form or IE is not editable

    if ($('form[id*="related_form_processing_event"]').length)
      HasEditProcessingEventForm = true;
    else
      HasEditProcessingEventForm = false;

    setupEmbeddedWorkForm('biological_specimen', false, 'new');
    setupEmbeddedWorkForm('processing_event', 'new', true, reloadPage);
    setupTooltip();

    form = $('form[id*="media"]')[0];

    // Temporary media access links
    $('input#media_temporary_link_expires_at').change(function() {
      let a = $('a#generate-temporary-media-access-link').first();
      let url = new URL(a.attr('href'));
      url.searchParams.set("expires_at", $(this).val());
      a.attr('href', url);
    });

    var clipboard = new Clipboard('.copy-temporary-media-link');
    clipboard.on('success', function(e) {
      $(e.trigger).tooltip('show');
      e.clearSelection();
    });

    // Hidden Default Scale Bar Field
    scaleBarGroup = document.querySelector('div.media_scale_bar');
    scaleBarGroupUl = scaleBarGroup.querySelector("ul");
    concatScaleBars = scaleBarGroup.querySelectorAll("input");
    concatScaleBarCount = (scaleBarGroup.querySelectorAll("input").length) - 1;

    // Three part scale bar entry
    scaleBarWrapper = document.getElementById("media_scale_bar_wrapper");
    scaleBarWrapperUl = scaleBarWrapper.querySelector('ul');
    scaleBarWrapperLi = scaleBarWrapper.querySelector('li');

    hide_fields(['.media_number_of_images_in_set','.media_scale_bar']);
    adjust_form_media_type();
    setupScaleBar();

    $(document).on('change', '#media_media_type', function() {
      adjust_form_media_type();
      setCustomTitlePlaceholder();
    });

    setMediaLocalRemoteEvent();

    // debug: click save button in standalone form to submit related work form
    $(".btn-save.debug").click(function() {
      var targetForm = $('form[id*="' + $(this).attr('id') + '"]');
      console.log('clicked save button for ' + targetForm.attr('id'));
      if ($('form[id*="processing_event"]').length) { // if PE form
        buildProcessingActivity(); // populate the PA field before saving PE
      }
      //      targetForm.submit();
      targetForm.submitRelatedWork();
    });

    function setupScaleBar() {

      // When editing a record, this populates the three-part scale bar fields with previously saved metadata.
      for (i = 0; i < concatScaleBarCount; i++) {
        var concatScaleBarValue = concatScaleBars[i].value
        var type = concatScaleBarValue.match(/Type: (.*?), Distance: /)[1];
        var distance = concatScaleBarValue.match(/, Distance: (.*?), Units: /)[1];
        var units = concatScaleBarValue.match(/Units: (.*)/)[1];

        // Fill in values for first line
        if (i == 0) {
          scaleBarWrapperLi.querySelectorAll('input')[0].value = type;
          scaleBarWrapperLi.querySelectorAll('input')[1].value = distance;
          scaleBarWrapperLi.querySelectorAll('input')[2].value = units;
        }
        // Add a new line for each additional scalebar
        else {
          // Assemble new type, distance, and units inputs
          var li = document.createElement('li');
          li.className = 'field-wrapper input-group input-append';

          var typeInput = document.createElement('input');
          typeInput.className = "string multi_value optional form-control media_scale_bar_target_type form-control multi-text-field";
          typeInput.setAttribute("id", "media_scale_bar_target_type");
          typeInput.setAttribute("name", "media[scale_bar_target_type][]");
          //typeInput.setAttribute("style", "margin:5px; width:30%; border-radius:5px;");
          typeInput.value = type;
          li.appendChild(typeInput);

          var distanceInput = document.createElement('input');
          distanceInput.className = "string multi_value optional form-control media_scale_bar_distance form-control multi-text-field";
          distanceInput.setAttribute("id", "media_scale_bar_distance");
          distanceInput.setAttribute("name", "media[scale_bar_distance][]");
          //distanceInput.setAttribute("style", "margin:5px; width:30%; border-radius:5px;");

          distanceInput.value = distance;
          li.appendChild(distanceInput);

          var unitsInput = document.createElement('input');
          unitsInput.className = "string multi_value optional form-control media_scale_bar_units form-control multi-text-field";
          unitsInput.setAttribute("id", "media_scale_bar_units");
          unitsInput.setAttribute("name", "media[scale_bar_units][]");
          //unitsInput.setAttribute("style", "margin:5px; width:30%; border-radius:5px;");

          unitsInput.value = units;
          li.appendChild(unitsInput);

          var span = document.createElement('span');
          span.className = "input-group-btn field-controls";
          span.innerHTML = `<button type="button" class="btn btn-link remove">
                              <span class="glyphicon glyphicon-remove"></span>
                              <span class="controls-remove-text">Remove</span>
                              <span class="sr-only"> previous
                                <span class="controls-field-name-text"> Scale Bar</span>
                              </span>
                            </button>`
          span.innerHTML = '<button type="button" class="btn btn-link remove" data-index="' + i.toString() + '"><i class="fa fa-times-circle" aria-hidden="true"></i></button><button type="button" class="btn btn-link add"><i class="fa fa-plus-circle" aria-hidden="true"></i></button>'

          li.appendChild(span);

          scaleBarWrapperUl.appendChild(li);

        }
      }

      // Clear default scale bar fields when done.
      scaleBarGroupUl.innerHTML = '';
      $(scaleBarGroup).hide(); // hide the field label and add button

    } // /setupScaleBar

    function setCustomTitlePlaceholder() {
      var parts = $('input[name="media[part][]"]').map(function() {
        return $(this).val();
      }).toArray();
      var title = parts.join(', ');
      if (title == '') {
        title = "Element Unspecified";
      } else {
        title = toTitleCase(title);
      }
      var mediaTypeSelect = $('#media_media_type');
      if (mediaTypeSelect.length) {
        title += ' [' + mediaTypeSelect.val() + ']';
      }
      var modalitySelect = $('#imaging_event_ie_modality'); // from the select input when IE is editable
      var modalityDiv = $('.ie_modality_value'); // from the hidden div when IE is not editable
      if (modalityDiv.length) {
        title += ' [' + modalityAbbrev(modalityDiv.text()) + ']';
      } else if (modalitySelect.length) {
        title += ' [' + modalityAbbrev(modalitySelect.val()) + ']';
      }
      $('#media_short_title').attr('placeholder', title);
    }

    function adjust_form_media_type() {
      $('.media_type_block').hide();
      $('#file-object-details').hide();
      // All references to #file-object-details relate to work submission UI section
      if ($('#media_media_type').val() == 'CTImageSeries') {

        $('.CTImageSeries').show();
        $('#file-object-details').show();

        // show/hide/require/un-require in hyrax add media form
        show_fields(['.media_series_type', '.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_slice_thickness', '.media_unit']);
        hide_fields(['.media_map_type', '#media_scale_bar_wrapper', '#media_scale_bar_target_type', '#media_scale_bar_distance', '#media_scale_bar_units']);
        require_fields(['.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_unit']);

      } else if ($('#media_media_type').val() == 'SequentialSectionImageSeries') {
        $('.SequentialSectionImageSeries').show();
        $('#file-object-details').show();

        // show/hide in hyrax add media form
        show_fields(['.media_series_type', '.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_slice_thickness', '.media_unit']);
        hide_fields(['.media_map_type', '#media_scale_bar_wrapper', '#media_scale_bar_target_type', '#media_scale_bar_distance', '#media_scale_bar_units']);
        unrequire_fields(['.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_unit']);

      } else if ($('#media_media_type').val() == 'PhotogrammetryImageSeries') {
        $('.PhotogrammetryImageSeries').show();
        $('#file-object-details').show();

        // show/hide in hyrax add media form
        show_fields(['#media_scale_bar_wrapper', '#media_scale_bar_target_type', '#media_scale_bar_distance', '#media_scale_bar_units']);
        hide_fields(['.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_slice_thickness', '.media_unit', '.media_map_type']);
        unrequire_fields(['.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_unit']);

      } else if ($('#media_media_type').val() == 'Mesh') {
        $('.Mesh').show();
        $('#file-object-details').show();

        // show/hide in hyrax add media form
        show_fields(['.media_unit', '.media_map_type']);
        hide_fields(['.media_series_type', '.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_slice_thickness', '#media_scale_bar_wrapper', '#media_scale_bar_target_type', '#media_scale_bar_distance', '#media_scale_bar_units']);
        unrequire_fields(['.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_unit']);

      } else {
        $('.media_type_block').hide();

        // show/hide in hyrax add media form
        hide_fields(['.media_series_type', '.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_slice_thickness', '.media_unit', '.media_map_type', '#media_scale_bar_wrapper', '#media_scale_bar_target_type', '#media_scale_bar_distance', '#media_scale_bar_units']);
        unrequire_fields(['.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_unit']);
      }
    }

    var thumbField = document.getElementById("custom_thumbnail");
    thumbField.onchange = function() {
      if (this.files[0].size > 500000) {
        alert('Thumbnail size must be 500KB or smaller.  Please upload another thumbnail image.');
        $('#custom_thumbnail_hint').addClass('text-alert');
        this.value = "";
      } else {
        $('#custom_thumbnail_hint').removeClass('text-alert');
      }
    };

  } // end if media form page

  jQuery.fn.extend({
    submitRelatedWork: function (callback) {
      var relatedFormId = $(this).attr('id');
      console.log('submitting '+ relatedFormId );
      var postData = new FormData($(this)[0]);
      $.ajax({
        type: "POST",
        url: $(this).attr('action'),
        data: postData,
        processData: false,
        contentType: false,
        dataType: "json",
        success: function(data){
          console.log("submitted work ID: " + data.id );
        }
      }).fail(function(data) {
        console.log("getting a fail status ", data );
        var errors = data.responseJSON.errors;
        var msg = "";
        if (errors !== undefined) {
          $.map(errors, function( errorsArray, field ) {
            $.map(errorsArray, function( errorMsg ) {
              msg += errorMsg + '\n';
            });
          });
        }
        if (msg) alert(msg);
      });
      // Call the next function (to save PE form or media form) 
      // NO need to wait for ajax post response
      if (relatedFormId.indexOf('imaging_event') > 0) {
        IsImagingEventOK = true;
      } else if (relatedFormId.indexOf('processing_event') > 0) {
        IsProcessingEventOK = true;
      }
      if (callback) callback();
    }
  });

  if ($('form[id*="edit_media"]').length) { // if edit media form page

    $('#tab-media-details[class!="active"] a').on('click', function(){
      var uvIframe = document.getElementById("uv-iframe");
      if (this.ariaExpanded == "false" && uvIframe) {
        uvIframe.contentDocument.location.reload(true);
      }
    })

    setupTooltip();
    removeLastRepeatable();
    adjust_form_media_type();

    // when switching tab, show/hide content
    $('.nav-tabs > li').click(function() {
      $(".related_form").hide();
      var clickedTab = $(this).find("a").attr("aria-controls");
      // hide the new work form from other tab if any
      if ($(this).find('a[aria-expanded="false"]').length) {
        $('.embedded_div').hide();
      }
      $(".related_form." + clickedTab).show();
    });

    // Select Physical Object Functions

    // select2-associated select physical object button
    $('#btn-select-physical-object').click(function() {
      var po = $('#s2id_imaging_event_find_physical_object').select2('data');
      if (po != null) {
        if (po.id != $("#physical-object-id-value").val()) {
          // if different po selected, display a modal to prompt the user to confirm to save the media
          $('#modal-select-physical-object').modal();
        } else {
          // reset the selection
          $('#s2id_imaging_event_find_physical_object').select2("val", "");
        }
      }
    });

    $('#modal-select-physical-object').on('hidden.bs.modal', function (e) {
      $('#s2id_imaging_event_find_physical_object').select2("val", "");
    })

    // Select Device Functions

    // select2-associated select organization button
    $('#btn-select-device-organization').click(function() {
      var selectData = $('#s2id_find_device_organization').select2('data');
      console.log($('#s2id_find_device_organization').select2('data'));

      $('#imaging_event_select_device_id option').each(function() {
        if ($(this).attr('value')) {
          $(this).remove();
        }
      });

      if (selectData) {
        for (const device of selectData.devices) {
          console.log(device);
          if (device.creator) {
            var title = device.creator + ' ' + device.title;
          } else {
            var title = device.title;
          }
          $('#imaging_event_select_device_id').
            append($('<option></option>')
              .attr('value', device.id)
              .attr('data-modality', device.modality)
              .attr('data-creator', device.creator)
              .attr('data-description', device.description)
              .text(title)
            );
        }
      }

      $('#device-select-section').removeClass('hide').addClass('show');
    });

    // select2-associated no organization button
    $('#btn-no-device-organization').click(function() {
      $.ajax({
        url: "/authorities/search/find_organizations_with_devices?type[]=Organization&id=NA&q=no organization",
        type: 'GET',
        dataType: 'json',
        complete: function (xhr, status) {
          var results = $.parseJSON(xhr.responseText);
          console.log(results);
          $('#s2id_find_device_organization').val(null).trigger('change');
          $('#select_device .select2-chosen').text('');

          $('#imaging_event_select_device_id option').each(function () {
            if ($(this).attr('value')) {
              $(this).remove();
            }
          });

          console.log(results[0]['devices']);
          for (const device of results[0]['devices']) {
            console.log(device);

            if (device['title'] && device['title'][0].toLowerCase() == 'unknown ct scanner') {
              continue;
            }

            $('#imaging_event_select_device_id')
              .append($('<option></option>')
                .attr('value', device['id'])
                .attr('data-modality', device['modality'])
                .attr('data-creator', device['creator'])
                .attr('data-description', device['description'])
                .text(device['title'])
              );
          }

          $('#device-select-section').removeClass('hide').addClass('show');
        }
      });
    });

    // select device button
    $('#btn-select-device').click(function() {
      var newDeviceID = $('#imaging_event_select_device_id').val();
      var orgData = $('#s2id_find_device_organization').select2('data');

      // modify current device properties
      $('#device-id-value').val(newDeviceID);
      if (orgData)
        deviceOrgTitle = orgData.text;
      else
        deviceOrgTitle = "No organization";
      $('#device-organization-title-value').text(deviceOrgTitle);
      $('#device-title-value').text($('#imaging_event_select_device_id').find(':selected').text());
      $('#device-creator-value').text($('#imaging_event_select_device_id').find(':selected').data('creator'));
      $('#device-modality-value').attr('data-modality-id', $('#imaging_event_select_device_id').find(':selected').data('modality'));
      console.log('data-modality-id set to ' + $('#device-modality-value').attr('data-modality-id'));
      $('#device-modality-value').text(modalityTerm($('#imaging_event_select_device_id').find(':selected').data('modality')));
      $('#device-description-value').text($('#imaging_event_select_device_id').find(':selected').data('description'));

      // modify the form
      $('form#related_form_imaging_event input[name^="imaging_event[device_id]"]').remove();
      $('<input />').attr('type', 'hidden')
        .attr('name', 'imaging_event[device_id]')
        .attr('value', newDeviceID )
        .appendTo($('form#related_form_imaging_event'));
    });


    // remove organization when clicking no organization button
    $('#btn_no_organization').click(function() {
      var removeOrganizationButton = $('#parent-relationships-organizations').find('[data-behavior="remove-relationship"]');
      if (removeOrganizationButton.length) {
        removeOrganizationButton.trigger('click');
      }
      $('#embedded_div_new_organization').hide();
    })

    $('#btn-select-media.has-processing-event-true').click(function() {
      // display a modal to prompt the user to confirm
      // when user clicks OK, trigger the add parent button,
      // immediately save the processing event form, then refresh the page
      $('#modal-select-parent-media').modal();
    })
    $('#btn-select-media.has-processing-event-false').click(function() {
      // display a modal to prompt the user to fill in the processing event form
      $('#modal-select-parent-media-new-processing-event').modal();
    })

    // when a parent media is selected
    $('#btn-add-parent-media').click(function() {
      // close the modal, immediately save the processing event form, then refresh the page
      if ($(this).data('hasProcessingEvent') == true) {
        $('#modal-select-parent-media').modal('hide');
        disablePageAndSave(".btn-save-media");
        $("form#related_form_processing_event").submitRelatedWork(reloadPage);
      } else if ($(this).data('hasProcessingEvent') == false) {
        $('#modal-select-parent-media-new-processing-event').modal('hide');
        $('.new-processing-event-wrapper').show();
        $('.selected_parent_media').show();
      }
    })

    // when page is loaded, show/hide content based on which tab is active
    $(".related_form").hide();
    var activeTab = $('.nav-tabs > li.active').find("a").attr("aria-controls");
    $(".related_form." + activeTab).show();


    form.addEventListener("submit", function(mediaSubmitEvent) {
      mediaSubmitEvent.preventDefault();
      if (uploadStatusOK) {
        if (skipNoFileCheck) {
          if (fileOrigin == "remote") {
            // make sure the field is empty before saving
            $('#media_remote_origin_url').val('');
            fileOrigin = "local";
          }
          editMediaSubmit();
        } else if (noFileCheck()) {
          if (fileOrigin == "remote") {
            remoteFileCheckAndSubmit();
          } else {
            editMediaSubmit();
          }
        }
      } else {
        promptAutoSave(".btn-save-media");
      }
    }); // /on submit

    $(".nav-tabs.upload-file a").click(function(){
      // set the hash to the main nav tab name instead of sub tab name
      // so that reloading the page will open the file-upload tab
      window.location.hash = 'file-upload';
    });

  } // end if edit media form page

})

function isModalityValid() {
  // check modality consistency
  if ($('#device-modality-value').length)
    var deviceModality = $('#device-modality-value').attr('data-modality-id');
  if ($('#imaging_event_ie_modality').length)
    var imagingEventModality = $('#imaging_event_ie_modality').val();
  if (deviceModality && imagingEventModality) {
    if (deviceModality.trim().split(/\s*,\s*/).includes(imagingEventModality)) {
      return true;
    } else {
      console.log('deviceModality '+ deviceModality);
      console.log('imagingEventModality '+ imagingEventModality);
      alert('Device modality does not match imaging event modality.');
    }
  } else {
    return true;
  }
}

function submitProcessingEvent() {
  // only needs to save PE edit form. Note that for cases like raw media,
  // which has no PE, the page will have a new PE form, which does not need
  // to be submitted when saving the Media
  if (HasEditProcessingEventForm) {
    var isProcessingActivityValid = buildProcessingActivity(); // populate the PA field before saving PE
    if (isProcessingActivityValid) {
      $("form#related_form_processing_event").submitRelatedWork(saveMediaIfReady);
    }
  } else {
    IsProcessingEventOK = true;
    saveMediaIfReady();
  }
}

function saveMediaIfReady() {
  if (IsImagingEventOK && IsProcessingEventOK) {
    form.submit();
    console.log('...media form submitted');
  } else {
    $.alert('imaging_event or processing_event not saved properly.');
    enablePageAndSave(".btn-save-media");
  }
}

// Puts concatenated values into scale bar on submit.
function buildScaleBar(scaleBar, scaleBarGroupUl) {
  var li = document.createElement('li');

  var input = document.createElement('input');
  input.className = 'string multi_value optional media_scale_bar form-control multi-text-field';
  input.setAttribute("id", "media_scale_bar");
  input.setAttribute("name", "media[scale_bar][]");
  input.value = scaleBar

  li.appendChild(input);
  scaleBarGroupUl.appendChild(li);
}

function prepareFieldsBeforeSubmit() {

  // If media type = photogrammetry, submit scale bar fields. Otherwise, submit an empty scale bar.
  if($('#media_media_type').val() == 'PhotogrammetryImageSeries') {

    var scaleBarCount = document.getElementsByClassName("media_scale_bar_target_type").length;

    for (i = 0; i < scaleBarCount; i++) {

      var targetType = document.getElementsByClassName("media_scale_bar_target_type")[i].value || '';
      var scaleBarDistance = document.getElementsByClassName("media_scale_bar_distance")[i].value || '';
      var scaleBarUnits = document.getElementsByClassName("media_scale_bar_units")[i].value || '';

      // As long as at least one input is filled out, proceed with creating a scale bar string. Otherwise, create an empty string, which will not result in a new scale bar triple.
      if ((targetType != '') || (scaleBarDistance != '') || (scaleBarUnits != '')) {
        var scaleBar = "Type: " + targetType + ", Distance: " + scaleBarDistance + ", Units: " +  scaleBarUnits;
      }
      else {
        var scaleBar = ''
      }
      buildScaleBar(scaleBar, scaleBarGroupUl);
    }
  }
  else {
    buildScaleBar('', scaleBarGroupUl);
  }

}

var editMediaSubmit = function() {
  prepareFieldsBeforeSubmit();
  if (isModalityValid() && hasRequiredFields()) {
    disablePageAndSave(".btn-save-media");
    if (HasEditImagingEventForm) {
      $("form#related_form_imaging_event").submitRelatedWork(submitProcessingEvent);
    } else {
      // has a read-only Imaging Event form
      IsImagingEventOK = true;
      submitProcessingEvent();
    }
  } else {
    enablePage();
  }
}

var doSubmitMedia = function(view) {
  if ($('form[id*="edit_media"]').length) {
    editMediaSubmit();
  } else if ($('form[id*="new_media"]').length) {
    view.submitMedia();
  }
}

var remoteFileCheckAndSubmit = function(view=null) {
  try {
    var url = (new URL($('#media_remote_origin_url').val()));
    var extension = url.pathname.substring(url.pathname.lastIndexOf('.'));
  } catch (e) {
    $.alert('Please enter a valid Remote Origin URL.');
    return false;
  }

  disablePage();
  console.log("remote file check... ");
  $.ajax({
    url: '/submissions/validate_remote_file_ajax?u=' + encodeURI(url) + '&o=' + $('#associated_organization_id').val(),
    type: 'POST',
    dataType: 'json',
    complete: function (xhr, status) {
      var results = $.parseJSON(xhr.responseText);
      console.log("remote file check results: ", results);
      if (results.status == "success") {
        if (results.resp_file_ext != "") {
          // Check if the file extension evaluated from headers content type an accepted format
         var acceptedFormats = $('#media_accepted_formats').val().split(', ');
         if ($.inArray(results.resp_file_ext, acceptedFormats) == -1) {
            console.log("acceptedFormats: " + acceptedFormats);
            $.confirm({
                title: 'Please confirm',
                content: 'The file format returned by the Remote Origin URL is ' + (results.resp_file_ext || "unknown") + ' and it does not match an accepted format.  Click CONFIRM to save the media, or CANCEL to go back.',
                buttons: {
                  confirm: function() {
                    doSubmitMedia(view);
                  },
                  cancel: function() {
                    enablePage();
                  }
                }
            });
          } else {
            doSubmitMedia(view);
          }
        } else {
          $.alert('The file format is unknown.  Please check the media after it is saved.', 'Warning');
          doSubmitMedia(view);
        }
      } else if (results.status == "error") {
        $.alert('There is problem with the Remote Origin URL: ' + results.message);
        enablePage();
        return false;
      } else {
        $.alert('There is problem with the Remote Origin URL.  Please try again later or contact MorphoSource team.');
        enablePage();
        return false;
      }

    }//complete
  });
}

var updatePOandSave = function() {
  var po = $('#s2id_imaging_event_find_physical_object').select2('data');

  // modify current physical object properties
  $('#physical-object-details #physical-object-id-value').val(po.id);
  $('#physical-object-details #physical-object-institution-code').text(po.institution_code || '');
  $('#physical-object-details #physical-object-collection-code').text(po.collection_code || '');
  $('#physical-object-details #physical-object-catalog-number').text(po.catalog_number || '');
  $('#physical-object-details #physical-object-occurrence-id').text(po.occurrence_id || '');
  $('#physical-object-details #physical-object-short-title').text(po.short_title || '');
  $('#physical-object-details #physical-object-cho-type').text(po.cho_type || '');
  $('#physical-object-details #physical-object-material').text(po.material || '');

  if (po.idigbio_uuid) {
    $('#physical-object-details #physical-object-source').text('iDigBio');
  } else {
    $('#physical-object-details #physical-object-source').text('');
  }

  // modify the form
  $('form.edit_imaging_event input[name^="imaging_event[physical_object_id]"]').remove();
  $('<input />').attr('type', 'hidden')
    .attr('name', 'imaging_event[physical_object_id][]')
    .attr('value', po.id )
    .appendTo($('form.edit_imaging_event')
  );

  skipNoFileCheck = true;
  $('.btn-save-media').click();
  $('#modal-select-physical-object').modal('hide');
}

var setMediaLocalRemoteEvent = function() {
  $('#tab-local-file-section a').click(function(event) {
    if ($('#media_remote_origin_url').val() != "") {
      $.alert('Please clear the Remote Origin URL if the file is not from a remote location.');
      return false;
    } else {
      fileOrigin = "local";
    }
  });

  $('#tab-remote-file-section a').click(function(event) {
    if (justUploaded > 0) {
      $.alert('Please remove the file uploaded from computer or cloud first.');
      return false;
    } else {
      fileOrigin = "remote";
    }
  });
}

var noFileCheck = function() {
  if (skipNoFileCheck) {
    return true;
  } else if (fileOrigin == "local") {
    if ($('.attribute-filename').length > 0) {
      // there is existing file associated with media
      return true;
    } else if (justUploaded > 0) {
      // file just uploaded waiting to be save
      return true;
    }
  } else if (fileOrigin == "remote") {
    return true;
  }

  return confirm('The media currently has no file associated.  Please click OK if you want to proceed.')
}

var hasRequiredFields = function() {
  // only require fields for media with files attached
  if (fileOrigin == 'local' && $('.attribute-filename').length == 0 && justUploaded == 0) {
    return true;
  }

  let mediaType = $('#media_media_type').val()
  let missing_fields = []

  // CTImageSeries
  if (mediaType == 'CTImageSeries') {
    x = $('#media_x_spacing').val()
    y = $('#media_y_spacing').val()
    z = $('#media_z_spacing').val()
    unit = $('#media_unit').val()

    if (x && y && z && unit) {
      return true;
    } else {
      if (!x) {
        missing_fields.push('X Pixel Spacing');
      }
      if (!y) {
        missing_fields.push('Y Pixel Spacing');
      }
      if (!z) {
        missing_fields.push('Z Pixel Spacing');
      }
      if (!unit) {
        missing_fields.push('Pixel Spacing Units');
      }
      let field = (missing_fields.length > 1) ? "fields" : "field";
      $.alert(`Please add required ${field}: ${missing_fields.join(', ')}.`);
      return false;
    }
  }
  return true;
}

var promptAutoSave = function(mediaSaveBtn) {
  isAutoSave = confirm('File is currently being uploaded. If you select OK, this media will be saved when the file upload is complete.');
  if (isAutoSave) {
    // Check one last time if the file is already uploaded.
    if (uploadStatusOK) {
      console.log('after confirm ... try auto saving ...');
      $(mediaSaveBtn).trigger('click');
    } else {
      // disable the form with overlay message
      toggleForm(true);
    }
  }
}

var toggleForm = function(disabledState) {
  if (disabledState) {
    var msg = '<b>Please wait while the file is being uploaded.  The media will be submitted and saved automatically when the file upload is complete.  Please do not close the browser tab or window.  If you want to cancel and not to save the media automatically, <a href="javascript:void(0)" onclick="toggleForm(false)">click here</a>.</b>';
    // see loader options: https://www.jqueryscript.net/loading/Simple-jQuery-Loading-Spinner-Overlay-Plugin-Loader.html
    $data = {
      size: 22,
      bgOpacity: 0.85,
      imgUrl: '/loading[size].gif',
      title: msg,
      fontColor: true
    };
    $.loader.open($data);

  } else {
    $.loader.close();
    isAutoSave = false;
  }
}
