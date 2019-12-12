module Hyrax
	class MediaMemberPresenterFactory < Hyrax::MemberPresenterFactory
		self.file_presenter_class = MediaFileSetPresenter
	end
end