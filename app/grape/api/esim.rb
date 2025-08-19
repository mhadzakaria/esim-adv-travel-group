module Api
  class Esim < Grape::API
    version 'v1', using: :path
    prefix :api

    resource :esim do
      desc 'Get eSIM summary by CID'
      params do
        requires :cid, type: String
      end
      get :summary do
        datas = JSON.load_file("public/mock_orders_5.json")
        record = datas.select { |e| e.dig("data", "cid").eql?(params[:cid]) }.first

        # cid tidak ditemukan → 404 { "error": "cid not found" }.
        error!({ error: "cid not found" }, 404) if record.blank? # handle jika data tidak ditemukan

        present record, with: ::Api::Entities::Esim
      end
    end
  end
end