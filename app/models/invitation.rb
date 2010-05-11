class Invitation < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :email, :body
  validates_format_of :email, :message =>_('requires proper format.'), :with => Authentication.email_regex

  attr_accessor :body_template

  def before_create
    self.body = "#{self.body}\n\n#{self.body_template}"
  end
end
