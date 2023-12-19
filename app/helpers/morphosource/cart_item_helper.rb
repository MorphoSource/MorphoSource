module Morphosource::CartItemHelper

  def media
    @curation_concern
  end

  # media showcase download button options
  def choose_download_button
    if current_user
      if user_can_download?
        download_button
      elsif media.restricted_download?
        if requested_by_user?
          download_requested_button
        else
          request_download_button
        end
      end
    else
      choose_guest_download_button
    end
  end

  # media is open, user has been granted download access, or has an approved download request
  def user_can_download?
    return true if current_user.can? :download, media
    return true if current_user.my_approved_requests_work_ids.include?(media.id)
    false
  end

  def requested_by_user?
    current_user.my_active_requests_work_ids.include?(media.id)
  end

  def choose_guest_download_button
    if media.restricted_download?
      disabled_request_download_button
    else
      disabled_download_button
    end
  end

  # media showcase cart button options
  # if a user is not signed in, show the disabled buttons
  # if the media is open or restricted download, show the 'add to cart' or 'in cart' buttons
  # if the media is private:
    # if the user can edit or download, show the 'add to cart' or 'in cart' buttons
    # if the user can view only, show nothig
  def choose_cart_button
    if !current_user
      disabled_cart_button
    elsif !media.private? || current_user.can?(:download, media)
      if media_in_cart?
        in_cart_button
      else
        add_to_cart_button
      end
    end
  end

  def media_in_cart?
    current_user.work_ids_in_cart.include? media.id
  end

  def edit_work_button
    link_to "Edit", edit_polymorphic_path([main_app, media]), class: 'btn btn-default'
  end

  def download_button
    mediaId = media&.id || ''
    link_to t('hyrax.file_sets.actions.download'), 'javascript:void(0)', class: 'btn btn-default btn-download-item', id: 'btn-download-item', data: { media_id: mediaId }
  end

  def download_requested_button
    link_to 'DL Request Sent', 'javascript:void(0)', class: 'btn btn-default', role: 'button', disabled: true
  end

  def request_download_button
    mediaId = media&.id || ''
    button_tag("Request Download", class: 'btn btn-default btn-request-download-item', id: 'btn-request-download-item', data: {toggle: 'modal', target: '#pageModal', work_id: mediaId, media_id: mediaId})
  end

  def disabled_request_download_button
    link_to "Request Download", 'javascript:void(0)', class: 'btn btn-default', role: 'button', disabled: true
  end

  def disabled_download_button
    link_to "Download", 'javascript:void(0)', class: 'btn btn-default', role: 'button', style: 'flex-grow: 1;' ,disabled: true
  end

  def in_cart_button
    link_to "Item in Cart", main_app.my_cart_path, class: 'btn btn-default'
  end

  def add_to_cart_button
    link_to "Add to Cart", main_app.add_to_cart_path(work_id: media.id), class: 'btn btn-default', method: :post
  end

  def disabled_cart_button
    link_to "Add to Cart", 'javascript:void(0)', class: 'btn btn-default', role: 'button', style: 'flex-grow: 1;', disabled: true
  end

  # No longer used
  def unavailable_for_download_button
    link_to 'Download Unavailable','', class: 'btn btn-default', role: 'button', disabled: true
  end

  # When user is not signed in, appears below disabled download/cart buttons
  def login_message
    (link_to 'Login', main_app.new_user_session_path) + ' or ' + (link_to 'create an account', main_app.new_user_registration_path) + ' to download files'
  end

  # provide status label <span> element
  # arguments: label text, class, style
  def item_status_label(item)
    case item.request_status
    when 'Canceled'
      make_label("Canceled","label label-danger","background-color: gray;")
    when 'Denied'
      make_label("Denied","label label-danger",'')
    when 'Expired'
      make_label("Expired","label label-warning","background-color: orange;")
    when 'Approved'
      make_label("Approved","label label-success",'')
    when 'Cleared'
      make_label("Cleared","label label-info",'')
    when 'Requested'
      make_label("Requested","label label-primary",'')
    else
      make_label("Not Requested",'label label-info',"background-color: teal;")
    end
  end

  # get the date associated with the most appropriate non-requested non-expired status
  def item_status_date(item)
    case item.request_status
    when 'Canceled'
      date(item, 'canceled')
    when 'Denied'
      date(item, 'denied')
    when 'Expired'
      # presumably all expired requests were approved at some point
      date(item, 'approved')
    when 'Approved'
      date(item, 'approved')
    when 'Cleared'
      date(item, 'cleared')
    end
  end

  # provide action button
  # arguments: item, button text, button class, http method, style
  def item_action_button(item)
    if item.downloadable?
      if item.request_status == "Approved"
        if !item.in_cart
          make_button(item,"Add to Cart",:move_to_cart_path,"btn btn-success",:put,'')
        else
          content_tag(:button, 'Item in Cart', class: "btn btn-success", disabled: true)
        end
      elsif item.request_status != "Denied" &&
        item.request_status != "Canceled" &&
        item.request_status != "Expired"
          make_download_button(item)
      end
    else
      case item.request_status
      when 'Approved'
        if !item.in_cart
          make_button(item,"Add to Cart",:move_to_cart_path,"btn btn-success",:put,'')
        else
          content_tag(:button, 'Item in Cart', class: "btn btn-success", disabled: true)
        end
      when 'Canceled'
        button_tag("Request Download", id:'request-button', class: 'btn btn-info btn-request-download-item', data: {toggle: 'modal', target: '#pageModal', item_id: item.id})
      when 'Denied'
        if item.in_cart
          make_button(item,"Remove from Cart",:remove_items_path,"btn btn-danger",:delete,'')
        else
          content_tag(:span)
        end
      when 'Expired'
        make_button(item,"Request Again",:request_again_path,"btn btn-primary",:get,'')
      when 'Cleared'
       button_tag("Request Download", id:'request-button', class: 'btn btn-info btn-request-download-item', data: {toggle: 'modal', target: '#pageModal', item_id: item.id})
      when 'Requested'
        make_button(item,"Cancel",:cancel_request_path,"btn btn-danger",:put,"background-color: gray;")
      else
        button_tag("Request Download", id:'request-button', class: 'btn btn-info btn-request-download-item', data: {toggle: 'modal', target: '#pageModal', item_id: item.id, media_id: item.work_id})
      end
    end
  end

  def make_label(text,label,style)
    content_tag(:span, text, class: label, style: style)
  end

  def make_button(item,text,path,button_class,method,style)
    link_to text, main_app.send(path, item_id: item.id), class: button_class, style: style, method: method
  end

  def make_download_button(item)
    tags = ""
    media = Media.find(item.work_id)
    if media.present?
      if media.file_sets.present?
        tags = ( button_tag("Download Item", class: "btn-download-item btn btn-info btn-xs", data: {item_id: item.id}) ) +
          ( link_to item.id, main_app.download_items_path(item_id: item.id), class: "hide", id: 'link-to-download-item-'+item.id.to_s, method: :get )
      end
    end
    return tags
  end

  def date(item,attribute)
    attribute = 'date_'.concat(attribute).to_sym
    item.send(attribute)&.strftime("%Y-%m-%d")
  end

  def action_by(item)
    return if item.action_by.nil?

    user = User.find_by(ms_id: item.action_by)
    return if user.nil?

    user.name
  end

  def get_requester_items(items,requester)
    @requester_items = items.select{|item| item.user_id == requester.ms_id}
    @requester_agreed_to_terms = @requester_items.all? { |item| item['download_request_terms_agreement'] == true }
  end

  def requester_uses
    @requester_items.map{|item| item.use }.uniq
  end

  def use_requests(items,use)
    items.select{|item| item.use == use }
  end

  def find_document(docs,item)
    docs.find{ |doc| doc[:id] == item.work_id }
  end

  def editable_use_requests(items,use)
    items.select{|item| (item.use == use && item.editable?)}
  end

  def page
    path = request.fullpath
    case
    when path.include?('cart')
      'cart'
    when path.include?('previous_requests')
      'previous_requests'
    when path.include?('requests')
      'requests'
    when path.include?('request_manager')
      'request_manager'
    when path.include?('downloads')
      'downloads'
    when path.include?('media')
      'showcase'
    end
  end

  def editable_items(items)
    items.select(&:editable?)
  end

  def object_details(media_doc)
    title = ""
    taxonomy = ""
    if media_doc.physical_object_id.present?
      obj = SolrDocument.find(media_doc.physical_object_id)
      title = obj.title.first
      if obj.specimen?
        type = "bso"
        if obj.taxonomy_id.present?
          taxonomy = SolrDocument.find(obj.taxonomy_id.first)&.title&.first
        end
      else # CHO
        type = "cho"
      end
    end
    return type, title, taxonomy
  end

  def requester_title(requester)
    if requester.display_name.present?
      requester.display_name
    else
      requester.email + " (display name not entered by user)"
    end
  end

end
