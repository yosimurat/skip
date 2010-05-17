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

describe ShareFile do
  before do
    @sg = create_tenant(:name => 'SonicGarden')
    @sg_alice = create_user(:tenant => @sg)
    @sg_group = create_group(:tenant => @sg)
  end
  describe ShareFile, '.accessible' do
    it { pending '[High]後で回帰テストを書く' }
  end

  describe ShareFile, '#validate' do
    before do
      @share_file = ShareFile.new
    end
    describe '権限チェック' do
      before do
        Tag.stub!(:validate_tags).and_return([])
      end
      describe '保存権限がある場合' do
        before do
          @share_file.should_receive(:full_accessible?).and_return(true)
        end
        it 'エラーメッセージが設定されないこと' do
          lambda do
            @share_file.validate
          end.should_not change(@share_file, :errors)
        end
      end
      describe '保存権限がない場合' do
        before do
          @share_file.should_receive(:full_accessible?).and_return(false)
          @errors = mock('errors')
          @errors.stub!(:add_to_base)
          @share_file.stub!(:errors).and_return(@errors)
        end
        it 'エラーメッセージが設定されること' do
          @share_file.errors.should_receive(:add_to_base).with('Operation inexecutable.')
          @share_file.validate
        end
      end
    end
  end

  describe ShareFile, '#validate_on_create' do
    before do
      @share_file = ShareFile.new
    end
    describe 'ファイルが指定されていない場合' do
      it 'valid_presence_of_fileのみ呼ばれること' do
        @share_file.should_receive(:valid_presence_of_file).and_return(false)
        @share_file.should_not_receive(:valid_extension_of_file)
        @share_file.should_not_receive(:valid_content_type_of_file)
        @share_file.should_not_receive(:validates_size_per_file)
        @share_file.should_not_receive(:validates_size_per_tenant)
        @share_file.validate_on_create
      end
    end
    describe 'ファイルが指定されている場合' do
      it 'fileに関するすべての検証メソッドが呼ばれること' do
        @share_file.should_receive(:valid_presence_of_file).and_return(true)
        @share_file.should_receive(:valid_extension_of_file)
        @share_file.should_receive(:valid_content_type_of_file)
        @share_file.should_receive(:validates_size_per_file)
        @share_file.should_receive(:validates_size_per_tenant)
        @share_file.validate_on_create
      end
    end
  end

  describe ShareFile, '#after_destroy' do
    before do
      @share_file = create_share_file(:tenant => @sg)
      ShareFile.stub!(:dir_path).and_return('dir_path')
      File.stub!(:delete)
    end
    describe '対象ファイルが存在する場合' do
      before do
        @full_path = 'full_path'
        @share_file.stub!(:full_path).and_return(@full_path)
      end
      it 'ファイル削除が呼ばれること' do
        File.should_receive(:delete).with(@full_path)
        @share_file.after_destroy
      end
    end
    describe '対象ファイルが存在しない場合' do
      before do
        File.should_receive(:delete).and_raise(Errno::ENOENT)
      end
      it '例外を送出しないこと' do
        lambda do
          @share_file.after_destroy
        end.should_not raise_error
      end
    end
  end

  describe ShareFile, '#full_accessible?' do
    it { pending '[High]後で回帰テストを書く' }
  end

  describe ShareFile, '#accessible?' do
    it { pending '[High]後で回帰テストを書く' }
  end

  describe ShareFile, '#accessible_without_writer?' do
    it { pending '[High]後で回帰テストを書く' }
  end

  describe ShareFile, '#create_history' do
    it { pending '[Low]後で回帰テストを書く' }
  end

  describe ShareFile, '#upload_file' do
    it { pending '[Low]後で回帰テストを書く' }
  end

  describe ShareFile, '#full_path' do
    before do
      @share_file_path = 'temp'
      GlobalInitialSetting["share_file_path"] = @share_file_path
      FileUtils.stub!(:mkdir_p)
      @file_name = 'sample.csv'
    end
    subject {
      @share_file.full_path
    }
    describe 'ユーザ所有の共有ファイルの場合' do
      before do
        @share_file = create_share_file(:tenant => @sg, :owner => @sg_alice, :file_name => @file_name)
      end
      it { should == File.join(@share_file_path, @sg.id.to_s, 'user', @sg_alice.id.to_s, @file_name) }
    end
    describe 'グループ所有の共有ファイルの場合' do
      before do
        @share_file = create_share_file(:tenant => @sg, :owner => @sg_group, :file_name => @file_name)
      end
      it { should == File.join(@share_file_path, @sg.id.to_s, 'group', @sg_group.id.to_s, @file_name) }
    end
  end

  describe ShareFile, '.total_file_size_per_owner' do
    it { pending '[Low]後で回帰テストを書く' }
  end

  describe ShareFile, '#file_size_with_unit' do
    before do
      @share_file = stub_model(ShareFile)
    end
    describe 'ファイルが存在しない場合' do
      before do
        @share_file.should_receive(:file_size).and_return(-1)
      end
      it '不明を返すこと' do
        @share_file.file_size_with_unit.should == '不明'
      end
    end
    describe 'ファイルが存在する場合' do
      describe 'ファイルサイズが1メガバイト以上の場合' do
        before do
          @size = 1.megabyte
          @share_file.should_receive(:file_size).and_return(@size)
        end
        it 'メガバイト表示が返ること' do
          @share_file.file_size_with_unit.should == "#{@size/1.megabyte}Mbyte"
        end
      end
      describe 'ファイルサイズが1メガバイト未満の場合' do
        describe 'ファイルサイズが1キロバイト以上の場合' do
          it 'キロバイト表示が返ること' do
            size = 1.kilobyte
            @share_file.should_receive(:file_size).and_return(size)
            @share_file.file_size_with_unit.should == "#{size/1.kilobyte}Kbyte"
          end
        end
        describe 'ファイルサイズが1キロバイト未満の場合' do
          before do
            @size = 1.kilobyte - 1
          end
          it 'バイト表示が返ること' do
            @share_file.should_receive(:file_size).and_return(@size)
            @share_file.file_size_with_unit.should == "#{@size}byte"
          end
        end
      end
    end
  end

  describe ShareFile, '#to_draft' do
    it { pending '[Low]後で回帰テストを書く' }
  end

  describe ShareFile, '#uncheck_extention?' do
    describe 'authenticityチェックしない拡張子(uncheck.jpg)の場合' do
      before do
        @share_file = stub_model(ShareFile, :file_name => 'uncheck.jpg')
      end
      it 'trueを返すこと' do
        @share_file.send(:uncheck_extention?).should be_true
      end
    end

    describe 'authenticityチェックしない拡張子(uncheck.JPG)の場合' do
      before do
        @share_file = stub_model(ShareFile, :file_name => 'uncheck.JPG')
      end
      it 'trueを返すこと' do
        @share_file.send(:uncheck_extention?).should be_true
      end
    end

    describe 'authenticityチェックする拡張子の場合' do
      before do
        @share_file = stub_model(ShareFile, :file_name => 'uncheck.xls')
      end
      it 'falseを返すこと' do
        @share_file.send(:uncheck_extention?).should be_false
      end
    end

    describe '拡張子がなく、紛らわしいファイル名の場合' do
      before do
        @share_file = stub_model(ShareFile, :file_name => 'jpg')
      end
      it 'falseを返すこと' do
        @share_file.send(:uncheck_extention?).should be_false
      end
    end
  end

  describe ShareFile, '#uncheck_authenticity?' do
    before do
      @share_file = stub_model(ShareFile)
    end
    describe 'チェックしない拡張子の場合' do
      before do
        @share_file.should_receive(:uncheck_extention?).and_return(true)
      end
      describe 'チェックしないContent-Typeの場合' do
        before do
          @share_file.should_receive(:uncheck_content_type?).and_return(true)
        end
        it 'trueを返すこと' do
          @share_file.uncheck_authenticity?.should be_true
        end
      end
      describe 'チェックするContent-Typeの場合' do
        before do
          @share_file.should_receive(:uncheck_content_type?).and_return(false)
        end
        it 'falseを返すこと' do
          @share_file.uncheck_authenticity?.should be_false
        end
      end
    end
    describe 'チェックする拡張子の場合' do
      before do
        @share_file.should_receive(:uncheck_extention?).and_return(false)
      end
      it 'falseを返すこと' do
        @share_file.uncheck_authenticity?.should be_false
      end
    end
  end
end

