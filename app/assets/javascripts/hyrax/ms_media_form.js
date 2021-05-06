/* Media Share tab specific */
document.addEventListener("share-tab-loaded", function(event) {

  $('#btn-transfer-submit').click(function() {

    $('#new_proxy_deposit_request').submit();

  });

});

$( document ).ready(function() {

  if ( $('form[id*="edit_media"]').length ||
       $('form[id*="new_media"]').length ) { // if media form page (add/edit)

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

    // setupEmbeddedWorkForm('device', 'new', false, updateMediaTitle);
    // setupEmbeddedWorkForm('organization', 'new', false, updateDevice);
    setupEmbeddedWorkForm('biological_specimen', false, 'new');
    setupEmbeddedWorkForm('processing_event', 'new', true, reloadPage);
    setupTooltip();
    //removeLastRepeatable();  // this should not be needed since it's already called inside 'if edit media form page' block

    form = $('form[id*="media"]')[0];

    // Hidden Default Scale Bar Field
    scaleBarGroup = document.querySelector('div.media_scale_bar');
    scaleBarGroupUl = scaleBarGroup.querySelector("ul");
    concatScaleBars = scaleBarGroup.querySelectorAll("input");
    concatScaleBarCount = (scaleBarGroup.querySelectorAll("input").length) - 1;

    // Three part scale bar entry
    scaleBarWrapper = document.getElementById("media_scale_bar_wrapper");
    scaleBarWrapperUl = scaleBarWrapper.querySelector('ul');
    scaleBarWrapperLi = scaleBarWrapper.querySelector('li');

    // concatenate rights holder name, type to rights holder
    // Check the rightsHolder Field (will be hidden)
    targetGroup = document.querySelector('div.media_rights_holder');
    targetGroupUl = targetGroup.querySelector("ul");
    concatFields = targetGroup.querySelectorAll("input");
    concatFieldCount = (targetGroup.querySelectorAll("input").length) - 1;

    // TODO: Needs more investigation -
    // Rights holder fields are being hidden on media edit pages for recently added media, but it is unclear why that is happening.
    // Below ensures that field shows up:
    $('#media_rights_holder_wrapper').removeClass('hide');

    // Two part rightsHolder entry
    targetWrapper = document.getElementById("media_rights_holder_wrapper");
    targetWrapperUl = targetWrapper.querySelector('ul');
    targetWrapperLi = targetWrapper.querySelector('li');

    hide_fields(['.media_number_of_images_in_set','.media_scale_bar']);
    adjust_form_media_type();
    setupRightsHolder();
    setupScaleBar();

    $(document).on('change', '#media_media_type', function() {
      adjust_form_media_type();
    });
    

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
          //li.setAttribute('style', "display:flex; flex-direction:row; justify-content:space-evenly;");

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

    function adjust_form_media_type() {
      $('.media_type_block').hide();
      $('#file-object-details').hide();
      // All references to #file-object-details relate to work submission UI section
      if ($('#media_media_type').val() == 'CTImageSeries') {
        $('.CTImageSeries').show();
        $('#file-object-details').show();

        // show/hide in hyrax add media form
        show_fields(['.media_series_type', '.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_slice_thickness', '.media_unit']);
        hide_fields(['.media_map_type', '#media_scale_bar_wrapper', '#media_scale_bar_target_type', '#media_scale_bar_distance', '#media_scale_bar_units']);
      } else if ($('#media_media_type').val() == 'PhotogrammetryImageSeries') {
        $('.PhotogrammetryImageSeries').show();
        $('#file-object-details').show();

        // show/hide in hyrax add media form
        show_fields(['#media_scale_bar_wrapper', '#media_scale_bar_target_type', '#media_scale_bar_distance', '#media_scale_bar_units']);
        hide_fields(['.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_slice_thickness', '.media_unit', '.media_map_type']);
      } else if ($('#media_media_type').val() == 'Mesh') {
        $('.Mesh').show();
        $('#file-object-details').show();

        // show/hide in hyrax add media form
        show_fields(['.media_unit', '.media_map_type']);
        hide_fields(['.media_series_type', '.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_slice_thickness', '#media_scale_bar_wrapper', '#media_scale_bar_target_type', '#media_scale_bar_distance', '#media_scale_bar_units']);
      } else {
        $('.media_type_block').hide();

        // show/hide in hyrax add media form
        hide_fields(['.media_series_type', '.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_slice_thickness', '.media_unit', '.media_map_type', '#media_scale_bar_wrapper', '#media_scale_bar_target_type', '#media_scale_bar_distance', '#media_scale_bar_units']);
      }
    }

    function setupRightsHolder() {

      // When editing a record, this populates the rightsHolder fields with previously saved metadata.
      for (i = 0; i < concatFieldCount; i++) {
        var concatFieldValue = concatFields[i].value;
        //console.log('concatFieldValue: '+concatFieldValue);
        if (concatFieldValue.match(/Name: (.*?), Type: /)) {
          var name = concatFieldValue.match(/Name: (.*?), Type: /)[1];
          var type = concatFieldValue.match(/Type: (.*)/)[1];          
        } else if (concatFieldValue.match(/Name: (.*?)/)) {
          // foung "Name" but no "Type"
          var name = concatFieldValue.match(/Name: (.*?)/)[1];
          var type = "";
        } else {
          // just assume the value is the Name (no type) 
          var name = concatFieldValue;
          var type = "";        
        }

        // Fill in values for first line
        if (i == 0) {
          var typeSelectOject = $('select[name="media[rights_holder_type][]"]')[0];
          for (var x = 0; x < typeSelectOject.length; x++){
            if (typeSelectOject.options[x].value == type)
              typeSelectOject.selectedIndex = x;
          }
          $('input[name="media[rights_holder_name][]"]')[0].value = name;
        } else {
          // Assemble new name, type
          var li = document.createElement('li');
          li.className = 'field-wrapper input-group input-append';
          //li.setAttribute('style', "display:flex; flex-direction:row; justify-content:space-evenly;");

          var nameInput = document.createElement('input');
          nameInput.className = "string multi_value optional form-control media_rights_holder_name form-control multi-text-field";
          nameInput.setAttribute("id", "media_rights_holder_name");
          nameInput.setAttribute("name", "media[rights_holder_name][]");
          //nameInput.setAttribute("style", "margin:5px; width:50%; border-radius:5px;");
          nameInput.value = name;
          li.appendChild(nameInput);

          $('<select />', {
            id : "media_rights_holder_type_" + i.toString(),
            name : 'media[rights_holder_type][]',
            class : "form-control select optional form-control",
            //style : "margin:5px; width:50%; border-radius:5px;",
            append : [
              $('<option />', {value : "", text : ""}),
              $('<option />', {value : "Copyright and License", text : "Copyright and License"}),
              $('<option />', {value : "Copyright", text : "Copyright"}),
              $('<option />', {value : "License", text : "License"})
            ]
          }).appendTo(li);
          // select the existing option
          $(li).find('select').val(type);

          var span = document.createElement('span');
          span.className = "input-group-btn field-controls";
          span.innerHTML = '<button type="button" class="btn btn-link remove" data-index="' + i.toString() + '"><i class="fa fa-times-circle" aria-hidden="true"></i></button><button type="button" class="btn btn-link add"><i class="fa fa-plus-circle" aria-hidden="true"></i></button>'

          li.appendChild(span);
          targetWrapperUl.appendChild(li);

        }
      }

      // Clear default rightsHolder fields when done.
      targetGroupUl.innerHTML = '';
      $(targetGroup).hide(); // hide the field label and add button

    } // /setupRightsHolder

  } // end if media form page

  jQuery.fn.extend({
    submitRelatedWork: function (callback) {
      var relatedFormId = $(this).attr('id');
      console.log('submitting '+ relatedFormId );
      // replace with ajax form post to trigger other actions
      var postData = new FormData($(this)[0]);
      //postdata.push({name: "NonFormValue", value: 'foo'});

      $.ajax({
        type: "POST",
        url: $(this).attr('action'),
        data: postData,
        processData: false,
        contentType: false,
        dataType: "json",
        success: function(data){
          //console.log("submitted work ID: " + data.id );
          if (relatedFormId.indexOf('imaging_event') != -1)
            IsImagingEventOK = true;
          else if (relatedFormId.indexOf('processing_event') != -1)
            IsProcessingEventOK = true;
          if (callback) callback();
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
        if (callback) callback();
      }).always(function(data) {

      });
    }
  });

  if ($('form[id*="edit_media"]').length) { // if edit media form page

    function updateMediaTitle() {
      var parts = $('[name="media[part][]"]').map(function(){
        if ($(this).val() != '')
          return $(this).val();
      }).get().join(', ');
      if (parts == '') {
        parts = 'Element Unspecified';
      }
      parts = toTitleCase(parts);
      var mediaType = $('[name="media[media_type]"]').val();
      mediaType = '[' + mediaType + ']';
      if ($('[name="imaging_event[ie_modality]"]').length)
        var ie_modality = $('[name="imaging_event[ie_modality]"]').val();
      else if ($('.showcase-value.imaging_event_modality').length)
        var ie_modality = $('.showcase-value.imaging_event_modality').html();
      else
        var ie_modality = 'modality_undefined';
      ie_modality = '[' + modalityAbbrev(ie_modality) + ']';
      var title = parts + ' ' + mediaType + ' ' + ie_modality;
      $('#showcase-title').text(title);
    }

    function updateDevice(organization, instutition) {
      var organization_institution = $('#organization-title-value').text();
      //console.log('in updateDevice, organization_institution ', organization_institution);
      var organization_institution = organization + ' (' + instutition + ')';
      $('#device-organization-institution-value').text(organization_institution);
    }

    setupTooltip();
    removeLastRepeatable();
    adjust_form_media_type();

    // update anything else after selecting a device.  remove later if not needed
    //$('#select_device [data-behavior="add-relationship"]').click(function() {
    //  var device_id = $('#device-id').text();
    //  updateDevice('aaa', 'bb');
    //})

    // Change title on the fly when corresponding fields are updated
    $('.form-group').on('change', '[name="media[media_type]"], input.media_part, [name="imaging_event[ie_modality]"]', function(){
        updateMediaTitle();
    });

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
    });

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
      $('#device-organization-title-value').text(orgData.text);
      $('#device-title-value').text($('#imaging_event_select_device_id').find(':selected').text());
      $('#device-creator-value').text($('#imaging_event_select_device_id').find(':selected').data('creator'));
      $('#device-modality-value').attr('data-modality-id', $('#imaging_event_select_device_id').find(':selected').data('modality'));
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

    // when selecting an organization or device, hide the new work form if any
    $('[data-behavior="add-relationship"]').click(function() {
      var addButtonId = $(this).attr('id');
      //console.log(addButtonId + ' clicked...')
      if (addButtonId == 'btn-add-parent-media') {
        // close the modal, immediately save the processing event form, then refresh the page
        if ($(this).data('hasProcessingEvent') == true) {
          $('#modal-select-parent-media').modal('hide');
          disablePageAndSave(".btn-save-media");
          $("form#related_form_processing_event").submitRelatedWork(reloadPage);
        } else if ($(this).data('hasProcessingEvent') == false) {
          $('#modal-select-parent-media-new-processing-event').modal('hide');
          $('.new-processing-event-wrapper').show();
          $('.selected_parent_media').show();
          /*
          var isFormValid = buildProcessingActivity(); // populate the PA field before saving PE
          if (isFormValid) {
            disablePageAndSave(".btn-save-media");
            $("form#new_processing_event").submitRelatedWork(reloadPage);
          }
          */
        }
      } else {
        var newWorkDiv = '#embedded_div_new_' + addButtonId.split('btn-add-')[1];
        $(newWorkDiv).hide();
        closeLinkedContent(newWorkDiv);
      }
    })

    // when page is loaded, show/hide content based on which tab is active
    $(".related_form").hide();
    var activeTab = $('.nav-tabs > li.active').find("a").attr("aria-controls");
    $(".related_form." + activeTab).show();

    form.addEventListener("submit", function(mediaSubmitEvent) {

      mediaSubmitEvent.preventDefault();
      if (uploadStatusOK) {
        if (noFileCheck()) {
          prepareFieldsBeforeSubmit();
          if (isFormValid()) {
            disablePageAndSave(".btn-save-media");
            if (HasEditImagingEventForm) {
              $("form#related_form_imaging_event").submitRelatedWork(submitProcessingEvent);
            } else {
              IsImagingEventOK = true;
              submitProcessingEvent();
            }
          }
        }
      } else {
        promptAutoSave(".btn-save-media");
      }

      function isFormValid() {
        // check modality consistency
        if ($('#device-modality-value').length)
          var deviceModality = $('#device-modality-value').data('modality-id');
        if ($('#imaging_event_ie_modality').length)
          var imagingEventModality = $('#imaging_event_ie_modality').val();
        if (deviceModality && imagingEventModality) {
          if (deviceModality.includes(imagingEventModality)) {
            return true;
          } else {
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
          //console.log('updating media work...');
          form.submit();
        } else {
          alert('imaging_event or processing_event not saved properly.');
          enablePageAndSave(".btn-save-media");
        }
      }

    }); // /on submit

  } // end if edit media form page

})

// Puts concatenated values into rightsHolder on submit.
function buildTargetRightHolderField(inputValue, targetGroupUl) {
  var li = document.createElement('li');
  var input = document.createElement('input');
  input.className = 'string multi_value optional media_rights_holder form-control multi-text-field';
  input.setAttribute("id", "media_rights_holder");
  input.setAttribute("name", "media[rights_holder][]");
  input.value = inputValue;

  li.appendChild(input);
  targetGroupUl.appendChild(li);
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
  // Before submit, name and type fields are concatenated and inserted into hidden default rights holder field.
  $(targetGroupUl).empty(); // remove all items and re-build
  var rightsHolderCount = $('select[name="media[rights_holder_type][]"]').length;
  for (i = 0; i < rightsHolderCount; i++) {

    var rightsHolderName = $('input[name="media[rights_holder_name][]"]')[i].value || '';
    var rightsHolderType = $('select[name="media[rights_holder_type][]"]')[i].value || '';

    // As long as at least one input is filled out, proceed with creating a rightsHolder string. Otherwise, create an empty string.
    if ((rightsHolderType != '') || (rightsHolderName != '')) {
      var rightsHolder = "Name: " + rightsHolderName + ", Type: " + rightsHolderType;
    } else {
      var rightsHolder = '';
    }
    //console.log('rightsHolder: '+rightsHolder);
    buildTargetRightHolderField(rightsHolder, targetGroupUl);
  }

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

var noFileCheck = function() {
  if ($('.attribute-filename').length > 0) {
    // there is existing file associated with media
    return true;
  } else if (justUploaded > 0) {
    // file just uploaded waiting to be save
    return true;
  } else {
    return confirm('The media currently has no file associated.  Please click OK if you want to proceed.')
  }
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
