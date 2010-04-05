class Document < ActiveRecord::Base
  belongs_to :tenant

  validates_uniqueness_of :name, :scope => :tenant_id
  DOCUMENT_NAMES = %w(about_this_site rules).freeze
  validates_inclusion_of :name, :in => DOCUMENT_NAMES

  validates_presence_of :value
  validates_presence_of :tenant

  def before_save
    # TODO これなんでやってるんだっけ? 理由を確認して不要なら無くしたい
    html_wrapper = <<-EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="ja" xml:lang="ja" xmlns="http://www.w3.org/1999/xhtml">
<head xmlns="">
  <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
  <title>TITLE_STR</title>
</head>
<body style="padding: 10px;">
BODY
</body>
</html>
    EOF
    self.value = html_wrapper.sub('BODY', self.value)
    self.value = self.value.sub('TITLE_STR', ERB::Util.h(self.name.humanize))
  end

  def self.default_document_value document_name
    target_lang =
      if locale = Locale::Tag.parse(I18n.locale).language and File.exist?(RAILS_ROOT + "/locale/#{locale}/html/default_#{document_name}.html")
        locale
      else
        'en'
      end
    document_value = open(RAILS_ROOT + "/locale/#{target_lang}/html/default_#{document_name}.html", 'r') { |f| f.read }
  end

  def to_param
    self.name
  end
end
