# frozen_string_literal: true

class EsimDataParserService
  def initialize(data)
    @data = data
  end

  def cid
    @data.dig("data", "cid")
  end

  def use_s_date
    Time.at(@data.dig("data", "useSDate").to_i / 1000)
  end

  def startISO
    use_s_date.utc
  end

  def use_e_date
    Time.at(@data.dig("data", "useEDate").to_i / 1000)
  end

  def endISO
    use_e_date.utc
  end

  def active_days
    Array(@data.dig("data", "itemList")).group_by do |data_hash|
      data_hash["usageDate"]
    end.keys.count
  end

  def sum_usage_bytes
    Array(@data.dig("data", "itemList")).map do |data_hash|
      data_hash["usage"].to_i
    end.sum
  end

  def isTotalConsistent
    @data.dig("data", "totalUsage").to_i == sum_usage_bytes
  end

  def convert_usage_date(date)
    DateTime.strptime(date, "%Y%m%d")
  end

  def violations
    Array(@data.dig("data", "itemList")).select do |data_hash|
      current_date = convert_usage_date(data_hash["usageDate"])

      current_date > use_e_date
    end
  end

  def topCountry
    top = Array(@data.dig("data", "itemList")).sort_by do |data_hash|
      data_hash["usage"].to_i
    end.last.clone
    top.merge!(exract_bytes(top["usage"].to_i))
    top.merge!(usageDate: convert_usage_date(top["usageDate"]))
    top.delete("usage")
    top
  end

  def peakDate
    peak = Array(@data.dig("data", "itemList")).sort_by do |data_hash|
      data_hash["usage"].to_i
    end.last.clone
    peak.merge!(exract_bytes(peak["usage"].to_i))
    peak.merge!(usageDate: convert_usage_date(peak["usageDate"]))
    peak.delete("usage")
    peak
  end

  def plan_days
    # + 1 FOR HANDLE START OF DAY TO END OF DAY
    ((use_e_date - use_s_date) / 1.day).to_i + 1
  end

  # Konversi: MB = bytes/1_000_000, GB = bytes/1_000_000_000 (desimal).
  def exract_bytes(bytes)
    {
      "bytes" => bytes,
      "mb" => (bytes / 1_000_000.0).round(4),
      "gb" => (bytes / 1_000_000_000.0).round(2)
    }
  end

  def avgPerActiveDay
    exract_bytes(sum_usage_bytes / active_days)
  end

  def avgPerPlanDay
    exract_bytes(sum_usage_bytes / plan_days)
  end

  # Agregasi per-negara (code) & per-hari (usageDate).
  def aggregate
    {
      by_country: by_country_aggregate,
      by_date: by_date_aggregate
    }
  end

  def by_country_aggregate
    grouped_data = Array(@data.dig("data", "itemList")).group_by do |data_hash|
      data_hash["code"]
    end

    grouped_data.map do |key, datas|
      sum_selected_item_list_by_code(datas)
    end.sort_by { |data| data["bytes"].to_i }.reverse # Urutkan desc by bytes, stable jika sama
  end

  def sum_selected_item_list_by_code(datas)
    summed_data = { "code" => datas.first["code"] }
    datas.each do |data|
      summed_data["usage"] ||= 0
      summed_data["usage"] += data["usage"].to_i
    end

    summed_data.merge(exract_bytes(summed_data["usage"]))
  end

  def by_date_aggregate
    grouped_data = Array(@data.dig("data", "itemList")).group_by do |data_hash|
      data_hash["usageDate"]
    end

    grouped_data.map do |key, datas|
      sum_selected_item_list_by_date(datas)
    end.sort_by { |data| data["bytes"].to_i }.reverse # Urutkan desc by bytes, stable jika sama
  end

  def sum_selected_item_list_by_date(datas)
    summed_data = { "usageDate" => convert_usage_date(datas.first["usageDate"]) }
    datas.each do |data|
      summed_data["usage"] ||= 0
      summed_data["usage"] += data["usage"].to_i
    end

    summed_data.merge(exract_bytes(summed_data["usage"]))
  end
end