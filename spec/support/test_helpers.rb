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

end