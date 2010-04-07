class DocumentsController < ApplicationController
  skip_before_filter :prepare_session, :only => :show
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
