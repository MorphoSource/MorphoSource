$( document ).ready(function() {
  if ($('form[id*="edit_biological_specimen"]').length) { // if BSO form page

		function updateObjectTitle() {
			var title = [ $('#biological_specimen_institution_code').val(),
													$('#biological_specimen_collection_code').val(),
													$('#biological_specimen_catalog_number').val() ]
			title = $.map( title, function(v){ return v === "" ? null : v; });
			$('#showcase-title').text(title.join(':'));			
		}

    function addTaxonomy(taxonomy) {
      const template = $( $('#new_taxonomy_detail_row')[0].innerHTML );
      if (taxonomy.gbif_key) {
        var label = 'GBIF (Unsaved)';
      } else {
        var label = 'User (Unsaved)';
      }
      template.attr('data-taxonomy-id', taxonomy.id);
      template.attr('data-gbif-key', taxonomy.gbif_key);
      template.find('input').val(taxonomy.id);
      template.find('.taxonomy-label').html(label);
      template.find('.taxonomy-title').html(build_name(taxonomy.name, taxonomy.rank));
      $('#taxonomy_detail_rows').append(template);
    }

    function addNewTaxonomy() {
      var newTaxonomy = $('#parent-relationships-taxonomies').data('new-work-created');
      if (newTaxonomy) {
        newTaxonomy.name = newTaxonomy.text;
        addTaxonomy(newTaxonomy);
      }
    }
    
    function build_name(name, rank) {
      var s = "";
      if (rank) {
        if (rank == 'GENUS' || rank == 'SPECIES' || rank == 'SUBSPECIES') {
          s = s + "<i>" + name + "</i>";
        } else {
          s = s + name;
        }
        s = s + " (" + rank.toLowerCase() + ")";
      } else {
        s = s + "<i>" + name + "</i>";
      }
      return s;
    }

    function build_name_no_formatting(name, rank) {
      var s = name;
      if (rank) {
        s = s + " (" + rank.toLowerCase() + ")";
      }
      return s;
    }

    setupEmbeddedWorkForm('taxonomy', 'new', false, addNewTaxonomy);
    setupEmbeddedWorkForm('organization', 'new', false, updateObjectTitle);
    setupTooltip();
		removeLastRepeatable();
		
    // Select Organization Functions

    // select2-associated select organization button
    $('#btn_select_organization').click(function() {
      var org = $('#s2id_biological_specimen_find_organization').select2('data');
      console.log(org);

      // modify current organization properties
      $('.organization-details #organization-id-value').val(org.id);
      $('.organization-details #organization_type').text(org.organization_type || '');
      $('.organization-details #institution_name').text(org.institution_name || '');
      $('.organization-details #title').text(org.text || '');
      $('.organization-details #institution_code').text(org.institution_code || '');
      $('.organization-details #collection_code').text(org.collection_code || '');
      $('.organization-details #related_url').text(org.related_url || '');
      $('.organization-details #address').text(org.address || '');
      $('.organization-details #city').text(org.city || '');
      $('.organization-details #state_province').text(org.state_province || '');
      $('.organization-details #postal_code').text(org.postal_code || '');
      $('.organization-details #country').text(org.country || '');
      $('.organization-details #contact_person').text(org.contact_person || '');
      $('.organization-details #description').text(org.description || '');

      // modify the form
      $('form.edit_biological_specimen input[name^="biological_specimen[organization_id]"]').remove();
      $('<input />').attr('type', 'hidden')
        .attr('name', 'biological_specimen[organization_id][]')
        .attr('value', org.id )
        .appendTo($('form.edit_biological_specimen')
      );   
    });

		// remove organization when clicking no organization button  
		$('#btn_no_organization').click(function() {
			// modify current organization properties
      $('.organization-details #organization-id-value').val(null);
      $('.organization-details #organization_type').text('');
      $('.organization-details #institution_name').text('');
      $('.organization-details #title').text('');
      $('.organization-details #institution_code').text('');
      $('.organization-details #collection_code').text('');
      $('.organization-details #related_url').text('');
      $('.organization-details #address').text('');
      $('.organization-details #city').text('');
      $('.organization-details #state_province').text('');
      $('.organization-details #postal_code').text('');
      $('.organization-details #country').text('');
      $('.organization-details #contact_person').text('');
      $('.organization-details #description').text('');

      // modify the form
      $('form.edit_biological_specimen input[name^="biological_specimen[organization_id]"]').remove();
      $('<input />').attr('type', 'hidden')
        .attr('name', 'biological_specimen[organization_id][]')
        .attr('value', '' )
        .appendTo($('form.edit_biological_specimen')
      );  
		})

    // Taxonomy select or add functions

    $('#biological_specimen_select_taxonomy_id').autocomplete({
      select: function(event, ui) {
          event.preventDefault();
          console.log(ui.item);
          addTaxonomy(ui.item);
          $(this).val('');
      },
      source: function (request, response) {
        console.log(request);
        $.ajax({
          url: '/submissions/search_taxonomy_ajax?type[]=Taxonomy&id=NA&q=' + request.term,
          type: 'GET',
          dataType: 'json',
          complete: function (xhr, status) {
            var results = $.parseJSON(xhr.responseText);
            var all_t = [];
            var all_g = [];
            $('.taxonomy-accordion-group').each(function() {
              all_t.push($(this).data('taxonomy-id'));
              all_g.push($(this).data('gbif-key'));
            });
            console.log(results);
            console.log(all_t);
            console.log(all_g);
            var new_results = $.map(results, function(r) {
              if (all_t.includes(r.id) || all_g.includes(r.gbif_key) ) {
                return null;
              } else {
                return r;
              }
            });
            console.log(new_results);
            response(new_results);
          }
        });
      },
      autoFocus: false
    }).autocomplete('instance')._renderItem = function(ul, item) {
      // Overwrite default autocomplete list display
      return $(
        "<li><div style='border-bottom: 1px solid #D2D2D2;'>" + 
        build_name(item.name, item.rank) + 
        "<br/><span style='font-size: small;'>" + 
        item.higher_taxonomy + 
        "</span><br/>" +
        item.source_info + 
        "</div></li>"
      ).appendTo(ul);
    };

    $(document).on('click', '#remove-taxonomy', function() {
      $(this).parents('.taxonomy-accordion-group').remove();
    })

		// when selecting taxonomy, hide the new work form if any
		$('[data-behavior="add-relationship"]').click(function() {
			$('.embedded_div').hide();
		})

		// when switching to another tab, hide the new work form from other tab if any
		$('.nav-tabs > li').click(function() {
			if ($(this).find('a[aria-expanded="false"]').length)
				$('.embedded_div').hide();
		})

		// Change title on the fly when corresponding fields are updated
		$('#biological_specimen_institution_code, #biological_specimen_collection_code, #biological_specimen_catalog_number').change(function() {
      updateObjectTitle();
    });

		// change badges on the fly when corresponding fields are updated
		$('#biological_specimen_vouchered').change(function(){
			if ($(this).val() == 'Yes')
				$('#in-collection-badge').text('In Collection');
			else
				$('#in-collection-badge').text('Not in Collection');				
		})


    function search_idigbio(occurrence_id) {

      $.ajax({
        url: '/search_idigbio_by_occurrence_id_ajax/' + occurrence_id,
        type: 'GET',
        dataType: 'json',
        complete: function (xhr, status) {
          var results = $.parseJSON(xhr.responseText);
          console.log(results);
          if (results.idigbio_uuid != $('#existing_idigbio_uuid').val()) {
            alert('idigbio_uuid not match');
          }
        }
      });
    }

	  $(document).on("submit", 'form[data-param-key="biological_specimen"]', function() {
			disablePage();
      if ($('#biological_specimen_occurrence_id').val() != $('#existing_occurrence_id').val()) {
        search_idigbio($('#biological_specimen_occurrence_id').val());

      }

event.preventDefault();

		})

  }
});