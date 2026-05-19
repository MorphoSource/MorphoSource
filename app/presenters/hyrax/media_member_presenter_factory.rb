module Hyrax
  class MediaMemberPresenterFactory < Hyrax::MemberPresenterFactory
    self.file_presenter_class = MediaFileSetPresenter

    def ordered_ids
      @ordered_ids ||= Array(@work.fetch('member_ids_ssim', []))
    end

    private

    def file_set_ids
      @file_set_ids ||= Array(@work.fetch('file_set_ids_ssim', []))
    end
  end
end