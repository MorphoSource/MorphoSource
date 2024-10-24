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
    return false unless ability.can? :read, work.id
    return false unless ability.can? :read, work
    return false unless ability.can? :read, work_doc
    return false unless user.can? :read, work.id
    return false unless user.can? :read, work

    user.can? :read, work_doc
  end

  def can_download?(work, member = user)
    user = User.find(member.id)
    ability = Ability.new(user)
    work_doc = SolrDocument.find(work.id)
    return false unless ability.can? :download, work.id
    return false unless ability.can? :download, work
    return false unless ability.can? :download, work_doc
    return false unless user.can? :download, work.id
    return false unless user.can? :download, work

    user.can? :read, work_doc
  end

  def can_edit?(work, member = user)
    user = User.find(member.id)
    ability = Ability.new(user)
    work_doc = SolrDocument.find(work.id)
    return false unless ability.can? :edit, work.id
    return false unless ability.can? :edit, work.id
    return false unless ability.can? :edit, work
    return false unless ability.can? :edit, work_doc
    return false unless user.can? :edit, work.id
    return false unless user.can? :edit, work

    user.can? :edit, work_doc
  end

  def can_update?(work, member = user)
    user = User.find(member.id)
    ability = Ability.new(user)
    work_doc = SolrDocument.find(work.id)
    return false unless ability.can? :update, work.id
    return false unless ability.can? :update, work.id
    return false unless ability.can? :update, work
    return false unless ability.can? :update, work_doc
    return false unless user.can? :update, work.id
    return false unless user.can? :update, work

    user.can? :update, work_doc
  end

  def can_transfer?(work, member = user)
    user = User.find(member.id)
    ability = Ability.new(user)
    return false unless ability.can? :transfer, work.id

    user.can? :transfer, work.id
  end

  def can_accept?(request, member = user)
    user = User.find(member.id)
    ability = Ability.new(user)
    return false unless ability.can? :accept, request

    user.can? :accept, request
  end

  def can_reject?(request, member = user)
    user = User.find(member.id)
    ability = Ability.new(user)
    return false unless ability.can? :reject, request

    user.can? :reject, request
  end
end