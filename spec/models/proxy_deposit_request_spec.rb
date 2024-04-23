require 'rails_helper'

RSpec.describe ProxyDepositRequest do
  let(:user5)          { FactoryBot.create(:user, id: '5', email: "purple@email.com", password: "password", display_name: "Mickey Mouse") }
  let(:user6)          { FactoryBot.create(:user, id: '6', email: "blue@email.com", password: "password", display_name: "Donald Duck") }

  before do
    allow(Hyrax.config).to receive(:host_name) { "test.host" }
  end

  describe "instance" do
    subject { described_class.new }

    let!(:proxy_deposit_request) {
      ProxyDepositRequest.create(
        work_id: "000200122", sending_user_id: user5.id, receiving_user_id: user6.id, status: "pending", sender_comment: "test")
    }

    context 'transfer_to_should_be_a_contributor' do
      it 'is not valid' do
        subject.sending_user = user5
        subject.receiving_user = user6
        expect(subject).to_not be_valid
        expect(subject.errors[:transfer_to]).to eq(["must have contributor access"])
      end
    end
  end

  describe 'create' do
    let(:work)                { FactoryBot.create(:media) }
    let(:email_dispatch_user) { FactoryBot.create(:user) }
    let(:sending_user)        { FactoryBot.create(:contributor, email: "sender@email.com", display_name: "Sender") }
    let(:receiving_user)      { FactoryBot.create(:contributor, email: "receiver@email.com", display_name: "Receiver") }
    let(:org_manager_1)       { FactoryBot.create(:contributor, email: "org_manager_1@email.com", display_name: "Org Manager 1") }
    let(:organization)        { FactoryBot.create(:organization_collection, depositor: org_manager_1.ms_id) }
    let(:org_manager_2)       { FactoryBot.create(:contributor, email: "org_manager_2@email.com", display_name: "Org Manager 2") }
    let(:organization2)       { FactoryBot.create(:organization_collection, depositor: org_manager_2.ms_id) }

    context 'created with user instances' do
      context 'individual to individual' do
        subject { described_class.create(work_id: work.id, sending_user: sending_user, receiving_user: receiving_user) }

        it 'creates successfully and has correct attributes' do
          expect(subject.id).not_to be_nil
          expect(subject.work_id).to eq work.id
          expect(subject.sending_user.id).to eq sending_user.id
          expect(subject.sending_user_id).to eq sending_user.id.to_s
          expect(subject.sending_user_type).to eq "User"
          expect(subject.receiving_user.id).to eq receiving_user.id
          expect(subject.receiving_user_id).to eq receiving_user.id.to_s
          expect(subject.receiving_user_type).to eq "User"
        end 
      end

      context 'individual to organization' do
        subject { described_class.create(work_id: work.id, sending_user: sending_user, receiving_user: organization) }

        it 'creates successfully and has correct attributes' do
          expect(subject.id).not_to be_nil
          expect(subject.work_id).to eq work.id
          expect(subject.sending_user.id).to eq sending_user.id
          expect(subject.sending_user_id).to eq sending_user.id.to_s
          expect(subject.sending_user_type).to eq "User"
          expect(subject.receiving_user.id).to eq organization.id
          expect(subject.receiving_user_id).to eq organization.id.to_s
          expect(subject.receiving_user_type).to eq "OrganizationCollection"
        end 
      end

      context 'organization to individual' do
        subject { described_class.create(work_id: work.id, sending_user: organization, receiving_user: receiving_user) }

        it 'creates successfully and has correct attributes' do
          expect(subject.id).not_to be_nil
          expect(subject.work_id).to eq work.id
          expect(subject.sending_user.id).to eq organization.id
          expect(subject.sending_user_id).to eq organization.id.to_s
          expect(subject.sending_user_type).to eq "OrganizationCollection"
          expect(subject.receiving_user.id).to eq receiving_user.id
          expect(subject.receiving_user_id).to eq receiving_user.id.to_s
          expect(subject.receiving_user_type).to eq "User"
        end 
      end

      context 'organization to organization' do
        subject { described_class.create(work_id: work.id, sending_user: organization, receiving_user: organization2) }

        it 'creates successfully and has correct attributes' do
          expect(subject.id).not_to be_nil
          expect(subject.work_id).to eq work.id
          expect(subject.sending_user.id).to eq organization.id
          expect(subject.sending_user_id).to eq organization.id.to_s
          expect(subject.sending_user_type).to eq "OrganizationCollection"
          expect(subject.receiving_user.id).to eq organization2.id
          expect(subject.receiving_user_id).to eq organization2.id.to_s
          expect(subject.receiving_user_type).to eq "OrganizationCollection"
        end 
      end
    end

    context 'created with user IDs' do
      context 'individual to individual' do
        subject { described_class.create(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id) }

        it 'creates successfully and has correct attributes' do
          expect(subject.id).not_to be_nil
          expect(subject.work_id).to eq work.id
          expect(subject.sending_user.id).to eq sending_user.id
          expect(subject.sending_user_id).to eq sending_user.id.to_s
          expect(subject.sending_user_type).to eq "User"
          expect(subject.receiving_user.id).to eq receiving_user.id
          expect(subject.receiving_user_id).to eq receiving_user.id.to_s
          expect(subject.receiving_user_type).to eq "User"
        end 
      end

      context 'individual to organization' do
        subject { described_class.create(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: organization.id) }

        it 'creates successfully and has correct attributes' do
          expect(subject.id).not_to be_nil
          expect(subject.work_id).to eq work.id
          expect(subject.sending_user.id).to eq sending_user.id
          expect(subject.sending_user_id).to eq sending_user.id.to_s
          expect(subject.sending_user_type).to eq "User"
          expect(subject.receiving_user.id).to eq organization.id
          expect(subject.receiving_user_id).to eq organization.id.to_s
          expect(subject.receiving_user_type).to eq "OrganizationCollection"
        end 
      end

      context 'organization to individual' do
        subject { described_class.create(work_id: work.id, sending_user_id: organization.id, receiving_user_id: receiving_user.id) }

        it 'creates successfully and has correct attributes' do
          expect(subject.id).not_to be_nil
          expect(subject.work_id).to eq work.id
          expect(subject.sending_user.id).to eq organization.id
          expect(subject.sending_user_id).to eq organization.id.to_s
          expect(subject.sending_user_type).to eq "OrganizationCollection"
          expect(subject.receiving_user.id).to eq receiving_user.id
          expect(subject.receiving_user_id).to eq receiving_user.id.to_s
          expect(subject.receiving_user_type).to eq "User"
        end 
      end

      context 'organization to organization' do
        subject { described_class.create(work_id: work.id, sending_user_id: organization.id, receiving_user_id: organization2.id) }

        it 'creates successfully and has correct attributes' do
          expect(subject.id).not_to be_nil
          expect(subject.work_id).to eq work.id
          expect(subject.sending_user.id).to eq organization.id
          expect(subject.sending_user_id).to eq organization.id.to_s
          expect(subject.sending_user_type).to eq "OrganizationCollection"
          expect(subject.receiving_user.id).to eq organization2.id
          expect(subject.receiving_user_id).to eq organization2.id.to_s
          expect(subject.receiving_user_type).to eq "OrganizationCollection"
        end 
      end
    end
  end

  describe 'save' do
    let(:work)                { FactoryBot.create(:media) }
    let(:email_dispatch_user) { FactoryBot.create(:user) }
    let(:sending_user)        { FactoryBot.create(:contributor, email: "sender@email.com", display_name: "Sender") }
    let(:receiving_user)      { FactoryBot.create(:contributor, email: "receiver@email.com", display_name: "Receiver") }
    let(:org_manager_1)       { FactoryBot.create(:contributor, email: "org_manager_1@email.com", display_name: "Org Manager 1") }
    let(:organization)        { FactoryBot.create(:organization_collection, depositor: org_manager_1.ms_id) }
    let(:org_manager_2)       { FactoryBot.create(:contributor, email: "org_manager_2@email.com", display_name: "Org Manager 2") }
    let(:organization2)       { FactoryBot.create(:organization_collection, depositor: org_manager_2.ms_id) }
    let(:org_manager_3)       { FactoryBot.create(:contributor, email: "org_manager_3@email.com", display_name: "Org Manager 3") }
    let(:org_manager_4)       { FactoryBot.create(:contributor, email: "org_manager_4@email.com", display_name: "Org Manager 4") }

    context 'message generation' do
      context 'for standard transfer' do
        context 'from individual to individual' do
          subject { described_class.new(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id) }

          before do
            allow(subject).to receive(:deliver_message).and_return(true)
            allow(subject).to receive(:email_sender).and_return(email_dispatch_user)
            subject.save
          end

          it 'generates a message sent to the transfer receiver' do          
            expect(subject).to have_received(:deliver_message).with(
              email_dispatch_user,
              receiving_user,
              "<a href=\"http://test.host/users/#{sending_user.user_key}\">Sender</a> has requested to transfer the ownership of <b><a href=\"http://test.host/concern/media/#{work.id}\">Media #{work.id}: example media title</a></b> to you. Please accept or reject this request in your <a href=\"http://test.host/dashboard/transfers\">Ownership Transfers</a> dashboard.",
              "You have a media transfer request"
            )
          end
        end

        context 'from individual to organization with one manager' do
          subject { described_class.new(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: organization.id) }

          before do
            allow(subject).to receive(:deliver_message).and_return(true)
            allow(subject).to receive(:email_sender).and_return(email_dispatch_user)
            subject.save
          end

          it 'generates a message sent to the transfer receiver org manager' do          
            expect(subject).to have_received(:deliver_message).with(
              email_dispatch_user,
              org_manager_1,
              "<a href=\"http://test.host/users/#{sending_user.user_key}\">Sender</a> has requested to transfer the ownership of <b><a href=\"http://test.host/concern/media/#{work.id}\">Media #{work.id}: example media title</a></b> to you. Please accept or reject this request in your <a href=\"http://test.host/dashboard/transfers\">Ownership Transfers</a> dashboard.",
              "You have a media transfer request"
            )
          end
        end

        context 'from individual to organization with two managers' do
          subject { described_class.new(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: organization.id) }

          before do
            allow_any_instance_of(OrganizationCollection).to receive(:managers).and_return([org_manager_1, org_manager_3])
            allow(subject).to receive(:deliver_message).and_return(true)
            allow(subject).to receive(:email_sender).and_return(email_dispatch_user)
            subject.save
          end

          it 'generates two messages, one for each org manager' do           
            expect(subject).to have_received(:deliver_message).exactly(2).times
          end
        end

        context 'from organization to individual' do
          subject { described_class.new(work_id: work.id, sending_user_id: organization2.id, receiving_user_id: receiving_user.id) }

          before do
            allow(subject).to receive(:deliver_message).and_return(true)
            allow(subject).to receive(:email_sender).and_return(email_dispatch_user)
            subject.save
          end

          it 'generates a message sent to the transfer receiver' do          
            expect(subject).to have_received(:deliver_message).with(
              email_dispatch_user,
              receiving_user,
              "<a href=\"http://test.host/organizations/#{organization2.id}\">#{organization2.name}</a> has requested to transfer the ownership of <b><a href=\"http://test.host/concern/media/#{work.id}\">Media #{work.id}: example media title</a></b> to you. Please accept or reject this request in your <a href=\"http://test.host/dashboard/transfers\">Ownership Transfers</a> dashboard.",
              "You have a media transfer request"
            )
          end
        end

        context 'from organization to organization with one manager' do
          subject { described_class.new(work_id: work.id, sending_user_id: organization2.id, receiving_user_id: organization.id) }

          before do
            allow(subject).to receive(:deliver_message).and_return(true)
            allow(subject).to receive(:email_sender).and_return(email_dispatch_user)
            subject.save
          end

          it 'generates a message sent to the transfer receiver org manager' do          
            expect(subject).to have_received(:deliver_message).with(
              email_dispatch_user,
              org_manager_1,
              "<a href=\"http://test.host/organizations/#{organization2.id}\">#{organization2.name}</a> has requested to transfer the ownership of <b><a href=\"http://test.host/concern/media/#{work.id}\">Media #{work.id}: example media title</a></b> to you. Please accept or reject this request in your <a href=\"http://test.host/dashboard/transfers\">Ownership Transfers</a> dashboard.",
              "You have a media transfer request"
            )
          end
        end

        context 'from organization to organization with two managers' do
          subject { described_class.new(work_id: work.id, sending_user_id: organization2.id, receiving_user_id: organization.id) }

          before do
            allow_any_instance_of(OrganizationCollection).to receive(:managers).and_return([org_manager_1, org_manager_3])
            allow(subject).to receive(:deliver_message).and_return(true)
            allow(subject).to receive(:email_sender).and_return(email_dispatch_user)
            subject.save
          end

          it 'generates two messages, one for each org manager' do           
            expect(subject).to have_received(:deliver_message).exactly(2).times
          end
        end
      end

      context 'for automated organization transfer' do
        context 'from individual to organization with one manager' do
          subject { described_class.new(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: organization.id, organization_transfer: true) }

          before do
            allow(subject).to receive(:deliver_message).and_return(true)
            allow(subject).to receive(:email_sender).and_return(email_dispatch_user)
          end

          it 'generates the correct message sent to the org manager' do
            allow(subject).to receive(:send_org_transfer_message_to_sender).and_return(nil)
            subject.save

            expect(subject).to have_received(:deliver_message).with(
              email_dispatch_user,
              org_manager_1,
              "<a href=\"http://test.host/users/#{sending_user.user_key}\">Sender</a> has requested to transfer the ownership of <b><a href=\"http://test.host/concern/media/#{work.id}\">Media #{work.id}: example media title</a></b> to your managed organization (<a href=\"http://test.host/organizations/#{organization.id}\">#{organization.title.first}</a>). It is your choice whether to accept or reject this request. If you accept the request, your organization will become the data manager for this media. When accepting the request, you may choose to allow the original depositor to retain edit access to the media. Please accept or reject this request in your <a href=\"http://test.host/dashboard/transfers\">Ownership Transfers</a> dashboard. For more details, see our <a href='https://wiki.duke.edu/display/MD/Organization+Ownership+Transfers' target='_blank'>documentation</a>.",
              "You have a media transfer request"
            )
          end

          it 'generates the correct message sent to the media depositor' do
            allow(subject).to receive(:send_org_transfer_message_to_receiver).and_return(nil)
            subject.save

            expect(subject).to have_received(:deliver_message).with(
              email_dispatch_user,
              sending_user,
              "A request to transfer ownership of <b><a href=\"http://test.host/concern/media/#{work.id}\">Media #{work.id}: example media title</a></b> to organization <a href=\"http://test.host/organizations/#{organization.id}\">#{organization.title.first}</a> has been generated. The organization manager(s) will decide to accept or reject this request. For more details, see our <a href='https://wiki.duke.edu/display/MD/Organization+Ownership+Transfers' target='_blank'>documentation</a>.",
              "Organization media transfer request generated"
            )
          end
        end

        context 'from individual to organization with two data managers' do
          subject { described_class.new(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: organization.id, organization_transfer: true) }

          before do
            allow_any_instance_of(OrganizationCollection).to receive(:managers).and_return([org_manager_1, org_manager_3])
            allow(subject).to receive(:send_org_transfer_message_to_sender).and_return(nil)
            allow(subject).to receive(:deliver_message).and_return(true)
            allow(subject).to receive(:email_sender).and_return(email_dispatch_user)
            subject.save
          end

          it 'generates two messages, one for each manager' do
            expect(subject).to have_received(:deliver_message).exactly(2).times
          end
        end

        context 'from organization with one manager to organization with one manager' do
          subject { described_class.new(work_id: work.id, sending_user_id: organization2.id, receiving_user_id: organization.id, organization_transfer: true) }

          before do
            allow(subject).to receive(:deliver_message).and_return(true)
            allow(subject).to receive(:email_sender).and_return(email_dispatch_user)
          end

          it 'generates the correct message sent to the receiving org manager' do
            allow(subject).to receive(:send_org_transfer_message_to_sender).and_return(nil)
            subject.save

            expect(subject).to have_received(:deliver_message).with(
              email_dispatch_user,
              org_manager_1,
              "<a href=\"http://test.host/organizations/#{organization2.id}\">#{organization2.name}</a> has requested to transfer the ownership of <b><a href=\"http://test.host/concern/media/#{work.id}\">Media #{work.id}: example media title</a></b> to your managed organization (<a href=\"http://test.host/organizations/#{organization.id}\">#{organization.title.first}</a>). It is your choice whether to accept or reject this request. If you accept the request, your organization will become the data manager for this media. When accepting the request, you may choose to allow the original depositor to retain edit access to the media. Please accept or reject this request in your <a href=\"http://test.host/dashboard/transfers\">Ownership Transfers</a> dashboard. For more details, see our <a href='https://wiki.duke.edu/display/MD/Organization+Ownership+Transfers' target='_blank'>documentation</a>.",
              "You have a media transfer request"
            )
          end

          it 'generates the correct message sent to the sending org manager' do
            allow(subject).to receive(:send_org_transfer_message_to_receiver).and_return(nil)
            subject.save

            expect(subject).to have_received(:deliver_message).with(
              email_dispatch_user,
              org_manager_2,
              "A request to transfer ownership of <b><a href=\"http://test.host/concern/media/#{work.id}\">Media #{work.id}: example media title</a></b> to organization <a href=\"http://test.host/organizations/#{organization.id}\">#{organization.title.first}</a> has been generated. The organization manager(s) will decide to accept or reject this request. For more details, see our <a href='https://wiki.duke.edu/display/MD/Organization+Ownership+Transfers' target='_blank'>documentation</a>.",
              "Organization media transfer request generated"
            )
          end
        end

        context 'from organization with two managers to organization with one manager' do
          subject { described_class.new(work_id: work.id, sending_user_id: organization2.id, receiving_user_id: organization.id, organization_transfer: true) }

          before do
            organization2.managers << org_manager_3
            organization2.save
            
            allow(subject).to receive(:deliver_message).and_return(true)
            allow(subject).to receive(:email_sender).and_return(email_dispatch_user)
            
          end

          it 'generates three messages in total' do
            subject.save
            expect(subject).to have_received(:deliver_message).exactly(3).times
          end

          it 'generates two messages to sending org managers, one for each manager' do
            allow(subject).to receive(:send_org_transfer_message_to_receiver).and_return(nil)
            subject.save
            expect(subject).to have_received(:deliver_message).exactly(2).times
          end

          it 'generates one messages to receiving org manager' do
            allow(subject).to receive(:send_org_transfer_message_to_sender).and_return(nil)
            subject.save
            expect(subject).to have_received(:deliver_message).exactly(1).times
          end
        end

        context 'from organization with one manager to organization with two managers' do
          subject { described_class.new(work_id: work.id, sending_user_id: organization2.id, receiving_user_id: organization.id, organization_transfer: true) }

          before do
            organization.managers << org_manager_3
            organization.save
            allow(subject).to receive(:deliver_message).and_return(true)
            allow(subject).to receive(:email_sender).and_return(email_dispatch_user)
          end

          it 'generates three messages in total' do
            subject.save
            expect(subject).to have_received(:deliver_message).exactly(3).times
          end

          it 'generates one message to sending org manager' do
            allow(subject).to receive(:send_org_transfer_message_to_receiver).and_return(nil)
            subject.save
            expect(subject).to have_received(:deliver_message).exactly(1).times
          end

          it 'generates two messages to receiving org managers, one for each manager' do
            allow(subject).to receive(:send_org_transfer_message_to_sender).and_return(nil)
            subject.save
            expect(subject).to have_received(:deliver_message).exactly(2).times
          end
        end

        context 'from organization with two managers to organization with two managers' do
          subject { described_class.new(work_id: work.id, sending_user_id: organization2.id, receiving_user_id: organization.id, organization_transfer: true) }

          before do
            organization.managers << org_manager_3
            organization.save
            organization2.managers << org_manager_4
            organization.save
            allow(subject).to receive(:deliver_message).and_return(true)
            allow(subject).to receive(:email_sender).and_return(email_dispatch_user)
            
          end

          it 'generates four messages in total' do
            subject.save
            expect(subject).to have_received(:deliver_message).exactly(4).times
          end

          it 'generates two messages to sending org managers, one for each manager' do
            allow(subject).to receive(:send_org_transfer_message_to_receiver).and_return(nil)
            subject.save
            expect(subject).to have_received(:deliver_message).exactly(2).times
          end

          it 'generates two messages to receiving org managers, one for each manager' do
            allow(subject).to receive(:send_org_transfer_message_to_sender).and_return(nil)
            subject.save
            expect(subject).to have_received(:deliver_message).exactly(2).times
          end
        end
      end
    end
  end

  describe 'update' do
    let(:work)                { FactoryBot.create(:media) }
    let(:email_dispatch_user) { FactoryBot.create(:user) }
    let(:sending_user)        { FactoryBot.create(:contributor, email: "sender@email.com", display_name: "Sender") }
    let(:receiving_user)      { FactoryBot.create(:contributor, email: "receiver@email.com", display_name: "Receiver") }
    let(:org_manager_1)       { FactoryBot.create(:contributor, email: "org_manager_1@email.com", display_name: "Org Manager 1") }
    let(:organization)        { FactoryBot.create(:organization_collection, depositor: org_manager_1.ms_id) }
    let(:org_manager_2)       { FactoryBot.create(:contributor, email: "org_manager_2@email.com", display_name: "Org Manager 2") }
    let(:organization2)       { FactoryBot.create(:organization_collection, depositor: org_manager_2.ms_id) }
    let(:org_manager_3)       { FactoryBot.create(:contributor, email: "org_manager_3@email.com", display_name: "Org Manager 3") }

    context 'for standard or automated organization transfer' do
      context 'individual to individual' do
        subject { described_class.create(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id) }

        before do
          allow(subject).to receive(:deliver_message).and_return(true)
          allow(subject).to receive(:email_sender).and_return(email_dispatch_user)
          subject.transfer!
        end

        it 'successfully transfers media to individual receiver and is marked as accepted' do
          expect(subject.status).to eq 'accepted'
          work.reload
          expect(work.owner).to eq receiving_user.user_key
        end

        it 'generates correct message sent to the sender individual' do
          expect(subject).to have_received(:deliver_message).with(
            email_dispatch_user,
            sending_user,
            "Your request to transfer ownership of <b><a href=\"http://test.host/concern/media/#{work.id}\">Media #{work.id}: example media title</a></b> to <a href=\"http://test.host/users/#{receiving_user.user_key}\">Receiver</a> has been accepted.<p>Please contact <a href=\"http://test.host/users/#{receiving_user.user_key}\">Receiver</a> if you have a question related to this request.</p>",
            "Media transfer request accepted"
          )
        end 
      end

      context 'individual to organization' do
        subject { described_class.create(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: organization.id) }

        before do
          allow(subject).to receive(:deliver_message).and_return(true)
          allow(subject).to receive(:email_sender).and_return(email_dispatch_user)
          subject.transfer!
        end

        it 'successfully transfers media to organization receiver and is marked as accepted' do
          expect(subject.status).to eq 'accepted'
          work.reload
          expect(work.owner).to eq organization.id
        end

        it 'generates correct message sent to the sender individual' do
          expect(subject).to have_received(:deliver_message).with(
            email_dispatch_user,
            sending_user,
            "Your request to transfer ownership of <b><a href=\"http://test.host/concern/media/#{work.id}\">Media #{work.id}: example media title</a></b> to <a href=\"http://test.host/organizations/#{organization.id}\">#{organization.name}</a> has been accepted.<p>Please contact <a href=\"http://test.host/organizations/#{organization.id}\">#{organization.name}</a> if you have a question related to this request.</p>",
            "Media transfer request accepted"
          )
        end 
      end

      context 'organization with one data manager to individual' do
        subject { described_class.create(work_id: work.id, sending_user_id: organization2.id, receiving_user_id: receiving_user.id) }

        before do
          allow(subject).to receive(:deliver_message).and_return(true)
          allow(subject).to receive(:email_sender).and_return(email_dispatch_user)
          subject.transfer!
        end

        it 'successfully transfers media to individual receiver and is marked as accepted' do
          expect(subject.status).to eq 'accepted'
          work.reload
          expect(work.owner).to eq receiving_user.user_key
        end

        it 'generates correct message sent to the sender org manager' do
          expect(subject).to have_received(:deliver_message).with(
            email_dispatch_user,
            org_manager_2,
            "Your request to transfer ownership of <b><a href=\"http://test.host/concern/media/#{work.id}\">Media #{work.id}: example media title</a></b> to <a href=\"http://test.host/users/#{receiving_user.user_key}\">Receiver</a> has been accepted.<p>Please contact <a href=\"http://test.host/users/#{receiving_user.user_key}\">Receiver</a> if you have a question related to this request.</p>",
            "Media transfer request accepted"
          )
        end 
      end

      context 'organization with two data managers to individual' do
        subject { described_class.create(work_id: work.id, sending_user_id: organization2.id, receiving_user_id: receiving_user.id) }

        before do
          organization2.managers << org_manager_3
          organization2.save!
          allow(subject).to receive(:deliver_message).and_return(true)
          allow(subject).to receive(:email_sender).and_return(email_dispatch_user)
          subject.transfer!
        end

        it 'successfully transfers media to individual receiver and is marked as accepted' do
          expect(subject.status).to eq 'accepted'
          work.reload
          expect(work.owner).to eq receiving_user.user_key
        end

        it 'generates two messages sent to the sender org managers, one for each manager' do
          expect(subject).to have_received(:deliver_message).exactly(2).times
        end 
      end

      context 'organization with one data manager to organization' do
        subject { described_class.create(work_id: work.id, sending_user_id: organization2.id, receiving_user_id: organization.id) }

        before do
          allow(subject).to receive(:deliver_message).and_return(true)
          allow(subject).to receive(:email_sender).and_return(email_dispatch_user)
          subject.transfer!
        end

        it 'successfully transfers media to organization receiver and is marked as accepted' do
          expect(subject.status).to eq 'accepted'
          work.reload
          expect(work.owner).to eq organization.id
        end

        it 'generates correct message sent to the sender org manager' do
          expect(subject).to have_received(:deliver_message).with(
            email_dispatch_user,
            org_manager_2,
            "Your request to transfer ownership of <b><a href=\"http://test.host/concern/media/#{work.id}\">Media #{work.id}: example media title</a></b> to <a href=\"http://test.host/organizations/#{organization.id}\">#{organization.name}</a> has been accepted.<p>Please contact <a href=\"http://test.host/organizations/#{organization.id}\">#{organization.name}</a> if you have a question related to this request.</p>",
            "Media transfer request accepted"
          )
        end 
      end

      context 'organization with two data managers to organization' do
        subject { described_class.create(work_id: work.id, sending_user_id: organization2.id, receiving_user_id: organization.id) }

        before do
          organization2.managers << org_manager_3
          organization2.save!
          allow(subject).to receive(:deliver_message).and_return(true)
          allow(subject).to receive(:email_sender).and_return(email_dispatch_user)
          subject.transfer!
        end

        it 'successfully transfers media to organization receiver and is marked as accepted' do
          expect(subject.status).to eq 'accepted'
          work.reload
          expect(work.owner).to eq organization.id
        end

        it 'generates two messages sent to the sender org managers, one for each manager' do
          expect(subject).to have_received(:deliver_message).exactly(2).times
        end 
      end
    end
  end

  describe 'remove_deleted_transfers' do
    let(:media1)  { FactoryBot.create(:media, title: ['media1']) }
    let(:media2)  { FactoryBot.create(:media, title: ['media2']) }
    let(:media3)  { FactoryBot.create(:media, title: ['media3']) }
    let(:media)   { [media1, media2, media3] }

    let!(:contributor_role)  { Role.create(name: "contributor") }

    before do
      user6.make_contributor
      media.each do |m|
        ProxyDepositRequest.create(
        work_id: m.id, sending_user_id: user5.id, receiving_user_id: user6.id, status: "pending", sender_comment: "test")
      end
    end

    context 'there are no transfers' do
      it 'returns a blank array' do
        expect(described_class.remove_deleted_transfers([])).to match_array([])
      end
    end

    context 'all request media have solr docs' do
      it 'returns all requests' do
        expect(described_class.remove_deleted_transfers(ProxyDepositRequest.all)).to match_array(ProxyDepositRequest.all)
      end
    end

    context 'some request media are missing' do
      let(:deleted_media) { FactoryBot.create(:media, title: ['deleted media']) }
      before do
        ProxyDepositRequest.create(
          work_id: deleted_media.id, sending_user_id: user5.id, receiving_user_id: user6.id, status: "pending", sender_comment: "test")
        deleted_media.destroy!
      end
      it 'returns only the transfer requests for existing media' do
        expect(ProxyDepositRequest.all.map(&:work_id)).to match_array([media1.id, media2.id, media3.id, deleted_media.id])
        expect(described_class.remove_deleted_transfers(ProxyDepositRequest.all).map(&:work_id)).to match_array([media1.id, media2.id, media3.id])
      end
    end
  end

  describe 'incoming_for' do
    let!(:receiving_user) { FactoryBot.create(:contributor) }
    let(:work)            { FactoryBot.create(:media) }
    let(:organization)    { FactoryBot.create(:organization_collection, depositor: user6.ms_id) }
    let!(:proxy_deposit_request) {
      ProxyDepositRequest.create(
      work_id: work.id, sending_user_id: user5.id, receiving_user_id: organization.id, status: "pending", sender_comment: "test")
    }

    context 'receiving_user is the user' do
      before do
        proxy_deposit_request.receiving_user_id = receiving_user.id
        proxy_deposit_request.save!
      end
      it 'returns the request' do
        expect(ProxyDepositRequest.incoming_for(user: receiving_user, number_of_days: 'all')).to match_array([proxy_deposit_request])
      end
    end

    context 'receiving_user is an organization' do
      let(:work2)           { FactoryBot.create(:media) }
      let(:work3)           { FactoryBot.create(:media) }
      let(:organization2)   { FactoryBot.create(:organization_collection, depositor: user6.ms_id) }
      let(:organization3)   { FactoryBot.create(:organization_collection, depositor: user6.ms_id) }
      let(:proxy_deposit_request2) {
        ProxyDepositRequest.create(
        work_id: work2.id, sending_user_id: user5.id, receiving_user_id: organization2.id, status: "pending", sender_comment: "test")
      }
      let(:proxy_deposit_request3) {
        ProxyDepositRequest.create(
        work_id: work3.id, sending_user_id: user5.id, receiving_user_id: organization3.id, status: "pending", sender_comment: "test")
      }

      context 'user is an organization manager' do
        before do
          allow(receiving_user).to receive(:groups).and_return(["#{organization.id}_managers"])
        end
        it 'returns the request for organization managers' do
          expect(ProxyDepositRequest.incoming_for(user: receiving_user, number_of_days: 'all')).to match_array([proxy_deposit_request])
        end
      end

      context 'user is not an organization manager' do
        it 'does not return the request' do
          expect(ProxyDepositRequest.incoming_for(user: receiving_user, number_of_days: 'all')).to match_array([])
        end
      end
      context 'user manages multiple organizations' do
        before do
          [proxy_deposit_request2, proxy_deposit_request3].each(&:touch)
          allow(receiving_user).to receive(:groups).and_return(["#{organization.id}_managers", "#{organization2.id}_managers", "#{organization3.id}_managers"])
        end

        it 'returns the requests for organization managers' do
          expect(ProxyDepositRequest.incoming_for(user: receiving_user, number_of_days: 'all')).to match_array([proxy_deposit_request, proxy_deposit_request2, proxy_deposit_request3])
        end

        context 'user manages multiple organizations and individual media' do
          let(:work4) { FactoryBot.create(:media) }
          let(:work5) { FactoryBot.create(:media) }

          let!(:proxy_deposit_request4) { ProxyDepositRequest.create(work_id: work4.id, sending_user_id: user5.id, receiving_user_id: receiving_user.id, status: "pending", sender_comment: "test") }
          let!(:proxy_deposit_request5) { ProxyDepositRequest.create(work_id: work5.id, sending_user_id: user5.id, receiving_user_id: receiving_user.id, status: "pending", sender_comment: "test") }

          it 'returns the request for organization managers and individual requests' do
            expect(ProxyDepositRequest.incoming_for(user: receiving_user, number_of_days: 'all')).to match_array([proxy_deposit_request, proxy_deposit_request2, proxy_deposit_request3, proxy_deposit_request4, proxy_deposit_request5])
          end
        end
      end
    end
  end
end
