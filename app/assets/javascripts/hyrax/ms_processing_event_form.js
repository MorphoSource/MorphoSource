$(document).on('turbolinks:load', function() {
  if ($('form[id*="processing_event"]').length) { // if PE form page
  	hide_fields(['.processing_event_processing_activity']);
    
    // concatenate rights holder name, type to rights holder
    var form = $('form[id*="processing_event"]')[0];

    // Check the processingActivity Field (will be hidden)
    var targetGroup = document.querySelector('div.processing_event_processing_activity');
    var targetGroupUl = targetGroup.querySelector("ul");
    var concatFields = targetGroup.querySelectorAll("input");
    var concatFieldCount = (targetGroup.querySelectorAll("input").length) - 1;

    // Two part processingActivity entry
    var targetWrapper = document.getElementById("processing_event_processing_activity_wrapper");
    var targetWrapperUl = targetWrapper.querySelector('ul');
    var targetWrapperLi = targetWrapper.querySelector('li');

    // remove the first set of fields if in editing (not adding) mode
    if (concatFieldCount > 0) {
      $(targetWrapperUl).children("li").remove();
    }

    // When editing a record, this populates the individual fields with previously saved metadata.
    for (i = 0; i < concatFieldCount; i++) {
      var concatFieldValue = concatFields[i].value;
      //console.log('concatFieldValue: '+concatFieldValue);

      var step = concatFieldValue.match(/^Step: ([0-9]+), Type: /)[1];
      var type = concatFieldValue.match(/, Type: (.*), Software: /)[1];
      var software = concatFieldValue.match(/, Software: (.*), Description: /)[1];
      var description = concatFieldValue.match(/, Description: (.*)/)[1];

      // Assemble new triple fields
      var li = document.createElement('li');
      li.className =  'field-wrapper input-group input-append';
      li.setAttribute('style', "display:flex; flex-direction:row; justify-content:space-evenly;");
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
      softwareInput.setAttribute("style", "margin:5px; width:23%; border-radius:5px;");
      softwareInput.value = software;
      li.appendChild(softwareInput);

      var descriptionInput = document.createElement('input');
      descriptionInput.className = "string multi_value optional form-control processing_event_processing_activity_description form-control multi-text-field";
      descriptionInput.setAttribute("id", "processing_event_processing_activity_description");
      descriptionInput.setAttribute("name", "processing_event[processing_activity_description][]");
      descriptionInput.setAttribute("style", "margin:5px; width:33%; border-radius:5px;");
      descriptionInput.value = description;
      li.appendChild(descriptionInput);

      var span = document.createElement('span');
      span.className = "input-group-btn field-controls";
      span.innerHTML = `<button type="button" class="btn btn-link remove">
                          <span class="glyphicon glyphicon-remove"></span>
                          <span class="controls-remove-text">Remove</span>
                          <span class="sr-only"> previous
                            <span class="controls-field-name-text"> processing_event</span>
                          </span>
                        </button>`

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
    targetGroupUl.innerHTML = '';
    $(targetGroup).hide(); // hide the field label and add button

    // On submit, the three fields are concatenated and inserted into hidden default processing activity field.
    form.addEventListener("submit", function() {

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
      if (!stepsValid(steps.sort())) {
        alert('Please select the steps in sequence.');
        event.preventDefault();
      } 

    });

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


  } // end if PE form page
})


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
    alert('Please select the steps in sequence.');
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
