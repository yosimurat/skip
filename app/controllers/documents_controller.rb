class DocumentsController < ApplicationController
  skip_before_filter :login_required, :only => :show
  before_filter :only => :show do |c|
    c.send(:login_required, {:allow_unused_user => true})
  end

  def show
    if Document::DOCUMENT_NAMES.include?(params[:id])
      document = current_tenant.documents.find_by_id(params[:id])
      value = document ? document.value : Document.default_document_value(params[:id])
      render :text => value
    else
      render_404
    end
  end
end
