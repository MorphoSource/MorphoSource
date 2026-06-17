module Morphosource
  module FundCodes
    class FundCodeChargeService
      include Morphosource::Jsend
      include SolrHelper

      attr_reader :fund_code, :billing_rate, :billing_unit, :save_charge, :media_ids,
        :filesets_to_media, :fileset_ids, :units_consumed, :solr,
        :media_docs # Media Solr documents cached from query_media_fileset_ids for use in query_media_sizes
      attr_accessor :start_date, :end_date, :media_sizes

      # Generates (and only optionally saves) fund code charge objects
      def self.call(fund_code:, billing_rate:, billing_unit:, custom_start_date: nil, custom_end_date: nil, save_charge: false)
        new(
          fund_code: fund_code, 
          billing_rate: billing_rate, 
          billing_unit: billing_unit, 
          custom_start_date: custom_start_date, 
          custom_end_date: custom_end_date,
          save_charge: save_charge
        ).call
      end

      def initialize(fund_code:, billing_rate:, billing_unit:, custom_start_date: nil, custom_end_date: nil, save_charge: false)
        @fund_code = fund_code
        @billing_rate = billing_rate
        @billing_unit = billing_unit
        @start_date = custom_start_date
        @end_date = custom_end_date
        @save_charge = save_charge
        @solr = solr_service.new
      end

      def call
        return fund_code_invalid_response unless validate_fund_code
        return overlapping_charge_response unless validate_no_overlapping_charges

        query_charge_information
        return fund_code_incoherent_charge_response unless validate_charge_sanity

        message = ""
        charges = []
        if media_ids.present? && fileset_ids.present? && units_consumed.present?
          message = "One or more charges successfully generated.",
          charges = generate_charges
        else
          message = "Fund code passed validation, but no charges were generated. Either no media, no filesets, or no units consumed.",
          charges = []
        end

        return jsend_success({
          fund_code: fund_code&.id,
          identifier: fund_code&.identifier,
          message: message,
          charges: charges
        })
      end

      def query_charge_information
        query_media_fileset_ids
        @fileset_ids = @filesets_to_media&.keys || []
        @media_sizes = query_media_sizes
        @units_consumed = query_bytes_consumed.to_d / unit_factor.to_d
      end

      def query_media_fileset_ids
        if !initial_media_ids.present?
          @filesets_to_media = {}
          @media_ids = []
          return
        end

        # Query media associated with fund code uploaded before end date that are local (not remote)
        solr_params = {
          fq: [
            "#{solrize('has_model', :symbol)}:Media",
            assemble_or_query('id', initial_media_ids),
            "date_uploaded_dtsi:[* TO \"#{solrize_date(end_date)}\"]",
            "-is_remote_backed_bsi:true"
          ],
          fl: [
            'id',
            solrize('file_set_ids', :symbol),
            # Total size in bytes of all FileSet binaries + FileSet derivatives, indexed by MediaIndexer
            'all_files_file_size_lts'
          ]
        }

        docs = solr.get_docs(nil, solr_params)

        # Cache docs so query_media_sizes can read all_files_file_size_lts without a second Solr round-trip
        @media_docs = docs

        @filesets_to_media = docs
          .select { |d| d['file_set_ids_ssim'].present? }
          .each_with_object({}) do |d, h|
            d['file_set_ids_ssim'].each { |fs_id| h[fs_id] = d['id'] }
          end

        @media_ids = docs.map { |d| d['id'] }
      end

      def initial_media_ids
        @initial_media_ids ||= fund_code.media_ids
      end

      def query_media_sizes
        # Prefer all_files_file_size_lts from the Media Solr doc — covers binary + all FileSet derivatives.
        # Falls back to nil when the media hasn't been indexed with this field yet;
        # query_bytes_consumed will call query_media_filesize for any nil entries.
        media_to_size = (media_docs || []).map { |d| [d['id'], d['all_files_file_size_lts']] }.to_h
        (media_ids - media_to_size.keys).each { |m_id| media_to_size[m_id] = nil }
        return media_to_size
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

      # Fallback for media whose all_files_file_size_lts is not yet indexed in Solr.
      # Reads FileSet binary + derivative sizes from FileSetSizeInfo rather than
      # re-computing from source records or the filesystem.
      def query_media_filesize(media_id)
        # FileSetSizeInfo.sum_file_size covers binary + all FileSet-level derivatives.
        fs_total = FileSetSizeInfo.where(media_id: media_id).sum(:sum_file_size)

        # Media-level derivatives (e.g. user-uploaded 2D thumbnails stored under the
        # Media ID path) are still globbed from disk and added on top.
        m_deriv_size = Morphosource::DerivativePath.derivatives_for_reference(media_id)
          .map { |p| File.size?(p) }.compact.sum

        total = fs_total + m_deriv_size
        # Cache in @media_sizes so query_bytes_consumed uses this value
        # instead of the nil from the Solr lookup.
        media_sizes[media_id] = total
        return total
      end

      def generate_charges
        charges = []
        charges << generate_initial_charge
        charges << generate_external_markup_charge if fund_code.external_user
        return charges
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
        charge.save! if save_charge
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

      def validate_fund_code
        fund_code.present? && fund_code.identifier.present? && fund_code.chargeable
      end

      def validate_no_overlapping_charges
        !FundCodeCharge.where("fund_code_id = ? AND start_date <= ? AND ? <= end_date", fund_code&.id, end_date, start_date).exists?
      end

      # fail validation if units consumed, billing rate, or external markup (only for external fc) are negative
      def validate_charge_sanity
        units_consumed >= 0.to_i && 
        billing_rate.to_d >= 0.to_d && 
        ( !fund_code.external_user || (fund_code.external_user_additional_rate_percent.to_d >= 0.to_d) )
      end

      def fund_code_invalid_response
        errors = {}
        errors[:fund_code] = "Fund code (ID: #{fund_code&.id}) not present." if !fund_code.present?
        errors[:fund_code_identifier] = "Fund code identifier (#{fund_code&.identifier}) not present." if !fund_code&.identifier.present?
        errors[:fund_code_chargeable] = "Fund code not chargeable." if !fund_code&.chargeable

        jsend_fail({
          errors: errors,
          fund_code: fund_code&.id,
          fund_code_identifier: fund_code&.identifier,
          message: "Fund code not present, not chargeable, or fund code identifier not present."
        })
      end

      def overlapping_charge_response
        jsend_fail({
          fund_code: fund_code&.id,
          fund_code_identifier: fund_code&.identifier,
          message: "Could not generate charge with start date #{start_date} and end date #{end_date}, dates overlap with existing charge for fund code ID #{fund_code&.id} with identifier #{fund_code&.identifier}."
        })
      end

      def fund_code_incoherent_charge_response
        errors = {}
        errors[:units_consumed] = "Units consumed can not be negative." if !(units_consumed >= 0.to_i)
        errors[:billing_rate] = "Billing rate can not be negative." if !(billing_rate.to_d >= 0.to_d)
        errors[:external_user_additional_rate_percent] = "External fund code additional rate percent can not be negative." if (fund_code.external_user && !(fund_code.external_user_additional_rate_percent.to_d >= 0.to_d))

        jsend_fail({
          errors: errors,
          fund_code: fund_code&.id,
          fund_code_identifier: fund_code&.identifier,
          message: "Could not generate charge, units consumed or billing rates are negative."
        })
      end
    end
  end
end