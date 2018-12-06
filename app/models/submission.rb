class Submission
  include ActiveModel::Model

  attr_accessor :imaging_event_id, :institution_id, :object_id
  attr_writer :current_step

  Step = Struct.new(:name, :previous_step, :next_step) do
    def to_s
      name
    end
  end

  # Define the steps
  STEP_IMAGING_EVENT = Step.new('imaging_event')
  STEP_INSTITUTION = Step.new('institution')
  STEP_OBJECT = Step.new('object')

  # List of all possible steps
  STEPS = [ STEP_IMAGING_EVENT, STEP_INSTITUTION, STEP_OBJECT ]

  # Step sequencing; i.e., previous step and next step for each step
  STEP_INSTITUTION.previous_step = nil
  STEP_INSTITUTION.next_step = STEP_OBJECT
  STEP_OBJECT.previous_step = STEP_INSTITUTION
  STEP_OBJECT.next_step = STEP_IMAGING_EVENT
  STEP_IMAGING_EVENT.previous_step = STEP_OBJECT
  STEP_IMAGING_EVENT.next_step = nil

  # Make sure there is exactly one first step
  previous_step_nil = STEPS.select { |step| step.previous_step.nil? }
  raise StandardError, 'No first step' if previous_step_nil.empty?
  raise StandardError, 'Multiple first steps' if previous_step_nil.size > 1

  # Make sure there is at least one last step
  next_step_nil = STEPS.select { |step| step.next_step.nil? }
  raise StandardError, 'No last step(s)' if next_step_nil.empty?

  def self.first_step
    STEPS.find { |step| step.previous_step.nil? }
  end

  def self.step(step_name)
    STEPS.find { |step| step.name == step_name }
  end

  validates_presence_of :object_id, if: :selecting_object?
  validates_presence_of :imaging_event_id, if: :selecting_imaging_event?

  def all_valid?
    STEPS.all? do |step|
      self.current_step = step
      valid?
    end
  end

  def current_step
    @current_step || STEP_INSTITUTION
  end

  def first_step?
    current_step == self.class.first_step
  end

  def last_step?
    current_step.next_step.nil?
  end

  def step_forward
    self.current_step = current_step.next_step
  end

  def step_back
    self.current_step = current_step.previous_step
  end

  def selecting_object?
    current_step == STEP_OBJECT
  end

  def selecting_imaging_event?
    current_step == STEP_IMAGING_EVENT
  end

end
