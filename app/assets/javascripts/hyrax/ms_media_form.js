$(document).on('turbolinks:load', function() {
  if ($('form[id*="media"]').length) { // if media form page
	hide_fields(['.media_number_of_images_in_set','.media_scale_bar']);
	adjust_form_media_type();
    
    // concatenate rights holder name, type to rights holder
    var form = $('form[id*="media"]')[0];

    // Check the rightsHolder Field (will be hidden)
    var targetGroup = document.querySelector('div.media_rights_holder');
    var targetGroupUl = targetGroup.querySelector("ul");
    var concatFields = targetGroup.querySelectorAll("input");
    var concatFieldCount = (targetGroup.querySelectorAll("input").length) - 1;

    // Two part rightsHolder entry
    var targetWrapper = document.getElementById("media_rights_holder_wrapper");
    var targetWrapperUl = targetWrapper.querySelector('ul');
    var targetWrapperLi = targetWrapper.querySelector('li');

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
        li.setAttribute('style', "display:flex; flex-direction:row; justify-content:space-evenly;");

        var nameInput = document.createElement('input');
        nameInput.className = "string multi_value optional form-control media_rights_holder_name form-control multi-text-field";
        nameInput.setAttribute("id", "media_rights_holder_name");
        nameInput.setAttribute("name", "media[rights_holder_name][]");
        nameInput.setAttribute("style", "margin:5px; width:50%; border-radius:5px;");
        nameInput.value = name;
        li.appendChild(nameInput);

        $('<select />', {
          id : "media_rights_holder_type_"+i,
          name : 'media[rights_holder_type][]',
          class : "form-control select optional form-control",
          style : "margin:5px; width:50%; border-radius:5px;",
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
        span.innerHTML = `<button type="button" class="btn btn-link remove">
                            <span class="glyphicon glyphicon-remove"></span>
                            <span class="controls-remove-text">Remove</span>
                            <span class="sr-only"> previous
                              <span class="controls-field-name-text"> RIGHTS HOLDER</span>
                            </span>
                          </button>`

        li.appendChild(span);

        targetWrapperUl.appendChild(li);

      }
    }

    // Clear default rightsHolder fields when done.
    targetGroupUl.innerHTML = '';
    $(targetGroup).hide(); // hide the field label and add button

    // On submit, name and type fields are concatenated and inserted into hidden default rights holder field.
    form.addEventListener("submit", function() {
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
        buildTargetField(rightsHolder, targetGroupUl);
      }
    });

    function adjust_form_media_type() {
      if ($('#media_media_type').val() == 'CTImageSeries') {
        show_fields(['.media_series_type', '.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_slice_thickness', '.media_unit']);
        hide_fields(['.media_map_type', '#media_scale_bar_wrapper', '#media_scale_bar_target_type', '#media_scale_bar_distance', '#media_scale_bar_units']);
      } else if ($('#media_media_type').val() == 'PhotogrammetryImageSeries') {
        show_fields(['#media_scale_bar_wrapper', '#media_scale_bar_target_type', '#media_scale_bar_distance', '#media_scale_bar_units']);
        hide_fields(['.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_slice_thickness', '.media_unit', '.media_map_type']);
      } else if ($('#media_media_type').val() == 'Mesh') {
        show_fields(['.media_unit', '.media_map_type']);
        hide_fields(['.media_series_type', '.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_slice_thickness', '#media_scale_bar_wrapper', '#media_scale_bar_target_type', '#media_scale_bar_distance', '#media_scale_bar_units']);
      } else {
        hide_fields(['.media_series_type', '.media_x_spacing', '.media_y_spacing', '.media_z_spacing', '.media_slice_thickness', '.media_unit', '.media_map_type', '#media_scale_bar_wrapper', '#media_scale_bar_target_type', '#media_scale_bar_distance', '#media_scale_bar_units']);
      }
    }

    // Puts concatenated values into rightsHolder on submit.
    function buildTargetField(inputValue, targetGroupUl) {
      var li = document.createElement('li');
      var input = document.createElement('input');
      input.className = 'string multi_value optional media_rights_holder form-control multi-text-field';
      input.setAttribute("id", "media_rights_holder");
      input.setAttribute("name", "media[rights_holder][]");
      input.value = inputValue;

      li.appendChild(input);
      targetGroupUl.appendChild(li);
    }

    $(document).on('change', '#media_media_type', function() {
      adjust_form_media_type();
    });

  } // end if media form page
})

