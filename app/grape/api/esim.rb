module Api
  class Esim < Grape::API
    version 'v1', using: :path
    prefix :api

    resource :esim do
	    desc 'Get eSIM summary by CID'
	    get :summary do
	    	esim_serv = ::Esim.new
	    	datas = esim_serv.data
	    	record = datas.select { |e| e[:cid].eql?(params[:cid]) }.first

	      error!({ error: "cid not found" }, 404) if record.blank? # handle jika data tidak ditemukan

	      # # mencari date active dari iso end dan start
	      # day_active = DateTime.parse(record[:endISO]) - DateTime.parse(record[:startISO])
	      # record[:day_active] = day_active

				# normalizeAndValidate
				record[:useSDate] = DateTime.parse(record[:endISO]).to_i
				record[:useEDate] = DateTime.parse(record[:startISO]).to_i
				record[:daysActive] = (DateTime.parse(record[:endISO]) - DateTime.parse(record[:startISO])).to_i + 1
				record[:sumUsageBytes] = 0
				record[:aggregate][:byCountry].each do |data_hash|
					record[:sumUsageBytes] += data_hash[:bytes].to_i
				end
				record[:violations] = []
				end_date = DateTime.parse(record[:endISO])
				record[:aggregate][:byDate].each do |data_hash|
					current_date = DateTime.strptime(data_hash[:date], "%Y%m%d")

					next if current_date < end_date
					record[:violations] << data_hash
				end
				record[:isTotalConsistent] = record[:sumUsageBytes] == record[:totalBytes]

				top = record[:aggregate][:byCountry].sort_by do |data_hash|
					data_hash[:bytes]
				end.last
				record[:topCountry] = {
					gb: "#{top[:bytes]/1000_000_000} GB",
					mb: "#{top[:bytes]/1000_000} MB",
					country_code: top[:code]
				}

	      present record
	    rescue StandardError => e # handler gagal baca data atau ada yg tidak terhandler
	     	error!({ error: e.message }, 500)
	    end
    end
  end
end