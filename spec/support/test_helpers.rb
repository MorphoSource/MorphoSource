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

  def create_collection_types
    Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::MediaLists::SETTINGS)
    Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::SequentialSectionLists::SETTINGS)
    Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Projects::SETTINGS)
    Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Teams::SETTINGS)
  end

end