module Api
  class Base < Grape::API
    version 'v1', using: :path
    prefix :api
    format :json

		mount Api::Esim
  end
end