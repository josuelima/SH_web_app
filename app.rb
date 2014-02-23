require 'sinatra'
require 'httparty'
require 'json'

set :server, :thin

SERVICE_HUB_API_URL = "http://192.168.33.5:8080/api"

helpers do
  def servicos_all
    JSON.parse(HTTParty.get "#{SERVICE_HUB_API_URL}/servicos")
  end

  def recursos_by_tag tag
    JSON.parse(HTTParty.get "#{SERVICE_HUB_API_URL}/servicos/#{tag}")
  end

  def servico_recursos params
    @servico  = servicos_all.select { |s| s["tag"] == params[:tag] }
  	@recursos = recursos_by_tag(params[:tag])
  	return @servico, @recursos
  end
end

# Lista os servicos registrados
get '/' do
  @servicos = servicos_all
  erb :index
end

# Obtem recursos do servico selecionado
get '/servico/:tag' do
  @servico, @recurso = servico_recursos params
  erb :recursos
end

# Implementacao da interface para solicitacao do servico
get '/servico/:tag/:recurso' do
  @servico, @recurso = servico_recursos params
  erb :request
end

# Solicitacao o recurso selecionado ao ServiceHub
get '/request/:tag/:recurso' do
  @servico, @recurso = servico_recursos params
  @resposta = HTTParty.get @recurso.first["form_url"], query: params
  erb :resposta
end

post '/request/:tag/:recurso' do
  @servico, @recurso = servico_recursos params
  @resposta = HTTParty.post @recurso.first["form_url"], body: params
  erb :resposta
end