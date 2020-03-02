// shared helper functions 

function disablePageAndSave(btn) {
  $(btn).prop('disabled', true).val('Saving...');
  disablePage();
}

function enablePageAndSave(btn) {
  $(btn).prop('disabled', false).val('Save');
  enablePage();
}

function disablePage() {
  // Create overlay and append to body:
	if ($('#overlay-whole-page').length) {

	} else {
	  $('<div id="overlay-whole-page" class="ui-loading-whole-page"/>').css({
	      position: 'fixed',
	      top: 0,
	      left: 0,
	      width: '100%',
	      height: $(window).height() + 'px'
	  }).hide().appendTo('body'); 
	}
  $('#overlay-whole-page').show();
}

function enablePage() {
	if ($('#overlay-whole-page').length)
	  $('#overlay-whole-page').hide();
}

function toTitleCase(str) {
  return str.replace(/(?:^|\s)\w/g, function(match) {
    return match.toUpperCase();
  });
}

// functions for show/edit fields
function show_fields(field_array) {
  $(field_array.join(',')).removeClass('hide');
}

function hide_fields(field_array, clear = true) {
  $(field_array.join(',')).addClass('hide');
  if (clear) {
    $(field_array.join(',')).children('input, select').val('');
  }
}

function depositorLink(email) {
  // url example: /users/johndoe@gmail-dot-com
  return "/users/" + email.replace(/(.+)@([^.]+)\.(.+)/, '$1@$2-dot-$3')
}

function reloadPage() {
  window.location.reload();
}

// setup embedded work form, when to load the form, submit and close handling
function setupEmbeddedWorkForm(work_name, action, submit_only, callbackAfterSubmit) {
	var this_btn = "#btn_" + action + '_' + work_name;
	var this_div = "#embedded_div_" + action + '_' + work_name;
	var this_form = "form#" + action + '_' + work_name;
	//var this_path = "/submissions/" + action + '_' + work_name;
	var detail_div = '#' + work_name + '_details';

  $(document).on("click", this_btn, function() {		
  	// the new work form button has been clicked	
		$(this_div).show();
	});

  $(this_div).on("submit", this_form, function() {
  	// the new work form's save button has been clicked
 		console.log(this_div + ' submitting new work form : ' + $(this_form).attr('action') );
		$(this_div).addClass('ui-loading');
		$('.btn').addClass('disabled');

		// replace with ajax form post to trigger other actions
		$.post($(this_form).attr('action'),
	  $(this_form).serialize(), function(data, status){
	    // got the data back after the new work has been created
	    //console.log("ms_helper, after post: ", data.message, data);
			var relationship_element = $(this_div).data("relationship-control");
	  	var relationship_input = $(relationship_element).find('input[name*="[find_parent_work]"]');
			$(relationship_input).val(data.work.id);
			if (work_name == 'organization') {
				var new_data = {
					id: data.work.id, 
					text: data.work.title,
					institution_code: data.work.institution_code,
					institution_name: data.work.institution_name,
					collection_code: data.work.collection_code,
	        description: data.work.description,
	        address: data.work.address, 
	        city: data.work.city, 
	        state_province: data.work.state_province,
	        country: data.work.country
				};
			} else if (work_name == 'device') {
				var new_data = {
					id: data.work.id, 
					text: data.work.title,
					creator: data.work.creator,
					modality: data.work.modality,
	        description: data.work.description,
	        organization_institution: data.work.organization_institution
				};
			} else if (work_name == 'taxonomy') {
				var new_data = {
					id: data.work.id, 
					text: data.work.title,
					taxonomy_domain: data.work.taxonomy_domain,
					taxonomy_kingdom: data.work.taxonomy_kingdom,
          taxonomy_phylum: data.work.taxonomy_phylum,
          taxonomy_superclass: data.work.taxonomy_superclass,
          taxonomy_class: data.work.taxonomy_class,
          taxonomy_subclass: data.work.taxonomy_subclass,
          taxonomy_superorder: data.work.taxonomy_superorder,
          taxonomy_order: data.work.taxonomy_order,
          taxonomy_suborder: data.work.taxonomy_suborder,
          taxonomy_superfamily: data.work.taxonomy_superfamily,
          taxonomy_family: data.work.taxonomy_family,
          taxonomy_subfamily: data.work.taxonomy_subfamily,
          taxonomy_tribe: data.work.taxonomy_tribe,
          taxonomy_genus: data.work.taxonomy_genus,
          taxonomy_subgenus: data.work.taxonomy_subgenus,
          taxonomy_species: data.work.taxonomy_species,
          taxonomy_subspecies: data.work.taxonomy_subspecies,
          depositor: data.work.depositor,
          depositor_link: depositorLink(data.work.depositor)
				}
			} else if (work_name == 'biological_specimen') {
				var new_data = {
					id: data.work.id, 
					text: data.work.title,
					bibliographic_citation: data.bibliographic_citation,
					catalog_number: data.catalog_number,
					collection_code: data.collection_code,
					canonical_taxonomy: data.canonical_taxonomy,
					institution_code: data.institution_code,
					latitude: data.latitude,
					longitude: data.longitude,
					numeric_time: data.numeric_time,
					original_location: data.original_location,
					periodic_time: data.periodic_time,
					vouchered: data.vouchered,
					idigbio_recordset_id: data.idigbio_recordset_id,
					idigbio_uuid: data.idigbio_uuid,
					is_type_specimen: data.is_type_specimen,
					occurrence_id: data.occurrence_id,
					sex: data.sex
				}
			} else if (work_name == 'cultural_heritage_object') {
				var new_data = {
					id: data.work.id, 
					text: data.work.title,
					bibliographic_citation: data.bibliographic_citation,
					catalog_number: data.catalog_number,
					collection_code: data.collection_code,
					institution_code: data.institution_code,
					latitude: data.latitude,
					longitude: data.longitude,
					numeric_time: data.numeric_time,
					original_location: data.original_location,
					periodic_time: data.periodic_time,
					vouchered: data.vouchered,
					cho_type: data.cho_type,
					material: data.material,
					short_title: data.short_title
				}
			} else {
				var new_data = {
					id: data.work.id, 
					text: data.work.title
				};
			}

			if (!submit_only) {
				console.log('populating new_data into new-work-created ', new_data)
		    $(relationship_element).data('new-work-created', new_data);
				var relationship_add_btn = $(this_div).data("add-button");
				$(relationship_add_btn).trigger("click");				
			}

			// perform any on-the-fly form update after new work has been created
			if(callbackAfterSubmit) callbackAfterSubmit();

			$(this_div).removeClass('ui-loading').hide();
			$('.btn').removeClass('disabled');
			$(this_div).find('form')[0].reset();
	  });
	  
		return false;
  }); // end submit

  $(this_div).on("click", ".cancel", function() {
  	// might need to loop and reset each form
		$(this_div).find('form')[0].reset();
		$(this_div).not('.persist_with_tab').hide();
		closeLinkedContent(this_div);
  });
}

function closeLinkedContent(thisDiv) {
	var linkedContentBlocks = $(thisDiv).data("linked-content-blocks");
	if (linkedContentBlocks) {
		linkedContentBlocks = linkedContentBlocks.split(',');
		$.each( linkedContentBlocks, function( key, blockSelector ) {
			$(blockSelector).hide();
		})
	}
}

function setupTooltip() {
  $('.tooltip-icon').tooltip({ 
    title: function(){
      return $(this).find('.hint').text() 
    } 
  })
}

function removeLastRepeatable() {
  // remove the last repeatable field for each group
  $('.form-group.multi_value').each(function(i) {
  	// do not remove if there is only one field
    if ($(this).find('.listing .input-group').length > 1) {
	    var lastli = $(this).find('.listing .input-group:last-child');
	    /* remove only:  
	    	either input or select field exists
	    	if input field exists, input must be empty
	    	if select field exists, nothing is selected
	    */
	  	var isRemovable = true;
			var lastInput = lastli.find('input');
			var lastSelect = lastli.find('select');
	    if (lastInput.length && lastInput.val() != '') {
	    	isRemovable = false;
  		}
	    if (lastSelect.length && lastSelect.val() != '') {
	    	isRemovable = false;
  		}
  		if ( (lastInput.length || lastSelect.length) && (isRemovable) ) {
		    lastli.find('.remove').trigger('click');	    	
  		}

    }
  })
	window.scrollTo(0, 0); // scroll back to top of the page since the trigger clicks cause the page to scroll to the middle	
}

function modalityAbbrev(m) {
  switch(m) {
    case 'MicroNanoXRayComputedTomography':
      return 'μCT';
      break;
    case 'MedicalXRayComputedTomography':
      return 'CT'
      break;
    case 'MagneticResonanceImaging':
      return 'MRI'
      break;
    case 'PositronEmissionTomography':
      return 'PET'
      break;
    case 'SynchrotronImaging':
      return 'Synchro'
      break;
    case 'NeutrinoImaging':
      return 'Neutrino'
      break;
    case 'Photogrammetry':
      return 'Photogram'
      break;
    case 'StructuredLight':
      return 'StrLight'
      break;
    case 'LaserScan':
      return 'Laser'
      break;
    case 'ConfocalImageStacking':
      return 'Confocal'
      break;
    case 'Infrared':
    	return 'Infrared'
    	break;
    case 'ReflectanceTransformationImaging':
      return 'RTI'
      break;
    case 'Photography':
      return 'Photo'
      break;
    case 'ScanningElectronMicroscopy':
      return 'SEM'
      break;
    default:
      return 'Etc'; 
 	}
 }  
  
