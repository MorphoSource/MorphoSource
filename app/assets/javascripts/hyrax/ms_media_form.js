$(document).on('turbolinks:load', function() {

  if ($('form[id*="media"]').length) { // if media form page (add/edit)

    if ($('form[id*="imaging_event"]').length)
      IsImagingEventReady = false;
    else
      IsImagingEventReady = true;  // this means no IE form or IE is not editable

    if ($('form[id*="processing_event"]').length)
      IsProcessingEventReady = false;
    else
      IsProcessingEventReady = true;

    setupEmbeddedWorkForm('device', 'new', updateMediaTitle);
    setupEmbeddedWorkForm('organization', 'new', updateDevice);
    setupTooltip();
    removeLastRepeatable();

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
    }) 

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
      if ($('#media_media_type').val() == 'CTImageSeries') {
        $('.CTImageSeries').show();

        // show/hide in hyrax add media form
        show_fields(['.media_series_type', '.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_slice_thickness', '.media_unit']);
        hide_fields(['.media_map_type', '#media_scale_bar_wrapper', '#media_scale_bar_target_type', '#media_scale_bar_distance', '#media_scale_bar_units']);
      } else if ($('#media_media_type').val() == 'PhotogrammetryImageSeries') {
        $('.PhotogrammetryImageSeries').show();

        // show/hide in hyrax add media form
        show_fields(['#media_scale_bar_wrapper', '#media_scale_bar_target_type', '#media_scale_bar_distance', '#media_scale_bar_units']);
        hide_fields(['.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_slice_thickness', '.media_unit', '.media_map_type']);
      } else if ($('#media_media_type').val() == 'Mesh') {
        $('.Mesh').show();

        // show/hide in hyrax add media form
        show_fields(['.media_unit', '.media_map_type']);
        hide_fields(['.media_series_type', '.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_slice_thickness', '#media_scale_bar_wrapper', '#media_scale_bar_target_type', '#media_scale_bar_distance', '#media_scale_bar_units']);
      } else {
        // show/hide in hyrax add media form
        hide_fields(['.media_series_type', '.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_slice_thickness', '.media_unit', '.media_map_type', '#media_scale_bar_wrapper', '#media_scale_bar_target_type', '#media_scale_bar_distance', '#media_scale_bar_units']);
      }
    }

    function setupRightsHolder() {

      // When editing a record, this populates the rightsHolder fields with previously saved metadata.
      for (i = 0; i < concatFieldCount; i++) {
        var concatFieldValue = concatFields[i].value;
        //console.log('concatFieldValue: '+concatFieldValue);

        var name = concatFieldValue.match(/Name: (.*?), Type: /)[1];
        var type = concatFieldValue.match(/Type: (.*)/)[1];

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

  } // end if media form page

  jQuery.fn.extend({
    submitRelatedWork: function (callback) {
      var relatedFormId = $(this).attr('id');
      console.log('submitting '+ relatedFormId );
      // replace with ajax form post to trigger other actions
      var postdata = $(this).serializeArray(); // convert form to array
      //postdata.push({name: "NonFormValue", value: 'foo'});
      //        console.log("postdata: " + postdata );
      $.post($(this).attr('action'), $.param(postdata), function(data){
        console.log("submitted work ID: " + data.id );
        if (relatedFormId.indexOf('imaging_event') != -1)
          IsImagingEventReady = true;
        else if (relatedFormId.indexOf('processing_event') != -1)
          IsProcessingEventReady = true;        
        callback();
      }, "json").fail(function(data) {
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
        callback();
      }).always(function(data) {
        
      });
    }
  });

  if ($('form[id*="edit_media"]').length) { // if edit media form page

    function updateMediaTitle() {
      var id = $('form[id*="edit_media"]').attr('id').split('_media_')[1];
      var parts = $('[name="media[part][]"]').map(function(){
        if ($(this).val() != '')
          return $(this).val();
      }).get().join(', ');
      parts = toTitleCase(parts);
      var mediaType = $('[name="media[media_type]"]').val();
      if ($('[name="imaging_event[ie_modality]"]').length)
        var ie_modality = $('[name="imaging_event[ie_modality]"]').val(); 
      else if ($('.showcase-value.imaging_event_modality').length)
        var ie_modality = $('.showcase-value.imaging_event_modality').html();
      else
        var ie_modality = 'modality_undefined';
      var title = [ id, parts, mediaType, ie_modality ];
      title = $.map( title, function(v){ return v === "" ? null : v; });
      $('#showcase-title').text(title.join(':'));     
    }

    function updateDevice(organization, instutition) {
      var organization_institution = $('#organization-title-value').text();
      console.log('in updateDevice, organization_institution ', organization_institution);
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
    // todo: input.media_part is a repeatable, but newly added media_part field does not trigger the event when it is updated
    $('[name="media[media_type]"], input.media_part, [name="imaging_event[ie_modality]"]').change(updateMediaTitle);

    // when switching tab, show/hide content
    $('.nav-tabs > li').click(function() {
      $(".related_form").hide();
      var clickedTab = $(this).find("a").attr("aria-controls");
      $(".related_form." + clickedTab).show();
    })

    // when page is loaded, show/hide content based on which tab is active
    var activeTab = $('.nav-tabs > li.active').find("a").attr("aria-controls");
    $(".related_form." + activeTab).show();

    form.addEventListener("submit", function(mediaSubmitEvent) {

      mediaSubmitEvent.preventDefault();
      $(".btn-save-media").prop('disabled', true).val('Saving...');

      prepareFieldsBeforeSubmit();
        
      // submit each related work form
      //$(".related_form form").each(function() {
      //  $(this).submitRelatedWork(saveMediaIfReady);
      //}) 

      if (!IsImagingEventReady) {  
        $("form#related_form_imaging_event").submitRelatedWork(submitProcessingEvent);
      } else {
        submitProcessingEvent();
      }

      function submitProcessingEvent() {
        if ($('form[id*="processing_event"]').length) { // if PE form 
          buildProcessingActivity(); // populate the PA field before saving PE
          $("#related_form_processing_event form").submitRelatedWork(saveMediaIfReady);
        } else {
          saveMediaIfReady();
        }
      }

      function saveMediaIfReady() {
        if (IsImagingEventReady && IsProcessingEventReady) {
          $(".btn-save-media").prop('disabled', true).val('Saving...');
          //console.log('updating media work...');
          form.submit();
        } else {
          // re-enable save button
          $(".btn-save-media").prop('disabled', false).val('Save');
        }
      }

    }); // /on submit

  } // end if edit media form page

  if ($('form[id*="new_media"]').length) { // if new media form page

    form.addEventListener("submit", function(mediaSubmitEvent) {

      $(".btn-save-media").prop('disabled', true).val('Saving...');

      prepareFieldsBeforeSubmit();

      //console.log('about to add media work...');
      
    }); // /on submit

  } // end if new media form page

})

