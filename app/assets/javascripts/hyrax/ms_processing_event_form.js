$( document ).ready(function() {
  if ($('form[id*="processing_event"]').length) { // if PE form page

    // concatenate rights holder name, type to rights holder
    var form = $('form[id*="processing_event"]')[0];

    // Check the processingActivity Field (will be hidden)
    var targetGroup = document.querySelector('div.processing_event_processing_activity');
    var targetGroupUl = targetGroup.querySelector("ul");
    var concatFields = targetGroup.querySelectorAll("input");
    var concatFieldCount = (targetGroup.querySelectorAll("input").length);

    // Two part processingActivity entry
    var targetWrapper = document.getElementById("processing_event_processing_activity_wrapper");
    var targetWrapperUl = targetWrapper.querySelector('ul');
    var targetWrapperLi = targetWrapper.querySelector('li');

    // if not in media edit page (standalone PE form), or in media edit page with a new PE form, it has an additional empty field
    if ($('form[id*="edit_media"]').length) { // if edit media form page
      if ($('form[id*="new_processing_event"]').length)
        var hasAdditionalEmptyField = true;
      else
        var hasAdditionalEmptyField = false;
    } else { // standalone PE form
        var hasAdditionalEmptyField = true;
    }

    if (hasAdditionalEmptyField) {
      concatFieldCount--;
    }

    // remove the last set of fields if in editing (not adding) mode
    if (concatFieldCount > 0) {
      $(targetWrapperUl).children("li").last().remove();
    }

    $('#processing_event_processing_activity_wrapper').on('click', '.add', function(){
        setNewProcessingActivityStep();
    });

    // build and validate the Processing Activity fields before submit
    // note: this has been moved out of "    if (hasAdditionalEmptyField) {  " condition block
    form.addEventListener("submit", function(peSubmitEvent) {
      var isFormValid = buildProcessingActivity(); // populate the PA field before saving PE
      if (!isFormValid || $('form[id*="processing_event"]').hasClass('stop-disable')) {
        peSubmitEvent.preventDefault();
        enablePage();
      } else {
        disablePage();
        console.log('about to submit in ME pe.js')
      }
    });

    // When editing a record, this populates the individual fields with previously saved metadata.
    for (i = 0; i < concatFieldCount; i++) {
      var concatFieldValue = concatFields[i].value;
      //console.log('concatFieldValue: '+concatFieldValue);
      var step = concatFieldValue.match(/^Step: ([0-9]+), Type: /)
      step = (step) ? step[1] : '1'; // if step value cannot be parsed, assume there is no PA, and set the first step to 1
      var type = concatFieldValue.match(/, Type: (.*), Software: /);
      type = (type) ? type[1] : '';
      var software = concatFieldValue.match(/, Software: (.*), Description: /);
      software = (software) ? software[1] : '';
      var description = concatFieldValue.match(/, Description: (.*)/);
      description = (description) ? description[1] : '';
      // Assemble new triple fields
      var li = document.createElement('li');
      li.className =  'field-wrapper input-group input-append processing_activity_items';
      li.setAttribute('data-step', step);

      appendProcessingActivityStepSelect(li);
      // select the existing option
      $(li).find('select.processing_event_processing_activity_step').val(step);

      appendProcessingActivityTypeSelect(li);
      // select the existing option
      $(li).find('select.processing_event_processing_activity_type').val(type);

      var softwareInput = document.createElement('input');
      softwareInput.className = "string multi_value optional form-control processing_event_processing_activity_software form-control multi-text-field";
      softwareInput.setAttribute("id", "processing_event_processing_activity_software");
      softwareInput.setAttribute("name", "processing_event[processing_activity_software][]");
      softwareInput.value = software;
      var row = document.createElement('div');
      row.className = "row";
      var label = document.createElement('div');
      label.className = "col-xs-6 showcase-label";
      label.innerHTML = "Activity software";
      var value = document.createElement('div');
      value.className = "col-xs-6 showcase-value";
      value.appendChild(softwareInput);
      row.appendChild(label);
      row.appendChild(value);
      li.appendChild(row);

      var descriptionInput = document.createElement('input');
      descriptionInput.className = "string multi_value optional form-control processing_event_processing_activity_description form-control multi-text-field";
      descriptionInput.setAttribute("id", "processing_event_processing_activity_description");
      descriptionInput.setAttribute("name", "processing_event[processing_activity_description][]");
      descriptionInput.value = description;
      var row = document.createElement('div');
      row.className = "row";
      var label = document.createElement('div');
      label.className = "col-xs-6 showcase-label";
      label.innerHTML = "Activity description and parameter settings";
      var value = document.createElement('div');
      value.className = "col-xs-6 showcase-value";
      value.appendChild(descriptionInput);
      row.appendChild(label);
      row.appendChild(value);
      li.appendChild(row);

      var span = document.createElement('span');
      span.className = "input-group-btn field-controls";
      span.innerHTML = '<button type="button" class="btn btn-link remove"><i class="fa fa-times-circle" aria-hidden="true"></i></button><button type="button" class="btn btn-link add"><i class="fa fa-plus-circle" aria-hidden="true"></i></button>';

      li.appendChild(span);
      targetWrapperUl.appendChild(li);

    }
    //console.log(targetWrapperUl);

    // sort the list items by 'step'
    $(targetWrapperUl).children("li").detach().sort(function(a, b) {
      //console.log($(a).data('step'));
      //return $(a).data('step').localeCompare($(b).data('step'));
      return +$(a).data('step') - +$(b).data('step');
    }).appendTo(targetWrapperUl);
    //console.log(targetWrapperUl);

    // Clear default fields when done.
    hide_fields(['.processing_event_processing_activity']);
    targetGroupUl.innerHTML = '';
    $(targetGroup).hide(); // hide the field label and add button

  } // end if PE form page
})

function buildProcessingActivity() {
  console.log('buildProcessingActivity...');
  var targetGroup = document.querySelector('div.processing_event_processing_activity');
  var targetGroupUl = targetGroup.querySelector("ul");

  // the three fields are concatenated and inserted into hidden default processing activity field.
  var processingActivityCount = $('select[name="processing_event[processing_activity_type][]"]').length;
  var steps = [];
  for (var i = 0; i < processingActivityCount; i++) {

    var processingActivityStep = $('select[name="processing_event[processing_activity_step][]"]')[i].value || '';
    var processingActivityType = $('select[name="processing_event[processing_activity_type][]"]')[i].value || '';
    var processingActivitySoftware = $('input[name="processing_event[processing_activity_software][]"]')[i].value || '';
    var processingActivityDescription = $('input[name="processing_event[processing_activity_description][]"]')[i].value || '';
    processingActivityStep = parseInt(processingActivityStep);
    steps.push(processingActivityStep);

    // As long as at least one input is filled out, proceed with creating a processingActivity string. Otherwise, create an empty string.
    if ((processingActivityType != '') || (processingActivitySoftware != '')) {
      var processingActivity = "Step: " + processingActivityStep + ", Type: " + processingActivityType + ", Software: " + processingActivitySoftware + ", Description: " + processingActivityDescription;
    } else {
      var processingActivity = '';
    }
    buildTargetField(processingActivity, targetGroupUl);
    //alert('processingActivity: '+processingActivity);
    // clear the individual fields to avoid confusion
    $('select[name="processing_event[processing_activity_type][]"]')[i].value = '';
    $('input[name="processing_event[processing_activity_software][]"]')[i].value = '';
    $('input[name="processing_event[processing_activity_description][]"]')[i].value = '';
  }

  // validate the step values
  if (processingActivity.length == 0) {
    // no need to validate if there is no processingActivity
    return true;
  } else if (!stepsValid(steps.sort())) {
    alert('Please select the processing steps in sequence.');
    return false;
  } else {
    return true;
  }

}

// Puts concatenated values into processingActivityHolder on submit.
function buildTargetField(inputValue, targetGroupUl) {
  var li = document.createElement('li');
  var input = document.createElement('input');
  input.className = 'string multi_value optional processing_event_processing_activity form-control multi-text-field';
  input.setAttribute("id", "processing_event_processing_activity");
  input.setAttribute("name", "processing_event[processing_activity][]");
  input.value = inputValue;

  li.appendChild(input);
  targetGroupUl.appendChild(li);
}

var setNewProcessingActivityStep = function() {
  var processingActivityCount = $('select[name="processing_event[processing_activity_type][]"]').length;
  var steps = [];
  for (var i = 0; i < processingActivityCount-1; i++) {
    var processingActivityStep = $('select[name="processing_event[processing_activity_step][]"]')[i].value || '';
    processingActivityStep = parseInt(processingActivityStep);
    steps.push(processingActivityStep);
  }
  var newStepValue = Math.max.apply(Math, steps) + 1;
  // set the last PA step number to the new value
  $('#processing_event_processing_activity_wrapper li.processing_activity_items:last-child select.processing_event_processing_activity_step').val(newStepValue);
}

var processingActivityStepChanged = function() {
  var processingActivityCount = $('select[name="processing_event[processing_activity_type][]"]').length;
  var steps = [];
  for (var i = 0; i < processingActivityCount; i++) {
    var processingActivityStep = $('select[name="processing_event[processing_activity_step][]"]')[i].value || '';
    processingActivityStep = parseInt(processingActivityStep);
    steps.push(processingActivityStep);
  }
  // validate the step values
  if (!stepsValid(steps.sort())) {
    alert('Please select the processing steps in sequence.');
    $('input[type="submit"], button[type="submit"]').attr("disabled", true);
  } else {
    $('input[type="submit"], button[type="submit"]').attr("disabled", false);
  }

};

function stepsValid(steps) {
  var expectedSteps = [];
  for (var i = 1; i <= steps.length; i++) {
     expectedSteps.push(i);
  }
  return (steps.equals(expectedSteps));
}

// define an array compare function
// Warn if overriding existing method
if(Array.prototype.equals)
    console.warn("Overriding existing Array.prototype.equals. Possible causes: New API defines the method, there's a framework conflict or you've got double inclusions in your code.");
// attach the .equals method to Array's prototype to call it on any array
Array.prototype.equals = function (array) {
    // if the other array is a falsy value, return
    if (!array)
        return false;

    // compare lengths - can save a lot of time
    if (this.length != array.length)
        return false;

    for (var i = 0, l=this.length; i < l; i++) {
        // Check if we have nested arrays
        if (this[i] instanceof Array && array[i] instanceof Array) {
            // recurse into the nested arrays
            if (!this[i].equals(array[i]))
                return false;
        }
        else if (this[i] != array[i]) {
            // Warning - two different object instances will never be equal: {x:20} != {x:20}
            return false;
        }
    }
    return true;
}
// Hide method from for-in loops
Object.defineProperty(Array.prototype, "equals", {enumerable: false});
