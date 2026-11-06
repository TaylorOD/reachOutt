class FrontendController < ActionController::Base
  def show
    path = Rails.root.join('public/app/index.html')
    if path.file?
      send_file path, type: 'text/html', disposition: 'inline'
    else
      render plain: 'Run npm run build to prepare the frontend.', status: :service_unavailable
    end
  end
end
