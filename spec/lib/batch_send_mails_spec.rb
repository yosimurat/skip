# SKIP(Social Knowledge & Innovation Platform)
# Copyright (C) 2008-2010 TIS Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

require File.dirname(__FILE__) + '/../spec_helper'

describe BatchSendMails, '#.execute' do
  before do
    @sender = BatchSendMails.new
    BatchSendMails.should_receive(:new).and_return(@sender)
    @sender.stub!(:send_message)
  end
  it 'messageメールの送信処理がおこなわれること' do
    @sender.should_receive(:send_message)
    BatchSendMails.execute []
  end
end

describe BatchSendMails, '#send_message' do
  before do
    @sender = BatchSendMails.new
  end
  describe 'messagesテーブルに未送信データがある場合' do
    before do
      @alice = create_user({:name => 'アリス'})
      @message = create_system_message(:user => @alice, :message_type => 'MESSAGE')
      @sender.stub!(:system_message_data).and_return(:message => 'message', :icon => 'icon', :url => 'url')
      ActionMailer::Base.deliveries.clear
    end
    describe '関連するuser_message_unsubscribesテーブルが存在する場合' do
      before do
        create_user_message_unsubscribe(:user => @alice, :message_type => 'MESSAGE')
      end
      it 'messagesテーブルの対象レコードが送信済みとなること' do
        @sender.send_message
        @message.reload.send_flag.should be_true
      end
      it 'メールが送信されないこと' do
        @sender.send_message
        ActionMailer::Base.deliveries.size == 0
      end
    end
    describe '関連するuser_message_unsubscribesテーブルが存在しない場合' do
      describe 'ユーザが退職していない場合' do
        it 'messagesテーブルの対象レコードが送信済みとなること' do
          @sender.send_message
          @message.reload.send_flag.should be_true
        end
        it 'メールが送信されること' do
          @sender.send_message
          ActionMailer::Base.deliveries.size == 1
        end
      end
      describe 'ユーザが退職している場合' do
        before do
          @alice.status = 'RETIRED'
          @alice.save
        end
        it 'messagesテーブルの対象レコードが送信済みとなること' do
          @sender.send_message
          @message.reload.send_flag.should be_true
        end
        it 'メールが送信されないこと' do
          @sender.send_message
          ActionMailer::Base.deliveries.size == 0
        end
      end
    end
  end
end
