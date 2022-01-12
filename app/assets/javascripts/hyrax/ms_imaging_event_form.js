// Puts concatenated values into filter on submit.
function buildFilter(filter, filterGroupUl) {
  var li = document.createElement('li');

  var input = document.createElement('input');
  input.className = 'string multi_value optional imaging_event_ie_filter form-control multi-text-field';
  input.setAttribute("id", "imaging_event_ie_filter");
  input.setAttribute("name", "imaging_event[ie_filter][]");
  input.value = filter;

  li.appendChild(input);
  filterGroupUl.appendChild(li);
}

function prepIeFilter() {
  // If X-ray modality is selected, submit filter fields. Otherwise, submit an empty filter.
  var selectedModality = $('select[name="imaging_event[ie_modality]"]').val();
  console.log('selectedModality '+ selectedModality);      
  if (selectedModality === 'MicroNanoXRayComputedTomography') {
    var filterCount = $('select[name="imaging_event[filter_material][]"]').length;
    for (i = 0; i < filterCount; i++) {
      var filterMaterial = $('select[name="imaging_event[filter_material][]"]')[i].value || '';
      var filterThickness = $('input[name="imaging_event[filter_thickness][]"]')[i].value || '';
      // make sure both fields are filled out before creating a filter string
      if ((filterMaterial != '') && (filterThickness != '')) {
        var filter = "Filter material: " + filterMaterial + ", Filter thickness: " + filterThickness;
      } else {
        var filter = '';
      }
      console.log('filter: '+filter);
      buildFilter(filter, filterGroupUl);
    }
  } else {
    buildFilter('', filterGroupUl);
  }
}

var showFieldsByModality = function() {
  // hide modality specific fields, then show only specific fields based on the modality
  $('.ie_xray_ct, .ie_photogrammetry, .ie_photography').addClass('hide').removeClass('show');
  var selectedModality = $('select[name="imaging_event[ie_modality]"]').val();
  //console.log('ICE: ' + selectedModality);
  switch(selectedModality) {
  case 'MicroNanoXRayComputedTomography':
    $('.ie_xray_ct').addClass('show').removeClass('hide');
    $('.ie_photogrammetry, .ie_photography').children('input, select').val('');
    break;
  case 'Photogrammetry':
    $('.ie_photogrammetry').addClass('show').removeClass('hide');
    $('.ie_xray_ct').children('input, select').val('');
    break;
  case 'Photography':
    $('.ie_photography').addClass('show').removeClass('hide');
    $('.ie_xray_ct').children('input, select').val('');
    $('.ie_photogrammetry').children('input#imaging_event_background_removal, select#imaging_event_focal_length_type').val('');
    break;
  default: // any other modality
    $('.ie_xray_ct, .ie_photogrammetry, .ie_photography').children('input, select').val('');
  }
}

$( document ).ready(function() {
  //console.log('ready... length='+ $('form[id*="imaging_event"]').length) ;
  if ($('form[id*="imaging_event"]').length) { // if IE add/edit form page (submission flow, media edit, default hyrax IE form)

    showFieldsByModality();

    // Check the Filter Field (will be hidden)
    filterGroup = document.querySelector('div.imaging_event_ie_filter');
    filterGroupUl = filterGroup.querySelector("ul");
    var concatFilters = filterGroup.querySelectorAll("input");
    var concatFilterCount = (filterGroup.querySelectorAll("input").length) - 1;

    // Two part filter entry
    var filterWrapper = document.getElementById("imaging_event_ie_filter_wrapper");
    var filterWrapperUl = filterWrapper.querySelector('ul');
    var filterWrapperLi = filterWrapper.querySelector('li');

    // When editing a record, this populates the filter fields with previously saved metadata.
    for (i = 0; i < concatFilterCount; i++) {
      var concatFilterValue = concatFilters[i].value;
      //console.log('concatFilterValue: '+concatFilterValue);

      // Does filter value match format? If not, just pass to thickness
      var filterMatch = concatFilterValue.match(/Filter material: (.*?), Filter thickness: /);
      if(Array.isArray(filterMatch)) {
        var material = filterMatch[1];
        var thickness = concatFilterValue.match(/Filter thickness: (.*)/)[1];
      } else {
        var material = null;
        var thickness = concatFilterValue;
      }

      // Fill in values for first line
      if (i == 0) {
        var materialSelectOject = $('select[name="imaging_event[filter_material][]"]')[0];
        for (var x = 0; x < materialSelectOject.length; x++){
          if (materialSelectOject.options[x].value == material)
            materialSelectOject.selectedIndex = x;
        }
        $('input[name="imaging_event[filter_thickness][]"]')[0].value = thickness;
      } else {
        // Assemble new material, thickness
        var li = document.createElement('li');
        li.className = 'field-wrapper input-group input-append';

        $('<select />', {
          id : "imaging_event_filter_material_"+i,
          name : 'imaging_event[filter_material][]',
          class : "form-control select optional form-control",
          append : [
            $('<option />', {value : "", text : "--Select Material--"}),
            $('<option />', {value : "Molybdenum", text : "Molybdenum"}),
            $('<option />', {value : "Aluminum", text : "Aluminum"}),
            $('<option />', {value : "Copper", text : "Copper"}),
            $('<option />', {value : "Rhodium", text : "Rhodium"}),
            $('<option />', {value : "Niobium", text : "Niobium"}),
            $('<option />', {value : "Europium", text : "Europium"}),
            $('<option />', {value : "Lead", text : "Lead"}),
            $('<option />', {value : "Tin", text : "Tin"})
          ]
        }).appendTo(li);
        // select the existing option
        $(li).find('select').val(material);

        var thicknessInput = document.createElement('input');
        thicknessInput.className = "string multi_value optional form-control imaging_event_filter_thickness form-control multi-text-field";
        thicknessInput.setAttribute("id", "imaging_event_filter_thickness");
        thicknessInput.setAttribute("name", "imaging_event[filter_thickness][]");
        thicknessInput.value = thickness;
        li.appendChild(thicknessInput);


        var span = document.createElement('span');
        span.className = "input-group-btn field-controls";
        span.innerHTML = `<button type="button" class="btn btn-link remove">
                            <i class="fa fa-times-circle" aria-hidden="true"></i>
                            <span class="controls-remove-text">Remove</span>
                            <span class="sr-only"> previous
                              <span class="controls-field-name-text"> FILTER</span>
                            </span>
                          </button>`

        li.appendChild(span);

        filterWrapperUl.appendChild(li);

      }
    }

    // Clear default filter fields when done.
    filterGroupUl.innerHTML = '';
    $(filterGroup).hide(); // hide the field label and add button

    // this is bening called by the default hyrax IE form 
    // On submit, material and thickness fields are concatenated and inserted into hidden default filter field.
    if ($("body").hasClass("dashboard")) {
      var ie_form = $('form[id*="imaging_event"]')[0];
      ie_form.addEventListener("submit", function() {
        prepIeFilter();
      });
    }

  } // end if IE add/edit form page
});
