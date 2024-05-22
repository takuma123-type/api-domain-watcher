class Api::DomainWatchController < Api::BaseController
  skip_before_action :verify_authenticity_token

  def index
    puts "Received params: #{params.inspect}"
    usecase = Api::DomainWatchUsecase.new(
      input: Api::DomainWatchUsecase::Input.new(
        domainName: params[:domainName]
      )
    )
    @output = usecase.fetch
    render json: @output
  end  
end
