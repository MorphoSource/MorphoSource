class Submission < ActiveRecord::Base

  attr_writer :current_step

  STEP_INSTITUTION = 'institution'
  STEP_OBJECT = 'object'

  validates_presence_of :institution_id, if: :selecting_institution?
  validates_presence_of :object_id, if: :selecting_object?

  def all_valid?
    steps.all? do |step|
      self.current_step = step
      valid?
    end
  end

  def steps
    [ STEP_INSTITUTION, STEP_OBJECT ]
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
    previous_step_idx = steps.index(current_step) - 1
    self.current_step = case
                        when previous_step_idx >= 0
                          steps[previous_step_idx]
                        else
                          nil
                        end
  end

  def selecting_institution?
    current_step == STEP_INSTITUTION
  end

  def selecting_object?
    current_step == STEP_OBJECT
  end

end
