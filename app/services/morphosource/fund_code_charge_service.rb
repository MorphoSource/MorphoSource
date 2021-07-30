module Morphosource
  class FundCodeChargeService
    include SolrHelper

    attr_reader :fund_code, :billing_rate, :billing_unit, :media_ids, 
      :filesets_to_media, :fileset_ids, :units_consumed, :solr
    attr_accessor :start_date, :end_date, :media_sizes

    def self.call(fund_code, billing_rate, billing_unit, custom_start_date = nil, custom_end_date = nil)
      new(fund_code, billing_rate, billing_unit, custom_start_date, custom_end_date).call
    end

    def initialize(fund_code, billing_rate, billing_unit, custom_start_date = nil, custom_end_date = nil)
      @fund_code = fund_code
      @billing_rate = billing_rate
      @billing_unit = billing_unit
      @start_date = custom_start_date
      @end_date = custom_end_date
      @solr = solr_service.new
    end

    def call
      if !fund_code.present? || !fund_code.identifier.present? || !fund_code.chargeable
        return {
          status: 'failure',
          fund_code: fund_code&.id,
          identifier: fund_code&.identifier,
          message: 'Fund code not present, not chargeable, or fund code identifier not present',
          charges: []
        }
      end

      query_charge_information

      if media_ids.present? && fileset_ids.present? && units_consumed.present?
        charges = []
        charges << generate_initial_charge
        charges << generate_external_markup_charge if fund_code.external_user

        return {
          status: 'success',
          fund_code: fund_code&.id,
          identifier: fund_code&.identifier,
          message: 'Charge(s) successfully generated',
          charges: charges
        }
      else 
        return {
          status: 'failure',
          fund_code: fund_code&.id,
          identifier: fund_code&.identifier,
          message: 'No charge possible. Either no media, no filesets, or no units consumed.',
          charges: []
        }
      end
    end

    def query_charge_information
      @media_ids = fund_code.media_ids
      @filesets_to_media = query_media_fileset_ids
      @fileset_ids = @filesets_to_media.keys
      @media_sizes = query_media_sizes
      @units_consumed = query_bytes_consumed.to_d / unit_factor.to_d
    end

    def query_media_fileset_ids
      return {} if !media_ids.present?

      solr_params = {
        fq: [
          "#{solrize('has_model', :symbol)}:Media",
          assemble_or_query('id', media_ids)
        ],
        fl: [
          'id',
          solrize('file_set_ids', :symbol)
        ]
      }

      solr.get_docs(nil, solr_params)
        .select { |d| d['file_set_ids_ssim'].present? }
        .each_with_object({}) do |d, h|
          d['file_set_ids_ssim'].each { |fs_id| h[fs_id] = d['id'] }
        end
    end

    def query_media_sizes
      fileset_docs = query_fileset_docs
      media_to_fs_size = fileset_docs.map { |d| [ filesets_to_media[d['id']] , d['file_size_lts'] ] }.to_h
      (media_ids - media_to_fs_size.keys).each { |m_id| media_to_fs_size[m_id] = nil }
      return media_to_fs_size
    end

    def query_fileset_docs
      return [] if !fileset_ids.present?

      solr_params = {
        fq: [
          "#{solrize('has_model', :symbol)}:FileSet",
          assemble_or_query('id', fileset_ids),
          "date_uploaded_dtsi:[* TO \"#{solrize_date(end_date)}\"]"
        ],
        fl: [
          'id',
          'file_size_lts',
          'digest_ssim'
        ]
      }

      solr.get_docs(nil, solr_params)
    end

    def query_bytes_consumed
      return 0 if !media_sizes.present?

      indexed_bytes_consumed = media_sizes.values.select { |v| v.present? }.sum
      unindexed_size_media_ids = media_sizes.select { |k, v| !v.present? }.keys
      unindexed_bytes_consumed = unindexed_size_media_ids.inject(0) do |sum, m_id|
        sum + ( (m_size = query_media_filesize(m_id)).present? ? m_size : 0 )
      end

      return indexed_bytes_consumed + unindexed_bytes_consumed
    end

    def query_media_filesize(media_id)
      if (
        Media.exists?(media_id) &&
        (m = Media.find(media_id)).present? &&
        (fs = m.file_sets.first).present? &&
        (of = fs.original_file).present?
      )
        media_sizes[media_id] = of.size
        return of.size
      end
    end

    def generate_initial_charge
      amount = ( units_consumed * billing_rate.to_d ).round(2)
      generate_charge(amount, 'standard')
    end

    def generate_external_markup_charge
      amount = ( units_consumed * billing_rate.to_d * ( fund_code.external_user_additional_rate_percent.to_d / 100.to_d ) ).round(2)
      generate_charge(amount, 'external_markup')
    end

    def generate_charge(amount, service_type)
      charge = FundCodeCharge.new(
        fund_code: fund_code,
        description: charge_description(service_type),
        start_date: start_date,
        end_date: end_date,
        billing_rate: billing_rate,
        billing_unit: billing_unit,
        units_consumed: units_consumed,
        amount: amount,
        service_type: service_type,
        media_size_hash: media_sizes
      )
      charge.save!
      return charge
    end

    def unit_factor
      case billing_unit.downcase
      when 'b'
        1
      when 'kb'
        1024
      when 'mb'
        1024**2
      when 'gb'
        1024**3
      when 'tb'
        1024**4
      else
        raise StandardError.new "Invalid billing unit provided"
      end
        
    end

    private

    def start_date
      @start_date ||= determine_start_date
    end

    def determine_start_date
      if DateTime.current.day < 24
        (DateTime.current.change(day: 25) - 2.month).to_date
      else
        (DateTime.current.change(day: 25) - 1.month).to_date
      end
    end

    def end_date
      @end_date ||= determine_end_date
    end

    def determine_end_date
      if DateTime.current.day < 24
        (DateTime.current.change(day: 24) - 1.month).to_date
      else
        DateTime.current.change(day: 24).to_date
      end
    end

    def solrize_date(d)
      d.to_datetime.change(hour: 23, min: 59, sec: 59).strftime("%FT%TZ")
    end

    def charge_description(service_type)
      if service_type == 'standard'
        desc = "Standard storage usage charge" 
      elsif service_type == 'external_markup'
        desc = "External user markup charge"
      else
        desc = "Charge"
      end

      desc += " for cost object code #{fund_code.identifier}"

      if fund_code.title.present?
        desc += " with MorphoSource title '#{fund_code.title}'"
      end
    end
  end
end