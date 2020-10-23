// Used for media permissions fields on media edit and team-linked organization edit
$( document ).ready(function() {
  var media_edit_form = $('form[id*="edit_media"]');
  var organization_edit_form = $('form[id*="edit_organization"]');

  if ($('form[id*="edit_organization"]').length) {
    var model = 'organization'
  } else if ($('form[id*="edit_media"]').length) {
    var model = 'media'
  }

  if ( media_edit_form.length || organization_edit_form.length ) {
    console.log('on edit org or media')
    downloadPermission();
  }

  if ( organization_edit_form.length) {
    console.log('on org form')
    setupRightsHolder();
  }

  // Manages the download permission dropdown menu
  // Hidden input is created by morphosource/permissions_helper
  function downloadPermission() {
    $(".download-permission-dropdown a").click(function () {
      console.log('clicked')
        var selectedText = $(this).text();
        var selectedValue = $(this).attr('id');
        var hiddenField = $("[id*='_download_permission']")
        hiddenField.val(selectedValue);
        var spanClass = $(this).find('span').attr('class');
        var span = '<span style="height:110%;" class="' + spanClass + '">';
        $(this).parents('.btn-group').find('.dropdown-toggle').html(span + selectedText + '</span><span class="glyphicon glyphicon-chevron-down" style="font-size:10px; color: black;"></span>');
    });
  }

  // Manages the rights holder fields
  function setupRightsHolder() {
    targetGroup = document.querySelector(`div.${model}_rights_holder`);
    targetGroupUl = targetGroup.querySelector("ul");
    concatFields = targetGroupUl.querySelectorAll("input");
    concatFieldCount = targetGroupUl.querySelectorAll("input").length;

    // Two part rightsHolder entry
    targetWrapper = document.getElementById(`${model}_rights_holder_wrapper`);
    targetWrapperUl = targetWrapper.querySelector('ul');
    targetWrapperLi = targetWrapper.querySelector('li');

    // When editing a record, this populates the rightsHolder fields with previously saved metadata.
    for (i = 0; i < concatFieldCount; i++) {
      var concatFieldValue = concatFields[i].value;

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
        var typeSelectOject = $('select[name="'+`${model}`+'[rights_holder_type][]"]')[0];
        for (var x = 0; x < typeSelectOject.length; x++){
          if (typeSelectOject.options[x].value == type)
            typeSelectOject.selectedIndex = x;
        }
        $('input[name="'+`${model}`+'[rights_holder_name][]"]')[0].value = name;
      } else {
        // Assemble new name, type
        var li = document.createElement('li');
        li.className = 'field-wrapper input-group input-append';
        var nameInput = document.createElement('input');
        nameInput.className = `string multi_value optional form-control ${model}_rights_holder_name form-control multi-text-field`;
        nameInput.setAttribute("id", `${model}_rights_holder_name`);
        nameInput.setAttribute("name", `${model}[rights_holder_name][]`);
        nameInput.value = name;
        li.appendChild(nameInput);

        $('<select />', {
          id : `${model}_rights_holder_type_` + i.toString(),
          name : `${model}[rights_holder_type][]`,
          class : "form-control select optional form-control",
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
})
