class Submission < ActiveRecord::Base

  attr_writer :current_step

  STEP_INSTITUTION = 'institution'

  validates_presence_of :institution_id, if: :selecting_institution?

  def all_valid?
    steps.all? do |step|
      self.current_step = step
      valid?
    end
  end

  def steps
    [ STEP_INSTITUTION ]
  end

  def current_step
    @current_step || steps.first
  end

  def first_step?
    current_step == steps.first
  end

  def last_step?
    current_step == steps.last
  end

  def next_step
    self.current_step = steps[steps.index(current_step) + 1]
  end

  def previous_step
    self.current_step = steps[steps.index(current_step) - 1]
  end

  def selecting_institution?
    current_step == STEP_INSTITUTION
  end

end
