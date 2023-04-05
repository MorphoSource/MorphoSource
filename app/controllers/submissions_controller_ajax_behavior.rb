# Collection of similar AJAX methods for work creation
module SubmissionsControllerAjaxBehavior
  extend ActiveSupport::Concern

  included do
    before_action :initialize_submission, only: [:new_processing_event_submit]
  end

  # AJAX Physical object and media edit page submission methods
  def new_organization_submit
    # this method is expected to be called from a form in modal, or an ajax post
    begin
      new_organization_id = prepare_and_create_work('organization', { 'organization' => params[:organization] })[0]
    rescue
      new_organization_id = nil
    end

    if new_organization_id.present?
      status = 'OK'
      message = 'New organization created'
      new_organization = Organization.where('id' => new_organization_id).first
      new_work = {
        :id => new_organization_id,
        :title => new_organization.title.first,
        :institution_code => new_organization.institution_code.first,
        :institution_name => new_organization.institution_name.first,
        :collection_code => new_organization.collection_code.first,
        :description => new_organization.description.first,
        :related_url => new_organization.related_url.first,
        :address => new_organization.address.first,
        :city => new_organization.city.first,
        :state_province => new_organization.state_province.first,
        :postal_code => new_organization.postal_code.first,
        :country => new_organization.country.first
      }
    else
      status = 'FAIL'
      message = 'There is a problem creating the organization.'
      new_work = {}
    end
    response_object = {
      :work => new_work,
      :status => status,
      :message => message
    }
    render :json => response_object
  end

  def new_taxonomy_submit
    # this method is expected to be called from a form in modal, or an ajax post
    begin
      new_taxonomy_id = prepare_and_create_work('taxonomy', { 'taxonomy' => params[:taxonomy] })[0]
    rescue
      new_taxonomy_id = nil
    end

    if new_taxonomy_id.present?
      status = 'OK'
      message = 'New Taxonomy created'
      new_taxonomy = Taxonomy.where('id' => new_taxonomy_id).first
      new_work = {
        :id => new_taxonomy_id,
        :title => new_taxonomy.title.first,
        :taxonomy_domain => new_taxonomy.taxonomy_domain.first,
        :taxonomy_kingdom => new_taxonomy.taxonomy_kingdom.first,
        :taxonomy_phylum => new_taxonomy.taxonomy_phylum.first,
        :taxonomy_superclass => new_taxonomy.taxonomy_superclass.first,
        :taxonomy_class => new_taxonomy.taxonomy_class.first,
        :taxonomy_subclass => new_taxonomy.taxonomy_subclass.first,
        :taxonomy_superorder => new_taxonomy.taxonomy_superorder.first,
        :taxonomy_order => new_taxonomy.taxonomy_order.first,
        :taxonomy_suborder => new_taxonomy.taxonomy_suborder.first,
        :taxonomy_superfamily => new_taxonomy.taxonomy_superfamily.first,
        :taxonomy_family => new_taxonomy.taxonomy_family.first,
        :taxonomy_subfamily => new_taxonomy.taxonomy_subfamily.first,
        :taxonomy_tribe => new_taxonomy.taxonomy_tribe.first,
        :taxonomy_genus => new_taxonomy.taxonomy_genus.first,
        :taxonomy_subgenus => new_taxonomy.taxonomy_subgenus.first,
        :taxonomy_species => new_taxonomy.taxonomy_species.first,
        :taxonomy_subspecies => new_taxonomy.taxonomy_subspecies.first,
        :depositor => new_taxonomy.depositor
      }
    else
      status = 'FAIL'
      message = 'There is a problem creating the taxonomy.'
      new_work = {}
    end
    response_object = {
      :work => new_work,
      :status => status,
      :message => message
    }
    render :json => response_object
  end

  def new_device_submit
    # this method is expected to be called from a form in modal, or an ajax post
    begin
      new_device_id = prepare_and_create_work('device', { 'device' => params[:device] })[0]
    rescue Exception => ex
      new_device_id = nil
      exception_message = "Exception: #{ex.class}, #{ex.message}"
    end
    if new_device_id.present?
      status = 'OK'
      message = 'New device created'
      new_device = Device.where('id' => new_device_id).first
      new_work = {
        :id => new_device_id,
        :title => new_device.title.first,
        :creator => new_device.creator.first,
        :modality => new_device.modality.first,
        :description => new_device.description.first,
        :organization_institution => organization_institution(new_device_id)
      }
    else
      status = 'FAIL'
      message = 'There is a problem creating the device. ' + exception_message
      new_work = {}
    end
    response_object = {
      :work => new_work,
      :status => status,
      :message => message
    }
    render :json => response_object
  end

  def new_processing_event_submit
    handle_ajax_submit do
      new_processing_event_id = prepare_and_create_work('processing_event', { 'processing_event' => params[:processing_event] })[0]
      if new_processing_event_id.present?
        new_processing_event = ProcessingEvent.find(new_processing_event_id)

        if params['child_media_id'].present?
          # update the child media (by setting this PE as a parent)
          # child < PE < parent
          child_media_id = params['child_media_id']
          child_media = Media.find(child_media_id)

          # if the child media has other parents, remove relationship
          previous_parents = child_media.member_of
          previous_parents.each do |parent|
            parent.ordered_members.delete(child_media)
            parent.members.delete(child_media)
            parent.save!

            # if parent is IE with no other children, delete IE
            if parent.imaging_event? && !parent.reload.members.present?
              parent.destroy
            end
          end
          
          new_processing_event.ordered_members << child_media
          new_processing_event.save!
          child_media.save!
          new_processing_event_updates(child_media)
        end

        response_object = {
          status: 'success',
          work: {
            :id => new_processing_event_id,
            :title => new_processing_event.title.first
          },
          message: 'New processing_event created'
        }
      else
        raise "Unexpected error creating processing event work"
      end
    end
  end

  private

  def initialize_submission
    @submission = Submission.new()
  end

  # Simple AJAX request handler, ensures more JSend-compliant (not 100%) repsonse
  # Specific methods should implement logic as block for this method
  def handle_ajax_submit
    response_object = yield

    # HTTP 200 if no exception raised from yield
    status_code = 200

    # basic failure if response not provided
    if !response_object.present?
      response_object = {
        status: 'fail',
        work: {},
        message: 'Unknown failure'
      }
    end
  rescue Exception => ex
    response_object = {
      status: 'error',
      work: {},
      message: "Exception #{ex.class}: #{ex.message}",
      code: 500
    }
    status_code = 500
  ensure
    render json: response_object, status: status_code
  end
end