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

describe BoardEntry do
  before do
    @sg = create_tenant(:name => 'SonicGarden')
    @sg_alice = create_user(:tenant => @sg)
    @sg_dave = create_user(:tenant => @sg)
    @sg_mike = create_user(:tenant => @sg)
    @sug = create_tenant(:name => 'SKIPUserGroup')
    @sug_carol = create_user(:tenant => @sug)
  end
  describe BoardEntry, '.accessible' do
    subject do
      BoardEntry.accessible(@sg_alice)
    end
    context '公開されている記事' do
      before do
        @sg_public_entry = create_board_entry(:tenant => @sg, :publication_type => 'public')
        @sug_public_entry = create_board_entry(:tenant => @sug, :publication_type => 'public')
      end
      it '全体に公開されている記事が取得出来ること' do
        should be_include(@sg_public_entry)
      end
      it '別のテナントの全体公開の記事が取得出来ないこと' do
        should_not be_include(@sug_public_entry)
      end
      context '参加グループのIDと一致するIDを持つ別のテナントのユーザの公開されている記事' do
        before do
          @sg_group = create_group(:tenant => @sg)
          @sg_group.group_participations.build(:user => @sg_alice).join!(@sg_alice)
          @sug_carol.stub(:id).and_return(@sg_group.id)
          @sug_carol_public_entry = create_board_entry(:tenant => @sug, :publication_type => 'public', :owner => @sug_carol)
        end
        it '別のテナントの全体公開の記事が取得出来ないこと' do
          should_not be_include(@sug_carol_public_entry)
        end
      end
    end
    context '下書き記事' do
      before do
        with_options(:publication_type => 'private') do |me|
          @sg_alice_private_entry = me.create_board_entry(:tenant => @sg, :owner => @sg_alice)
          @sg_dave_private_entry = me.create_board_entry(:tenant => @sg, :owner => @sg_dave)
          @sug_carol_private_entry = me.create_board_entry(:tenant => @sug, :owner => @sug_carol)
        end
      end
      it '自分の下書き記事を取得出来ること' do
        should be_include(@sg_alice_private_entry)
      end
      it '他人の下書き記事を取得出来ないこと' do
        should_not be_include(@sg_dave_private_entry)
      end
      it '別のテナントの下書き記事を取得出来ないこと' do
        should_not be_include(@sug_carol_private_entry)
      end
    end
    context 'フォーラム記事' do
      before do
        @sg_group = create_group(:tenant => @sg)
        @sg_group.group_participations.build(:user => @sg_alice).join!(@sg_alice)
        @sg_group.group_participations.build(:user => @sg_dave).join!(@sg_dave)
        with_options(:tenant => @sg, :publication_type => 'private', :owner => @sg_group) do |me|
          @sg_group_alice_private_entry = me.create_board_entry(:user => @sg_alice)
          @sg_group_dave_private_entry = me.create_board_entry(:user => @sg_dave)
        end
        @sg_another_group = create_group(:tenant => @sg)
        @sg_another_group.group_participations.build(:user => @sg_dave).join!(@sg_dave)
        with_options(:tenant => @sg, :publication_type => 'private', :owner => @sg_another_group) do |me|
          @sg_another_group_dave_private_entry = me.create_board_entry(:user => @sg_dave)
        end
      end
      it '参加グループの自分の記事が取得出来ること' do
        should be_include(@sg_group_alice_private_entry)
      end
      it '参加グループの他人の記事が取得出来ること' do
        should be_include(@sg_group_dave_private_entry)
      end
      it '未参加グループの記事が取得出来ないこと' do
        should_not be_include(@sg_another_group_dave_private_entry)
      end
    end
  end

  describe BoardEntry, "valid?" do
    describe '正しい値が設定されていない場合' do
      subject {
        BoardEntry.new
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
        BoardEntry.new({
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
    it { pending '後で回帰テストを書く' }
  end

  describe BoardEntry, '#before_create' do
    it { pending '後で回帰テストを書く' }
  end

  describe BoardEntry, '#after_create' do
    it { pending '後で回帰テストを書く' }
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
    it { pending '[High]後で回帰テストを書く' }
  end

  describe BoardEntry, '#accessible?' do
    it { pending '[High]後で回帰テストを書く' }
  end

  describe BoardEntry, '#accessible_without_writer?' do
    it { pending '[High]後で回帰テストを書く' }
  end

  describe BoardEntry, '#writer?' do
    it { pending '[High]後で回帰テストを書く' }
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
    it { pending '[Low]後で回帰テストを書く' }
  end

  describe BoardEntry, '.categories_hash' do
    it { pending '[Low]後で回帰テストを書く' }
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
            Admin::Setting.set_enable_send_email_to_all_users(@tenant, true)
          end
          it 'アクティブなユーザ全員分のEmailが出来ていること' do
            lambda do
              @entry.send_contact_mails
            end.should change(Email, :count).by(@tenant.users.active.count)
          end
        end
        describe '全体へのメール送信が無効の場合' do
          before do
            Admin::Setting.set_enable_send_email_to_all_users(@tenant, 'false')
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
        it '自分宛のEmailが作られること' do
          lambda do
            @entry.send_contact_mails
          end.should change(Email, :count).by(1)
        end
      end
      describe '公開範囲が参加者のみのフォーラムの場合' do
        before do
          @group = create_group(:name => 'SKIPグループ') do |g|
            g.group_participations.build(:user_id => @alice.id, :owned => true)
            g.group_participations.build(:user_id => @jack.id)
            g.group_participations.build(:user_id => @nancy.id)
          end
          @entry = create_board_entry(:tenant => @sg, :publication_type => 'private', :user_id => @alice.id, :owner => @group)
          @entry.send_mail = '1'
        end
        it '参加者全員分のEmailが出来ていること' do
          lambda do
            @entry.send_contact_mails
          end.should change(Email, :count).by(3)
        end
        describe '記事を所有するグループが削除された場合' do
          before do
            @group.destroy
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

  describe BoardEntry, '#accessed' do
    it { pending '後で回帰テストを書く' }
  end

  describe BoardEntry, '#send_trackbacks!' do
    before do
      @board_entry = create_board_entry(:tenant => @sg, :publication_type => 'public')
      @trackback_entry_1 = create_board_entry(:tenant => @sg, :publication_type => 'public')
      @trackback_entry_2 = create_board_entry(:tenant => @sg, :publication_type => 'public')
    end
    describe '2つの記事のidを話題の記事として指定する場合' do
      it '2件のentry_trackbacksが作成されること' do
        lambda do
          @board_entry.send_trackbacks!(@sg_alice, [@trackback_entry_1, @trackback_entry_2].map(&:id).join(','))
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
            @board_entry.send_trackbacks!(@sg_alice, @trackback_entry_1.id.to_s)
          end.should change(EntryTrackback, :count).by(-1)
        end
      end
    end
  end

  describe BoardEntry, '#publication_users' do
    describe 'あるグループのフォーラムが存在する場合' do
      before do
        # あるグループの管理者がアリス, 参加者がマイク, デイブ(退職者)
        @sg_dave.update_attribute('status', 'RETIRED')
        @sg_group = create_group(:tenant => @sg, :name => 'SKIPグループ')
        @sg_group.group_participations.build(:user => @sg_alice, :owned => true).join!(@sg_alice)
        @sg_group.group_participations.build(:user => @sg_mike, :owned => false).join!(@sg_mike)
        @sg_group.group_participations.build(:user => @sg_dave, :owned => false).join!(@sg_dave)
      end
      subject {
        @entry.publication_users
      }
      context 'アリスのprivateなブログ' do
        before do
          @entry = create_board_entry(:tenant => @sg, :publication_type => 'private', :user_id => @sg_alice.id, :owner => @sg_alice)
        end
        it 'アリスのみの配列が返ること' do
          should == [@sg_alice]
        end
      end

      context 'アリスのpublicなブログ' do
        before do
          @entry = create_board_entry(:tenant => @sg, :publication_type => 'public', :user_id => @sg_alice.id, :owner => @sg_alice)
        end
        it "アクティブな全ユーザの配列が返ること" do
          subject.size.should == @sg.users.active.count
        end
      end

      context 'SKIPグループにprivateで公開されているフォーラム' do
        before do
          @entry = create_board_entry(:tenant => @sg, :publication_type => 'private', :user_id => @sg_alice.id, :owner => @sg_group)
        end
        it '作成者以外のグループ参加ユーザの配列が返ること' do
          should == [@sg_alice, @sg_mike]
        end
      end

      context 'SKIPグループにpublicに公開されているフォーラム' do
        before do
          @entry = create_board_entry(:tenant => @sg, :publication_type => 'public', :user_id => @sg_alice.id, :owner => @sg_group)
        end
        it "アクティブな全ユーザの配列が返ること" do
          subject.size.should == @sg.users.active.count
        end
      end
    end
  end

  describe BoardEntry, '#toggle_hide' do
    it { pending '後で回帰テストを書く' }
  end

  describe BoardEntry, '#be_close!' do
    subject do
      @board_entry = create_board_entry(:tenant => @sg, :publication_type => 'public', :user_id => @sg_alice.id, :owner => @owner)
      @board_entry.be_close!
      @board_entry.reload
      @board_entry
    end

    describe 'ブログの場合' do
      before do
        @owner = @sg_alice
      end
      it '公開範囲がprivateになること' do
        subject.publication_type.should == 'private'
      end
    end

    describe 'フォーラムの場合' do
      before do
        group = create_group(:tenant => @sg, :name => 'SKIPグループ')
        @owner = group
      end
      it '公開範囲が変化しないこと' do
        subject.publication_type.should == 'public'
      end
    end
  end

  describe BoardEntry, '.be_hide_too_old' do
    before do
      BoardEntry.record_timestamps = false
      create_board_entry(:tenant => @sg, :aim_type => 'question', :hide => false, :created_on => Time.now.ago(31.day))
      create_board_entry(:tenant => @sg, :aim_type => 'question', :hide => false, :created_on => Time.now.ago(30.day))
      create_board_entry(:tenant => @sg, :aim_type => 'question', :hide => false, :created_on => Time.now.ago(29.day))
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
      @entry = create_board_entry(:tenant => @sg, :owner => @sg_alice, :publication_type => 'public', :user => @sg_alice)
    end
    describe '記事の最終更新者が新着作成対象者と同一の場合' do
      it '未読が作成されないこと' do
        lambda do
          @entry.reflect_user_reading @sg_alice
        end.should_not change(UserReading, :count)
      end
    end
    describe '記事の最終更新者が新着作成対象者と異なる場合' do
      describe 'そのユーザに記事の閲覧権限がある場合' do
        describe '記事の更新時刻以前に新着作成対象者の既読がある場合' do
          before do
            @user_reading = create_user_reading(:user => @sg_dave, :board_entry => @entry, :read => true, :checked_on => @entry.last_updated.ago(1.minute))
          end
          subject {
            @entry.reflect_user_reading @sg_dave
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
            @entry.reflect_user_reading @sg_dave
            UserReading.count
          }
          it { should == 1 }
        end
      end
      describe 'そのユーザに記事の閲覧権限がない場合' do
        before do
          @entry.should_receive(:accessible?).with(@sg_dave).and_return(false)
        end
        it '未読が作成されないこと' do
          lambda do
            @entry.reflect_user_reading @sg_dave
          end.should_not change(UserReading, :count)
        end
      end
    end
  end
end
