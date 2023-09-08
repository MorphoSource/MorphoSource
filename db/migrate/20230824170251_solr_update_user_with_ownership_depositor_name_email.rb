class SolrUpdateUserWithOwnershipDepositorNameEmail < ActiveRecord::Migration[5.2]
  def up
    users = User.where(guest: false).map { |u| [u.user_key, u] }.to_h
    media_docs = ActiveFedora::SolrService.query("has_model_ssim:Media", rows: 999_999)
    media_docs.each do |doc|
      new_doc = doc.to_h

      # Data manager name and email
      user_with_ownership_user = users[doc["user_with_ownership_ssi"]]
      user_with_ownership_name = user_with_ownership_user&.name || "Unknown User"
      new_doc['user_with_ownership_name_tesim'] = user_with_ownership_name
      new_doc['user_with_ownership_name_ssim'] = user_with_ownership_name
      user_with_ownership_email = user_with_ownership_user&.email
      new_doc['user_with_ownership_email_tesim'] = user_with_ownership_email
      new_doc['user_with_ownership_email_ssim'] = user_with_ownership_email

      # Depositor name and email
      depositor_user = users[doc["depositor_ssim"]&.first]
      depositor_name = depositor_user&.name || "Unknown User"
      depositor_email = depositor_user&.email
      new_doc['depositor_name_tesim'] = depositor_name
      new_doc['depositor_name_ssim'] = depositor_name
      new_doc['depositor_email_tesim'] = depositor_email
      new_doc['depositor_email_ssim'] = depositor_email

      # Commit new_doc to Solr
      ActiveFedora::SolrService.add(new_doc, softCommit: true)
    end
  end

  def down
    users = User.where(guest: false).map { |u| [u.user_key, u] }.to_h
    media_docs = ActiveFedora::SolrService.query("has_model_ssim:Media", rows: 999_999)
    media_docs.each do |doc|
      new_doc = doc.to_h

      # Data manager name and email
      user_with_ownership_user = users[doc["user_with_ownership_ssi"]]
      user_with_ownership_name = user_with_ownership_user&.name_and_email
      new_doc['user_with_ownership_name_tesim'] = user_with_ownership_name
      new_doc['user_with_ownership_name_ssim'] = user_with_ownership_name
      new_doc['user_with_ownership_email_tesim'] = nil
      new_doc['user_with_ownership_email_ssim'] = nil

      # Depositor name and email
      depositor_user = users[doc["depositor_ssim"]&.first]
      depositor_name = depositor_user&.name_and_email
      new_doc['depositor_name_tesim'] = depositor_name
      new_doc['depositor_name_ssim'] = depositor_name
      new_doc['depositor_email_tesim'] = nil
      new_doc['depositor_email_ssim'] = nil

      # Commit new_doc to Solr
      ActiveFedora::SolrService.add(new_doc, softCommit: true)
    end
  end
end
