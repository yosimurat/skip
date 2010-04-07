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

describe BoardEntry, "valid?" do
  describe '正しい値が設定されていない場合' do
    subject {
      @board_entry = BoardEntry.new
    }
    it { should_not be_valid }
    it { should have(1).errors_on(:title) }
    it { should have(1).errors_on(:contents) }
    it { should have(1).errors_on(:date) }
    it { should have(1).errors_on(:user) }
    it { should have(1).errors_on(:tenant) }
    it { should have(1).errors_on(:owner) }
    it { should have(1).errors_on(:last_updated) }
  end
  describe '正しい値が設定されている場合' do
    subject {
      @board_entry = BoardEntry.new({
        :title => "hoge",
        :contents => "hoge",
        :date => Time.now,
        :user => create_user,
        :tenant => create_tenant,
        :owner => create_user,
        :last_updated => Time.now,
        :publication_type => 'public'
      })
    }

    it { should be_valid }
  end
end

describe BoardEntry, '#validate' do
end

describe BoardEntry, '#before_create' do
end

describe BoardEntry, '#after_create' do
end

describe BoardEntry, '#after_save' do
  describe 'タグの作成' do
    describe 'タグが入力されていない場合' do
      before do
        @entry = create_board_entry :category => ''
        @entry.save
      end
      it { @entry.entry_tags.size.should == 0 }
    end
    describe 'タグが入力されている場合' do
      before do
        @entry = create_board_entry :category => SkipFaker.comma_tags(:qt => 2)
        @entry.save
      end
      it { @entry.entry_tags.size.should == 2 }
    end
  end
end

describe BoardEntry, '#full_accessible?' do
end

describe BoardEntry, '#accessible?' do
end

describe BoardEntry, '#accessible_without_writer?' do
end

describe BoardEntry, '#writer?' do
end

describe BoardEntry, '.unescape_href' do
  it "hrefの部分のみがアンエスケープされること" do
    text = <<-EOF
<a href=\"http://maps.google.co.jp/maps?f=q&amp;source=s_q&amp;hl=ja&amp;geocode=&amp;q=%E6%9D%B1%E4%BA%AC%E3%82%BF%E3%83%AF%E3%83%BC&amp;vps=1&amp;jsv=160f&amp;sll=36.5626,136.362305&amp;sspn=46.580215,79.101563&amp;ie=UTF8&amp;latlng=35658632,139745411,12292286392395809068&amp;ei=uX0fSoLaEIyyuwP5r8HtAw&amp;sig2=afRsS3vW83gTeW9KYfv0jg&amp;cd=1\">&amp;hoho</a>
EOF
    @result = BoardEntry.unescape_href(text)
    @result.should == <<-EOF
<a href="http://maps.google.co.jp/maps?f=q&source=s_q&hl=ja&geocode=&q=%E6%9D%B1%E4%BA%AC%E3%82%BF%E3%83%AF%E3%83%BC&vps=1&jsv=160f&sll=36.5626,136.362305&sspn=46.580215,79.101563&ie=UTF8&latlng=35658632,139745411,12292286392395809068&ei=uX0fSoLaEIyyuwP5r8HtAw&sig2=afRsS3vW83gTeW9KYfv0jg&cd=1">&amp;hoho</a>
EOF
  end

  it "2つaタグがある場合でもただしく動作すること" do
    text = "hoge<a href='/hoge?f=q&amp;hl=h1' id='ff'>aa\na</a>aa&amp;aa<a href=\"/fuga?f=q&amp;h=h\">bb&amp;b</a>"
    BoardEntry.unescape_href(text).should ==
      "hoge<a href='/hoge?f=q&hl=h1' id='ff'>aa\na</a>aa&amp;aa<a href=\"/fuga?f=q&h=h\">bb&amp;b</a>"
  end

  it '置換対象外の場合は引数がそのまま返ること' do
    BoardEntry.unescape_href('<p>foo</p>').should == '<p>foo</p>'
  end
end

describe BoardEntry, '.get_popular_tag_words' do
  describe "複数タグが見つかったとき" do
    before(:each) do
      @tag1 = mock_model(EntryTag)
      @tag1.stub!(:name).and_return('z')
      @tag2 = mock_model(EntryTag)
      @tag2.stub!(:name).and_return('a')
      @tag3 = mock_model(EntryTag)
      @tag3.stub!(:name).and_return('z')
      EntryTag.should_receive(:find).and_return([@tag1,@tag2,@tag3])
    end
    it "タグの名前をユニークして返す" do
      BoardEntry.get_popular_tag_words.should == ['z','a']
    end
  end
end

describe BoardEntry, '.categories_hash' do
end

describe BoardEntry, '#send_contact_mails' do
  describe 'メールを送信しない場合' do
    before do
      @entry = create_board_entry
      @entry.send_mail = '0'
    end
    it 'Emailが作られないこと' do
      lambda do
        @entry.send_contact_mails
      end.should change(Email, :count).by(0)
    end
  end
  describe 'メールを送信する場合' do
    before do
      @tenant = create_tenant
      @alice = create_user({:tenant => @tenant, :name => 'アリス', :admin => true})
      @jack = create_user({:tenant => @tenant, :name => 'ジャック', :admin => true})
      @nancy = create_user({:tenant => @tenant, :name => 'ナンシー', :admin => true})
    end
    describe '公開範囲が全体公開の場合' do
      before do
        @entry = create_board_entry(:tenant => @tenant, :owner => @alice, :publication_type => 'public', :user => @alice)
        @entry.send_mail = '1'
      end
      describe '全体へのメール送信が有効の場合' do
        before do
          Admin::Setting.[]=(@tenant, "enable_send_email_to_all_users", false)
        end
        it 'テナント内のアクティブなユーザ全員分(自分以外)のEmailが出来ていること' do
          lambda do
            @entry.send_contact_mails
          end.should change(Email, :count).by(@tenant.users.active.count - 1)
        end
      end
      describe '全体へのメール送信が無効の場合' do
        before do
          Admin::Setting.[]=(@tenant, "enable_send_email_to_all_users", false)
        end
        it 'Emailが作られないこと' do
          lambda do
            @entry.send_contact_mails
          end.should change(Email, :count).by(0)
        end
      end
    end
    describe '公開範囲が自分だけのブログの場合' do
      before do
        @entry = create_board_entry(:tenant => @tenant, :owner => @alice, :publication_type => 'private', :user => @alice)
        @entry.send_mail = '1'
      end
      it 'Emailが作られないこと' do
        lambda do
          @entry.send_contact_mails
        end.should change(Email, :count).by(0)
      end
    end
    describe '公開範囲が参加者のみのフォーラムの場合' do
      before do
        @group = create_group(:gid => 'skip_group', :name => 'SKIPグループ') do |g|
          g.group_participations.build(:user_id => @alice.id, :owned => true)
          g.group_participations.build(:user_id => @jack.id)
          g.group_participations.build(:user_id => @nancy.id)
        end
        @entry = create_board_entry(:symbol => @group.symbol, :publication_type => 'private', :user_id => @alice.id, :publication_symbols_value => @group.symbol)
        @entry.send_mail = '1'
      end
      it '参加者全員分(自分以外)のEmailが出来ていること' do
        lambda do
          @entry.send_contact_mails
        end.should change(Email, :count).by(2)
      end
      describe '記事を所有するグループが論理削除された場合' do
        before do
          @group.logical_destroy
        end
        it 'Emailに送信予定のレコードが作成されないこと' do
          lambda do
            @entry.send_contact_mails
          end.should_not change(Email, :count)
        end
      end
    end
  end
end

describe BoardEntry, '#send_trackbacks!' do
  before do
    @sato = create_user(:user_options => {:name => 'Sato'})
    @board_entry = create_board_entry
    @trackback_entry_1 = create_board_entry
    @trackback_entry_2 = create_board_entry
  end
  describe '2つの記事のidを話題の記事として指定する場合' do
    it '2件のentry_trackbacksが作成されること' do
      lambda do
        @board_entry.send_trackbacks!(@sato, [@trackback_entry_1, @trackback_entry_2].map(&:id).join(','))
      end.should change(EntryTrackback, :count).by(2)
    end
  end
  describe '2件のentry_trackbacksが作成済みの場合' do
    before do
      @board_entry.to_entry_trackbacks.create(:board_entry_id => @trackback_entry_1.id)
      @board_entry.to_entry_trackbacks.create(:board_entry_id => @trackback_entry_2.id)
    end
    describe '1つの記事のidを話題の記事として指定する場合' do
      it '1件のentry_trackbacksが削除されること' do
        lambda do
          @board_entry.send_trackbacks!(@sato, @trackback_entry_1.id.to_s)
        end.should change(EntryTrackback, :count).by(-1)
      end
    end
  end
end

describe BoardEntry, '#publication_users' do
  describe 'あるグループのフォーラムが存在する場合' do
    before do
      # あるグループの管理者がアリス, 参加者がマイク, デイブ(退職者)
      @alice = create_user :user_options => {:name => 'アリス', :admin => true}
      @mike = create_user :user_options => {:name => 'マイク', :admin => true}
      @dave = create_user :user_options => {:name => 'デイブ', :admin => true}, :status => 'RETIRED'
      @group = create_group(:gid => 'skip_group', :name => 'SKIPグループ') do |g|
        g.group_participations.build(:user_id => @alice.id, :owned => true)
        g.group_participations.build(:user_id => @mike.id, :owned => false)
        g.group_participations.build(:user_id => @dave.id, :owned => false)
      end
    end
    describe "アリスのブログで、そのグループ及びマイクが直接指定されている" do
      before do
        @entry = create_board_entry(:symbol => 'uid:alice', :publication_type => 'protected', :user_id => @alice.id, :publication_symbols_value => [@group, @mike].map(&:symbol).join(','))
      end
      it '公開されているユーザの配列が返ること' do
        @entry.publication_users.should == [@alice, @mike]
      end
      describe '記事を所有するグループが論理削除された場合' do
        before do
          @group.logical_destroy
        end
        it '公開されているユーザの配列が返ること' do
          @entry.publication_users.should == [@mike]
        end
      end
    end

    it "アリスのブログをprivateにしている場合、公開されているユーザの配列が返ること" do
      @entry = create_board_entry(:symbol => 'uid:alice', :publication_type => 'private', :user_id => @alice.id, :publication_symbols_value => "")
      @entry.publication_users.should == [@alice]
    end

    it "アリスのブログをpublicにしている場合、アクティブな全ユーザの配列が返ること" do
      @entry = create_board_entry(:symbol => 'uid:alice', :publication_type => 'public', :user_id => @alice.id, :publication_symbols_value => "")
      @entry.publication_users.size.should == User.active.all.size
    end

    it 'SKIPグループに private で公開されている記事の場合、公開されているユーザの配列が返ること' do
      @entry = create_board_entry(:symbol => 'gid:skip_group', :publication_type => 'private', :user_id => @alice.id, :publication_symbols_value => "")
      @entry.publication_users.should == [@alice, @mike]
    end

    it "SKIPグループで public に公開されている記事の場合、アクティブな全ユーザの配列a返ること" do
      @entry = create_board_entry(:symbol => 'gid:skip_group', :publication_type => 'public', :user_id => @alice.id, :publication_symbols_value => "")
      @entry.publication_users.size.should == User.active.all.size
    end
  end
end

describe BoardEntry, '#accessible_without_writer?' do
  before do
    @board_entry = stub_model(BoardEntry)
    @user = stub_model(User)
  end
  describe '指定されたユーザに記事の閲覧権限がある場合' do
    before do
      @board_entry.should_receive(:readable?).with(@user).and_return(true)
    end
    describe '指定されたユーザが記事の作者ではない場合' do
      before do
        @board_entry.should_receive(:writer?).with(@user.id).and_return(false)
      end
      it 'trueが返却されること' do
        @board_entry.accessible_without_writer?(@user).should be_true
      end
    end
    describe '指定されたユーザが記事の作者の場合' do
      before do
        @board_entry.should_receive(:writer?).with(@user.id).and_return(true)
      end
      it 'falseが返却されること' do
        @board_entry.accessible_without_writer?(@user).should be_false
      end
    end
  end
  describe '指定されたユーザに記事の閲覧権限がない場合' do
    before do
      @board_entry.should_receive(:readable?).with(@user).and_return(false)
    end
    it 'falseが返却されること' do
      @board_entry.accessible_without_writer?(@user).should be_false
    end
  end
end

describe BoardEntry, '#be_close!' do
  subject do
    creater = create_user(:user_options => {:name => 'Sato'}, :user_uid_options => {:uid => 'sato'})
    @board_entry = create_board_entry(:publication_type => 'protected', :entry_type => @entry_type, :symbol => @owner_symbol, :user_id => creater.id)
    @board_entry.entry_publications.create!(:symbol => 'uid:symbol')
    @board_entry.entry_editors.create!(:symbol => 'uid:symbol')
    @board_entry.be_close!
    @board_entry.reload
    @board_entry
  end

  describe 'ブログの場合' do
    before do
      @entry_type = 'DIARY'
      @owner_symbol = 'uid:sato'
    end
    it '公開範囲がprivateになること' do
      subject.publication_type.should == 'private'
    end

    it '関連するentry_publicationsが削除されること' do
      subject.entry_publications.should be_empty
    end

    it '関連するentry_editorsが削除されること' do
      subject.entry_editors.should be_empty
    end
  end

  describe 'フォーラムの場合' do
    before do
      @entry_type = 'GROUP_BBS'
      group = create_group(:gid => 'skip_group', :name => 'SKIPグループ')
      @owner_symbol = 'gid:skip_group'
    end
    it '公開範囲が変化しないこと' do
      subject.publication_type.should == 'protected'
    end

    it '関連するentry_publicationsが削除されないこと' do
      subject.entry_publications.should_not be_empty
    end

    it '関連するentry_editorsが削除されないこと' do
      subject.entry_editors.should_not be_empty
    end
  end
end

describe BoardEntry, '.be_hide_too_old' do
  before do
    BoardEntry.record_timestamps = false
    create_board_entry(:aim_type => 'question', :hide => false, :created_on => Time.now.ago(31.day))
    create_board_entry(:aim_type => 'question', :hide => false, :created_on => Time.now.ago(30.day))
    create_board_entry(:aim_type => 'question', :hide => false, :created_on => Time.now.ago(29.day))
  end

  describe '日数指定しない場合' do
    subject {
      BoardEntry.be_hide_too_old
    }
    it '30日より前の質問のみ閉じられること' do
      should == 1
    end
  end

  after do
    BoardEntry.record_timestamps = true
  end
end

describe BoardEntry, '#reflect_user_reading' do
  before do
    @tenant = create_tenant
    @alice = create_user({:tenant => @tenant, :name => 'アリス', :admin => true})
    @jack = create_user({:tenant => @tenant, :name => 'ジャック', :admin => true})
    @entry = create_board_entry(:tenant => @tenant, :owner => @alice, :publication_type => 'public', :user => @alice)
  end
  describe '記事の最終更新者が新着作成対象者と同一の場合' do
    it '未読が作成されないこと' do
      lambda do
        @entry.reflect_user_reading @alice
      end.should_not change(UserReading, :count)
    end
  end
  describe '記事の最終更新者が新着作成対象者と異なる場合' do
    describe 'そのユーザに記事の閲覧権限がある場合' do
      describe '記事の更新時刻以前に新着作成対象者の既読がある場合' do
        before do
          @user_reading = create_user_reading(:user => @jack, :board_entry => @entry, :read => true, :checked_on => @entry.last_updated.ago(1.minute))
        end
        subject {
          @entry.reflect_user_reading @jack
          @user_reading.reload
        }
        it 'その既読が未読に更新されること' do
          subject.read.should be_false
        end
        it 'その既読のチェック日時がクリアされること' do
          subject.checked_on.should be_nil
        end
      end
      describe '記事の更新時刻以前に新着作成対象者の既読がない場合' do
        subject {
          @entry.reflect_user_reading @jack
          UserReading.count
        }
        it { should == 1 }
      end
    end
    describe 'そのユーザに記事の閲覧権限がない場合' do
      before do
        @entry.should_receive(:accessible?).with(@jack).and_return(false)
      end
      it '未読が作成されないこと' do
        lambda do
          @entry.reflect_user_reading @jack
        end.should_not change(UserReading, :count)
      end
    end
  end
end
