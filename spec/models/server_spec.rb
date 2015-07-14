require 'rails_helper'

describe Server do
  let(:server) { FactoryGirl.create(:server) }

  it 'has a valid server' do
    expect(server).to be_valid
  end

  it 'is invalid without an identifier' do
    server.identifier = ''
    expect(server).not_to be_valid
  end

  it 'is invalid without a name' do
    server.name = ''
    expect(server).not_to be_valid
  end

  it 'should be in the off state by default' do
    expect(server.state_building?).to be true
  end

  it 'is invalid without a valid user' do
    server.user = nil
    expect(server).not_to be_valid
  end

  it 'is invalid without a location' do
    server.location = nil
    expect(server).not_to be_valid
  end

  it 'is invalid without a template' do
    server.template = nil
    expect(server).not_to be_valid
  end

  describe 'Notifying of stuck states', type: :mailer  do
    def refresh_server
      ServerTasks.new.perform(:refresh_server, server.user.id, server.id)
    end

    before :each do
      @squall = double
      allow(Squall::VirtualMachine).to receive(:new).and_return(@squall)
      allow(@squall).to receive(:show).and_return({})
      # Simulate creating the server 1 hour ago.
      # Notifications should be triggered because the server has been building for longer
      # than Server::MAX_TIME_FOR_INTERMEDIATE_STATES
      server.update_attributes created_at: Time.zone.now - 1.hour
    end

    it 'should notify when a server has been building for an hour' do
      refresh_server
      email = ActionMailer::Base.deliveries.find do |e|
        e.subject =~ /Server stuck in intermediate stat/
      end
      expect(email.body).to match(/stuck in the building state/)
      expect(email.body).to match(/#{server.identifier}/)
    end

    it 'should only notify once' do
      refresh_server
      refresh_server
      emails = ActionMailer::Base.deliveries.select do |e|
        e.subject =~ /Server stuck in intermediate stat/
      end
      expect(emails.count).to eq 1
    end

    it 'should mark a server as unstuck after being stuck' do
      refresh_server
      server.reload
      expect(server.stuck).to be true

      allow(@squall).to receive(:show).and_return('booted' => true)
      refresh_server
      server.reload
      expect(server.stuck).to be false
    end
  end
end
