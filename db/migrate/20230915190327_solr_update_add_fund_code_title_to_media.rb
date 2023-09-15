class SolrUpdateAddFundCodeTitleToMedia < ActiveRecord::Migration[5.2]
  def up
    # Add field active_fund_code_title_ssim to Media

    active_fund_code_associations = FundCodeMediaAssociation
      .joins(:fund_code)
      .select('fund_code_media_associations.*, fund_codes.title, fund_codes.description')
      .where(active: true)
      .all
    media_to_fc = active_fund_code_associations.each_with_object({}) do |fc, hsh|
      hsh[fc.media] = fc
    end

    media_docs = ActiveFedora::SolrService.query("has_model_ssim:Media", rows: 999_999)
    media_docs.each do |doc|
      fund_code_title = media_to_fc[doc["id"]]&.title || "MorphoSource"
      ActiveFedora::SolrService.add(
        {
          "id" => doc["id"],
          "active_fund_code_title_ssim" => { "set" => fund_code_title },
        },
        softCommit: true
      )
    end
  end

  def down
    # Remove field active_fund_code_title_ssim from Media

    media_docs = ActiveFedora::SolrService.query("has_model_ssim:Media", rows: 999_999)
    media_docs.each do |doc|
      ActiveFedora::SolrService.add(
        {
          "id" => doc["id"],
          "active_fund_code_title_ssim" => { "set" => nil },
        },
        softCommit: true
      )
    end
  end
end
