module Hyrax
  class MediaMemberPresenterFactory < Hyrax::MemberPresenterFactory
    self.file_presenter_class = MediaFileSetPresenter

    def ordered_ids
      # Union AF PCDM member IDs with Valkyrie-only FileSets so that works whose
      # FileSets were created via the Valkyrie path (stored in valkyrie_member_ids_ssim
      # but not yet in member_ids_ssim) still surface their file presenters.
      @ordered_ids ||= (
        Array(@work.fetch('member_ids_ssim', [])) +
        Array(@work.fetch('valkyrie_member_ids_ssim', []))
      ).uniq
    end

    private

    def file_set_ids
      # Same union as ordered_ids — the intersection of ordered_ids & file_set_ids
      # must be non-empty for presenters to be built.
      @file_set_ids ||= (
        Array(@work.fetch('file_set_ids_ssim', [])) +
        Array(@work.fetch('valkyrie_member_ids_ssim', []))
      ).uniq
    end
  end
end