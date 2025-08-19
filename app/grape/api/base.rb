module Api
  class Base < Grape::API
    version 'v1', using: :path
    prefix :api
    format :json

    include Api::Modules::ErrorsHandlers

		mount Api::Esim
  end
end