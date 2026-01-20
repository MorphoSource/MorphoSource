module Morphosource
  module Reports
		class CartItemsReportService
			attr_reader :media_ids, :where_chain
			attr_accessor :results

			class_attribute :where_chain, default: [:where_work_is_media]

			def self.call(media_ids = [])
				new(media_ids).call
			end

			def initialize(media_ids = [])
				@media_ids = media_ids
				@where_chain = self.class.where_chain
				@results = []
			end

			def call
				process_where_chain
				format_results
			end

			def process_where_chain
				if where_chain.present?
					@results = where_chain.inject(model) { |model_or_result, where_func| send(where_func, model_or_result) }
				else
					@results = model.all
				end
			end

			def model
				CartItem
			end

			def format_results
				results_for_format = attributes.present? ? results.select(attributes) : results
				results_for_format.map do |cart_item|
					transformed_item = transform_for_report(cart_item.attributes.except('id'))
					if attributes.include? :user_id
						transformed_item.merge('download_user_id' => cart_item[:user_id])
					else
						transformed_item
					end
				end
			end

			# Overwrite and add attributes for child methods
			def attributes
				[]
			end

			def transform_for_report(download)
				download.map do |k, v|
					[
						field_transform(k),
						value_transform(k, v)
					]
				end.to_h
			end

			def field_transform(k)
				case k
				when 'work_id'
					'media_id'
				when 'user_id'
					'download_user'
				else
					k
				end
			end

			def value_transform(k, v)
				case k
				when 'user_id'
					User.find_by_user_key(v).present? ? User.find_by_user_key(v).name_and_email : v
				else
					v.try(:join, '; ') || v
				end
			end

			def where_work_is_media(model_or_result)
				media_ids.present? ? model_or_result.where(work_id: media_ids) : model_or_result.all
			end
		end
  end
end