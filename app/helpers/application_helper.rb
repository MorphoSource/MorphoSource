module ApplicationHelper
  def modalities_client_lookup_json
    @modalities_client_lookup_json ||= json_escape(Morphosource::ModalitiesService.client_lookup.to_json).html_safe
  end
end
