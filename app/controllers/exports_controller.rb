class ExportsController < ApplicationController

  def new
    @export = ::Export.new
  end
  
  def create
    @export = ::Export.new(set_params)
    
    if @export.valid?
      begin
        send_data @export.process_file!, filename: "emails-#{Date.today}.csv" 
      rescue 
        render json: "Erro ao processar o arquivo, verifique o tamanho enviado"
      end
    else
      render action: :new
    end
  end

  private

  def set_params
    params.fetch(:export, {}).permit(:file, :version_one)
  end
end