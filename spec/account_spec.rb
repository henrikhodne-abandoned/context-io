require 'spec_helper'

describe ContextIO::Account do
  let(:existing_account) do
    stub_request(:post, 'https://api.context.io/2.0/accounts').
      to_return(
        :body => '{
          "success": true,
          "id": "1234567890abcdef",
          "resource_url": "https://api.context.io/2.0/accounts/1234567890abcdef"
        }')
    account = ContextIO::Account.new(:email => 'foo@bar.com')
    account.save

    account
  end
  describe '.all' do
    before(:each) do
      json_accs = File.read(File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "accounts.json")))
      @stub = stub_request(:get, 'https://api.context.io/2.0/accounts').to_return(:body => json_accs)
    end

    it 'returns an array of Account objects' do
      accounts = ContextIO::Account.all
      accounts.first.should be_a(ContextIO::Account)
    end

    it 'calls the API request' do
      ContextIO::Account.all

      @stub.should have_been_requested
    end

    it 'sets the attributes on the Account objects' do
      ContextIO::Account.all.first.id.should == 'abcdef0123456789'
    end

    it 'sends a query if one is given' do
      @stub = @stub.with(:query => {
        :email => 'me@example.com',
        :status => 'OK',
        :status_ok => '1',
        :limit => '1',
        :offset => '0'
      })

      ContextIO::Account.all(
        :email => 'me@example.com',
        :status => :ok,
        :status_ok => true,
        :limit => 1,
        :offset => 0
      )

      @stub.should have_been_requested
    end
  end

  describe '.find' do
    before(:each) do
      @stub = stub_request(:get, 'https://api.context.io/2.0/accounts/abcdef0123456789').to_return(
        :body => '{
          "id": "abcdef0123456789",
          "username": "me.example.com_1234567890abcdef",
          "created": 1234567890,
          "suspended": 0,
          "email_addresses": [ "me@example.com" ],
          "first_name": "John",
          "last_name": "Doe",
          "password_expired": 0,
          "sources": [{
            "server": "mail.example.com",
            "label": "me::mail.example.com",
            "username": "me",
            "port": 993,
            "authentication_type": "password",
            "use_ssl": true,
            "sync_period": "1d",
            "status": "OK",
            "service_level": "pro",
            "type": "imap"
          }]
        }'
      )
    end

    it 'returns an instance of Account' do
      ContextIO::Account.find('abcdef0123456789').should be_a(ContextIO::Account)
    end

    it 'calls the API request' do
      ContextIO::Account.find('abcdef0123456789')

      @stub.should have_been_requested
    end

    it 'sets the attributes on the Account object' do
      ContextIO::Account.find('abcdef0123456789').id.should == 'abcdef0123456789'
    end
  end

  describe '.new' do
    it 'returns an instance of Account' do
      ContextIO::Account.new.should be_a(ContextIO::Account)
    end

    it 'sets the given attributes on the Account object' do
      account = ContextIO::Account.new(:first_name => 'John')
      account.first_name.should == 'John'
    end
  end

  describe '#save' do


    it 'returns true if the save was successful' do
      @stub = stub_request(:post, 'https://api.context.io/2.0/accounts').
        with(:body => { :email => 'me@example.com' }).
        to_return(
        :body => '{
          "success": true,
          "id": "abcdef0123456789",
          "resource_url": "https://api.context.io/2.0/accounts/abcdef0123456789"
        }'
      )

      account = ContextIO::Account.new(:email => 'me@example.com')

      account.save.should be_true
    end

    it 'returns false if the save was unsuccessful' do
      @stub = stub_request(:post, 'https://api.context.io/2.0/accounts').
        with(:body => { :email => 'me@example.com' }).
        to_return(
        :body => '{
          "success": false
        }'
      )

      account = ContextIO::Account.new(:email => 'me@example.com')

      account.save.should be_false
    end

    context 'for a new account' do
      before(:each) do
        @stub = stub_request(:post, 'https://api.context.io/2.0/accounts').
          with(:body => { :email => 'me@example.com' }).
          to_return(
          :body => '{
            "success": true,
            "id": "abcdef0123456789",
            "resource_url": "https://api.context.io/2.0/accounts/abcdef0123456789"
          }'
        )
      end

      it 'calls the API request' do
        ContextIO::Account.new(:email => 'me@example.com').save

        @stub.should have_been_requested
      end

      it 'sets the ID of the account' do
        account = ContextIO::Account.new(:email => 'me@example.com')
        account.save
        account.id.should == 'abcdef0123456789'
      end
    end

    context 'for an existing account' do
      it 'calls the API request' do
        @stub = stub_request(:put,
          'https://api.context.io/2.0/accounts/1234567890abcdef').
          with(:query => { :first_name => 'John' }).
          to_return(
          :body => '{
            "success": true
          }'
        )

        existing_account.first_name = 'John'
        existing_account.save

        @stub.should have_been_requested
      end
    end
  end

  describe '#update_attributes' do
    it 'calls the API request' do
      @stub = stub_request(:put,
        'https://api.context.io/2.0/accounts/1234567890abcdef').
        with(:query => { :first_name => 'John' }).
        to_return(
        :body => '{
          "success": true
        }'
      )

      existing_account.update_attributes(:first_name => 'John')

      @stub.should have_been_requested
    end

    it 'returns true if the update was successful' do
      stub_request(:put, 'https://api.context.io/2.0/accounts/1234567890abcdef').
        with(:query => { :first_name => 'John' }).
        to_return(
        :body => '{
          "success": true
        }'
      )

      existing_account.update_attributes(:first_name => 'John').should be_true
    end

    it 'returns false if the update was unsuccessful' do
      stub_request(:put, 'https://api.context.io/2.0/accounts/1234567890abcdef').
        with(:query => { :first_name => 'John' }).
        to_return(
        :body => '{
          "success": false
        }'
      )

      existing_account.update_attributes(:first_name => 'John').should be_false
    end


    it 'sets the attributes on the account object' do
      stub_request(:put, 'https://api.context.io/2.0/accounts/1234567890abcdef').
        with(:query => { :first_name => 'John' }).
        to_return(
        :body => '{
          "success": true
        }'
      )

      existing_account.update_attributes(:first_name => 'John')

      existing_account.first_name.should == 'John'
    end
  end

  describe '#sync_info' do
    it 'calls the API request' do
      @stub = stub_request(:get,
        'https://api.context.io/2.0/accounts/1234567890abcdef/sync').
        to_return(
        :body => '{
                    "me@example.com::mail.example.com": {
                      "INBOX": {
                        "initial_import_finished": true,
                        "last_expunge": 1234567890,
                        "last_sync_start": 1234567890,
                        "last_sync_stop": 1234567892
                      }
                    }
                  }')

      existing_account.sync_info

      @stub.should have_been_requested
    end
  end

  describe '#sync!' do
    it 'calls the API request' do
      @stub = stub_request(:post,
        'https://api.context.io/2.0/accounts/1234567890abcdef/sync')

      existing_account.sync!

      @stub.should have_been_requested
    end
  end
end

