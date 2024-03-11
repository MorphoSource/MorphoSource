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

  def can_read?(work, member = user)
    user = User.find(member.id)
    ability = Ability.new(user)
    work_doc = SolrDocument.find(work.id)
    result = []
    result << (ability.can? :read, work.id)
    result << (ability.can? :read, work)
    result << (ability.can? :read, work_doc)
    result << (user.can? :read, work.id)
    result << (user.can? :read, work)
    result << (user.can? :read, work_doc)
    return if result.uniq.count > 1

    result.first
  end

  def can_edit?(work, member = user)
    user = User.find(member.id)
    ability = Ability.new(user)
    work_doc = SolrDocument.find(work.id)
    result = []
    result << (ability.can? :edit, work.id)
    result << (ability.can? :edit, work)
    result << (ability.can? :edit, work_doc)
    result << (user.can? :edit, work.id)
    result << (user.can? :edit, work)
    result << (user.can? :edit, work_doc)
    return if result.uniq.count > 1

    result.first
  end

  def can_transfer?(work, member = user)
    user = User.find(member.id)
    ability = Ability.new(user)
    result = []
    result << (ability.can? :transfer, work.id)
    result << (user.can? :transfer, work.id)
    return if result.uniq.count > 1

    result.first
  end

  def can_accept?(request, member = user)
    user = User.find(member.id)
    ability = Ability.new(user)
    result = []
    result << (ability.can? :accept, request)
    result << (user.can? :accept, request)
    return if result.uniq.count > 1

    result.first
  end

  def can_reject?(request, member = user)
    user = User.find(member.id)
    ability = Ability.new(user)
    result = []
    result << (ability.can? :reject, request)
    result << (user.can? :reject, request)
    return if result.uniq.count > 1

    result.first
  end
end