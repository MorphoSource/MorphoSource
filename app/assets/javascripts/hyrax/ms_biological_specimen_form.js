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

    function taxonomy_short_title(t) {
      ranks = [t.taxonomy_genus, t.taxonomy_subgenus, t.taxonomy_species, t.taxonomy_subspecies];
      title = ranks.join(' ');
      if (title.replace(/\s/g,'') != '')
        return title;
      else
        return "(no title)";
    }

    function populate_taxonomy(label, t) {
      //console.log(label, t);
      var labelClass = "#modal-idigbio-result ." + label;
      $(labelClass + ' .taxonomy-title').html(taxonomy_short_title(t));
      $(labelClass + ' .taxonomy-domain').html(t.taxonomy_domain);
      $(labelClass + ' .taxonomy-kingdom').html(t.taxonomy_kingdom);
      $(labelClass + ' .taxonomy-phylum').html(t.taxonomy_phylum);
      $(labelClass + ' .taxonomy-superclass').html(t.taxonomy_superclass);
      $(labelClass + ' .taxonomy-class').html(t.taxonomy_class);
      $(labelClass + ' .taxonomy-subclass').html(t.taxonomy_subclass);
      $(labelClass + ' .taxonomy-superorder').html(t.taxonomy_superorder);
      $(labelClass + ' .taxonomy-order').html(t.taxonomy_order);
      $(labelClass + ' .taxonomy-suborder').html(t.taxonomy_suborder);
      $(labelClass + ' .taxonomy-superfamily').html(t.taxonomy_superfamily);
      $(labelClass + ' .taxonomy-family').html(t.taxonomy_family);
      $(labelClass + ' .taxonomy-subfamily').html(t.taxonomy_subfamily);
      $(labelClass + ' .taxonomy-tribe').html(t.taxonomy_tribe);
      $(labelClass + ' .taxonomy-genus').html(t.taxonomy_genus);
      $(labelClass + ' .taxonomy-subgenus').html(t.taxonomy_subgenus);
      $(labelClass + ' .taxonomy-species').html(t.taxonomy_species);
      $(labelClass + ' .taxonomy-subspecies').html(t.taxonomy_subspecies);
    }

    function search_idigbio(occurrence_id) {
      $.ajax({
        url: '/search_idigbio_by_occurrence_id_ajax/' + occurrence_id,
        type: 'GET',
        dataType: 'json',
        timeout: 5000,
        complete: function(xhr, status) {
          if (status != "success") {
            console.log(" status returned: " + status + ", saving... ");
            saveSpecimen();
          } else {
            var results = $.parseJSON(xhr.responseText);
            if (jQuery.isEmptyObject(results) || results.idb_records.length == 0) {
              console.log(" no match from IDB, saving... ");
              saveSpecimen();
            } else if (results.idb_records.length > 1) {
              idb_records = results.idb_records;
              var li = "";
              $(idb_records).each(function() {
                li += '<li><a href="//www.idigbio.org/portal/records/' + $(this)[0].uuid + '" target="_blank" id="idb-link">iDigBio UUID ' + $(this)[0].uuid + '</a> <span class="glyphicon glyphicon-new-window"></span></li>';
              });
              $('#idb-records').append(li);
              $('#modal-idigbio-multi-result').modal();
              enablePage();
              $(document).on('click', '#modal-idigbio-multi-result #btn-save', function(){
                $('#modal-idigbio-multi-result').modal('hide');
                saveSpecimen();
              });
              $("#modal-idigbio-multi-result").on("hidden.bs.modal", function () {
                $('#idb-records').html('');
              });
            } else if (results.idigbio_uuid == $('#existing_idigbio_uuid').val()) {
              console.log(" idigbio_uuid is the same as existing, saving... ");
              saveSpecimen();
            } else if ( ($('#organization-recordset-id').val() != '') && (results.idigbio_recordset_id != $('#organization-recordset-id').val()) ) {
              $('#modal-idigbio-recordset-not-match').modal();
              enablePage();
              $(document).on('click', '#modal-idigbio-recordset-not-match #btn-save', function(){
                $('#modal-idigbio-recordset-not-match').modal('hide');
                saveSpecimen();
              });
            } else {
              console.log("Match from IDB: ", results);
              $('#modal-idigbio-result #institution-code').html(results.institution_code);
              $('#modal-idigbio-result #collection-code').html(results.collection_code);
              $('#modal-idigbio-result #catalog-number').html(results.catalog_number);
              $('#modal-idigbio-result #idb-link').attr("href", "//www.idigbio.org/portal/records/" + results.idigbio_uuid);
              
              if (results.taxonomy.provider != null) {
                populate_taxonomy('Provider', results.taxonomy.provider);
              }
              if (results.taxonomy.gbif != null) {
                populate_taxonomy('GBIF', results.taxonomy.gbif);
              }

              $('#modal-idigbio-result').modal();
              enablePage();
              $(document).on('click', '#modal-idigbio-result #btn-save', function(){
                $('#modal-idigbio-result').modal('hide');
                saveSpecimen();
              });
            }
          }
        }
      });
    }

    function saveSpecimen() {
      disablePage();
      $('form[data-param-key="biological_specimen"]').submit();
    }
	  
    $(document).on('click', '#btn-save-bso', function(){
			disablePage();
      // search iDigBio if occurrence_id has been changed
      if ($('#biological_specimen_occurrence_id').val() != $('#existing_occurrence_id').val()) {
        search_idigbio($('#biological_specimen_occurrence_id').val());
      } else {
        $('form[data-param-key="biological_specimen"]').submit();
      }
		})

  }
});