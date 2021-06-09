module Morphosource
  class FundCodeChargeService
    include SolrHelper

    attr_reader :fund_code, :billing_rate, :billing_unit, :media_ids, 
      :fileset_ids, :units_consumed, :solr
    attr_accessor :start_date, :end_date

    def self.call(fund_code, billing_rate, billing_unit, custom_start_date = nil, custom_end_date = nil)
      new(fund_code, billing_rate, billing_unit, custom_start_date, custom_end_date).call
    end

    def self.audit_charge_units_consumed(fund_code, start_date, end_date)

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
      @fileset_ids = query_media_child_fileset_ids
      @units_consumed = query_bytes_consumed.to_d / unit_factor.to_d
    end

    def query_media_child_fileset_ids
      return [] if !media_ids.present?

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

      solr.get_docs(nil, solr_params).pluck(solrize('file_set_ids', :symbol)).compact
    end

    def query_bytes_consumed
      filesets = query_fileset_docs
      filesets_with_size = filesets.select { |fs| fs['file_size_lts'].present? }
      filesets_without_size = filesets - filesets_with_size

      indexed_units_consumed = filesets.pluck('file_size_lts').sum
      filesystem_units_consumed = filesets_binary_sizes(filesets_without_size).pluck('file_size_lts').sum

      return indexed_units_consumed + filesystem_units_consumed
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

    # calculate space used by each fileset from binary file
    def filesets_binary_sizes(filesets)
      Morphosource::FilesetsBinarySizeService.call(filesets.pluck('id'))
    end

    def generate_initial_charge
      amount = units_consumed * billing_rate.to_d
      generate_charge(amount, 'standard')
    end

    def generate_external_markup_charge
      amount = units_consumed * billing_rate.to_d * ( fund_code.external_user_additional_rate_percent.to_d / 100.to_d )
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
        service_type: service_type
      )
      charge.save!
      return charge
    end

    def unit_factor
      case billing_unit.downcase
      when 'b'
        1
      when 'kb'
        2**10
      when 'mb'
        2**20
      when 'gb'
        2**30
      when 'tb'
        2**40
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
        desc = "External user markup charge"
      elsif service_type == 'external_markup'
        desc = "Standard storage usage charge"
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