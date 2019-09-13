// shared helper functions 

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

// setup embedded work form, when to load the form, submit and close handling
function setupEmbeddedWorkForm(work_name, action, callbackAfterSubmit) {
	var this_btn = "#btn_" + action + '_' + work_name;
	var this_div = "#embedded_div_" + action + '_' + work_name;
	var this_form = "form#" + action + '_' + work_name;
	var this_path = "/submissions/" + action + '_' + work_name;
	var detail_div = '#' + work_name + '_details';

  $(document).on("click", this_btn, function() {		
  	// the new work form button has been clicked	
		$(this_div).addClass('ui-loading').show();
		// hide detail section if any
		$(detail_div).hide();

		$.ajax({
		  url: this_path,
		  success: function(result) {
		  	// new work form has been retrieved in the request
		  	try {
			    $(this_div).html(result);
		  	} catch (e) {
		  		// catching the error " incorrect module build, no module name "
		  		// todo: resolve the error later
		  		// console.log(e);
		  	}
		  	$(this_div).removeClass('ui-loading');		    
		  }
		});
	});

  $(this_div).on("submit", this_form, function() {
  	// the new work form's save button has been clicked
		// replace with ajax form post to trigger other actions
		$.post($(this_form).attr('action'),
	  $(this_form).serialize(), function(data, status){
	    // got the data back after the new work has been created
	    console.log(data.message, data);
			var relationship_element = $(this_div).data("relationship-control");
	  	var relationship_input = $(relationship_element).find('input[name*="[find_parent_work]"]');
			$(relationship_input).val(data.work.id);
			if (work_name == 'institution') {
				var new_data = {
					id: data.work.id, 
					text: data.work.title,
					institution_code: data.work.institution_code,
	        description: data.work.description,
	        address: data.work.address, 
	        city: data.work.city, 
	        state_province: data.work.state_province,
	        country: data.work.country
				};
			} else if (work_name == 'taxonomy') {
				console.log('in taxonomy '+data.work.taxonomy_kingdom)
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
			} else {
				var new_data = {
					id: data.work.id, 
					text: data.work.title
				};
			}
	    $(relationship_element).data('new-work-created', new_data);
			var relationship_add_btn = $(this_div).data("add-button");
			$(relationship_add_btn).trigger("click");

			// perform any on-the-fly form update after new work has been created
			if(callbackAfterSubmit) callbackAfterSubmit();

			$(this_div).hide();
			$(detail_div).show();
	  });
	  
		$(this_div).addClass('ui-loading');
		//$(this_div).hide();
   	$(this_div).html('');
		return false;
  });
  $(this_div).on("click", ".cancel", function() {
		$(this_div).hide();
   	$(this_div).html('');
		$(detail_div).show();
  });
}
