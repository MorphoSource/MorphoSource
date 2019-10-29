module Morphosource::CartItemHelper

  def edit_work_button(presenter)
    link_to "Edit", edit_polymorphic_path([main_app, presenter]), class: 'btn btn-default'
  end

  def download_button(id)
    link_to t('hyrax.file_sets.actions.download'), main_app.download_work_path(work_id: [id]), class: 'btn btn-default', download: true, target: "_blank", role: 'button', id: 'file_download', data: { label: id }
  end

  def request_download_button(id)
    button_tag("Request Download", id:'request-button', class: 'btn btn-default', data: {toggle: 'modal', target: '#pageModal', work_id: id})
  end

  def download_requested_button
    link_to 'Download Requested','', class: 'btn btn-default', role: 'button', disabled: true
  end

  def choose_download_button(id)
    if current_user.downloadable_item_work_ids.include?(id)
      download_button(id)
    elsif current_user.my_active_requests_work_ids.include?(id)
      download_requested_button
    else
      request_download_button(id)
    end
  end

  def in_cart_button
    link_to "Item in Cart", main_app.my_cart_path, class: 'btn btn-default'
  end

  def add_to_cart_button(id)
    link_to "Add to Cart", main_app.add_to_cart_path(:work_id => id), class: 'btn btn-default', :method => :post
  end

  def choose_cart_button(presenter)
    if current_user.work_ids_in_cart.include? presenter.id
      in_cart_button
    else
      add_to_cart_button(presenter.id)
    end
  end

  def unavailable_for_download_button
    link_to 'Download Unavailable','', class: 'btn btn-default', role: 'button', disabled: true
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

  # provide action button
  # arguments: item, button text, button class, http method, style
  def item_action_button(item)
    case item.request_status
    when 'Approved'
      if !item.in_cart
        make_button(item,"Add to Cart",:move_to_cart_path,"btn btn-success",:put,'')
      else
        content_tag(:button, 'Item in Cart', class: "btn btn-success", disabled: true)
      end
    when 'Canceled'
      button_tag("Request Download", id:'request-button', class: 'btn btn-info', data: {toggle: 'modal', target: '#pageModal', item_id: item.id})
    when 'Denied'
      if item.in_cart
        make_button(item,"Remove from Cart",:remove_items_path,"btn btn-danger",:delete,'')
      else
        content_tag(:span)
      end
    when 'Expired'
      make_button(item,"Request Again",:request_again_path,"btn btn-primary",:get,'')
    when 'Cleared'
     make_button(item,"Request Download",:request_item_path,"btn btn-info",:put,'')
    when 'Requested'
      make_button(item,"Cancel Request",:cancel_request_path,"btn btn-danger",:put,"background-color: gray;")
    when 'Downloadable'
      make_button(item,"Download Item",:download_items_path,"btn btn-info",:get,'')
    else
      button_tag("Request Download", id:'request-button', class: 'btn btn-info', data: {toggle: 'modal', target: '#pageModal', item_id: item.id})
    end
  end

  def make_label(text,label,style)
    content_tag(:span, text, class: label, style: style)
  end

  def make_button(item,text,path,button_class,method,style)
    link_to text, main_app.send(path, item_id: item.id), class: button_class, style: style, method: method
  end

  def date(item,attribute)
    attribute = 'date_'.concat(attribute).to_sym
    item.send(attribute)&.strftime("%Y-%m-%d")
  end

  def get_requester_items(items,requester)
    @requester_items = items.select{|item| item.user_id == requester.id}
  end

  def requester_uses
    @requester_items.map{|item| item.use }.uniq
  end

  def use_requests(items,use)
    items.select{|item| item.use == use }
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
    items.select{|item| item.editable?}
  end

end
