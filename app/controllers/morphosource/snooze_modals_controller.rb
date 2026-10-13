module Morphosource
  class SnoozeModalsController < ApplicationController
    COOKIE_KEYS = {
      'modal' => :hide_donation_modal,
      'download_modal' => :hide_download_modal
    }.freeze

    def snooze_hour
      snooze(1.hour)
    end

    def snooze_day
      snooze(1.day)
    end

    def snooze_week
      snooze(1.week)
    end

    private

    def snooze(duration)
      cookies[snooze_cookie_key] = { value: true, expires: duration.from_now }
      head :ok
    end

    # the modal param is set by route defaults, not by the client
    def snooze_cookie_key
      COOKIE_KEYS.fetch(params[:modal])
    end
  end
end
