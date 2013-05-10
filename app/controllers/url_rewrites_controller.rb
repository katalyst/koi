class UrlRewritesController < Koi::CrudController

  def redirect
    url_rewrite = UrlRewrite.active.find_by_from("#{request.path}")

    if url_rewrite
      redirect_to url_rewrite.to, status: :moved_permanently
    else
      raise ActiveRecord::RecordNotFound
    end
  end

end
