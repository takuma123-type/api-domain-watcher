class Api::DomainWatchController < Api::BaseController
  skip_before_action :verify_authenticity_token

  def index
    usecase = Api::DomainWatchUsecase.new(
      input: Api::DomainWatchUsecase::Input.new(
        domainName: params[:domainName]
      )
    )
    @output = usecase.fetch
    render json: @output
  end  
end
