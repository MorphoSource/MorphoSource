// Based on code from ms_media_form
$( document ).ready(function() {

  if ($('form[id*="edit_organization"]').length) { // if team organization edit form tab

    // TODO: investigate why extra media rights holder wrapper is showing up. Just delete for now.
    // mediaRightsHolder = document.getElementById('media_rights_holder_wrapper')
    // mediaRightsHolder.parentNode.removeChild(mediaRightsHolder);

    // form = $('form[id*="edit_organization"]')[0];

    // concatenate rights holder name, type to rights holder
    // Check the rightsHolder Field (will be hidden)
    targetGroup = document.querySelector('div.organization_rights_holder');
    targetGroupUl = targetGroup.querySelector("ul");
    concatFields = targetGroupUl.querySelectorAll("input");
    concatFieldCount = (targetGroupUl.querySelectorAll("input").length) - 1;

    // Two part rightsHolder entry
    targetWrapper = document.getElementById("organization_rights_holder_wrapper");
    targetWrapperUl = targetWrapper.querySelector('ul');
    targetWrapperLi = targetWrapper.querySelector('li');

    setupRightsHolder();

    function setupRightsHolder() {

      // When editing a record, this populates the rightsHolder fields with previously saved metadata.
      for (i = 0; i < concatFieldCount; i++) {
        var concatFieldValue = concatFields[i].value;

        var name = concatFieldValue.match(/Name: (.*?), Type: /)[1];
        var type = concatFieldValue.match(/Type: (.*)/)[1];

        // Fill in values for first line
        if (i == 0) {
          var typeSelectOject = $('select[name="organization[rights_holder_type][]"]')[0];
          for (var x = 0; x < typeSelectOject.length; x++){
            if (typeSelectOject.options[x].value == type)
              typeSelectOject.selectedIndex = x;
          }
          $('input[name="organization[rights_holder_name][]"]')[0].value = name;
        } else {
          // Assemble new name, type
          var li = document.createElement('li');
          li.className = 'field-wrapper input-group input-append';
          li.setAttribute('style', "display:flex; flex-direction:row; justify-content:space-evenly;");

          var nameInput = document.createElement('input');
          nameInput.className = "string multi_value optional form-control organization_rights_holder_name form-control multi-text-field";
          nameInput.setAttribute("id", "organization_rights_holder_name");
          nameInput.setAttribute("name", "organization[rights_holder_name][]");
          nameInput.setAttribute("style", "margin:5px; width:50%; border-radius:5px;");
          nameInput.value = name;
          li.appendChild(nameInput);

          $('<select />', {
            id : "organization_rights_holder_type_" + i.toString(),
            name : 'organization[rights_holder_type][]',
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
          span.innerHTML = '<button type="button" class="btn btn-link remove" data-index="' + i.toString() + '"><i class="fa fa-times-circle" aria-hidden="true"></i></button><button type="button" class="btn btn-link add"><i class="fa fa-plus-circle" aria-hidden="true"></i></button>'

          li.appendChild(span);
          targetWrapperUl.appendChild(li);

        }
      }

      // Clear default rightsHolder fields when done.
      targetGroupUl.innerHTML = '';
      $(targetGroup).hide(); // hide the field label and add button

    } // /setupRightsHolder

  } // end if organization form page

})
