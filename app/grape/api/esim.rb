module Api
  class Esim < Grape::API
    version 'v1', using: :path
    prefix :api

    resource :esim do
      desc 'Get eSIM summary by CID'
      get :summary do
        esim_serv = ::Esim.new
        datas = esim_serv.data
        record = datas.select { |e| e.dig("data", "cid").eql?(params[:cid]) }.first

        error!({ error: "cid not found" }, 404) if record.blank? # handle jika data tidak ditemukan

        present record, with: ::Api::Entities::Esim
      rescue StandardError => e # handler gagal baca data atau ada yg tidak terhandler
        error!({ error: e.message }, 500)
      end
    end
  end
end