require 'rails_helper'

RSpec.describe BackgroundJob, type: :model do

  let(:user)          { User.create(email: "example@email.com", password: "password") }
  let!(:main_job1)     { BackgroundJob.create( 
                                main_job_id: '123', 
                                user_id: user.id, 
                                status: 'working',
                                exceptions: '',
                                created_objects: { 'file1': 'media_id1'} ) }
  let(:new_params)      { {'file2': 'media_id2'} }
  let(:new_status)      { 'failed' }
  let(:new_exceptions)  { "new exceptions" }

  describe '#update_created_objects' do
    context 'merged new params' do
      before do
        main_job1.update_created_objects(new_params)
      end
      it { expect(main_job1.created_objects).to eq( {"file1"=>"media_id1", "file2"=>"media_id2"} ) }
    end
  end

  describe '#clear_created_objects' do
    context 'clear params' do
      before do
        main_job1.clear_created_objects
      end
      it { expect(main_job1.created_objects).to eq( {} ) }
    end
  end

  describe '#update_status' do
    context 'change status and exceptions' do
      before do
        main_job1.update_status(new_status, new_exceptions)
      end
      it { expect(main_job1.status).to eq( new_status ) }
      it { expect(main_job1.exceptions).to eq( new_exceptions ) }
    end
  end

end
