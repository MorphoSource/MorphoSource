module TestHelpers

  # https://github.com/cldwalker/hirb/blob/master/test/test_helper.rb
  def capture_stdout(&block)
    original_stdout = $stdout
    $stdout = fake = StringIO.new
    begin
      yield
    ensure
      $stdout = original_stdout
    end
    fake.string
  end

  def is_contributor(user)
    allow(user).to receive(:contributor?).and_return(true)
  end

  def is_not_contributor(user)
    allow(user).to receive(:contributor?).and_return(false)
  end

  def team_collection_type
    Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Teams::SETTINGS)
  end

  def project_collection_type
    Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Projects::SETTINGS)
  end

  def media_list_collection_type
    Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::MediaLists::SETTINGS)
  end

  def sequential_section_list_collection_type
    Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::SequentialSectionLists::SETTINGS)
  end

  def organization_collection_type
    Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Organizations::SETTINGS)
  end

  def expect_cancan_access_denied
    expect(response).to redirect_to(main_app.root_path(locale: 'en'))
    expect(flash[:notice]).to eq("#{I18n.t("cancan.not_found.message")}: #{I18n.t("cancan.not_found.description")}")
  end
end