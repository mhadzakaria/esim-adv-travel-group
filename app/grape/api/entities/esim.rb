# frozen_string_literal: true

module Api
  module Entities
    class Esim < Grape::Entity
      # {
      #   "cid": "987654",
      #   "startISO": "2025-07-01T00:00:00.000Z",
      #   "endISO": "2025-07-10T23:59:59.000Z",
      #   "daysActive": 7,
      #   "totalBytes": 7398265432,
      #   "totalMB": 7398.27,
      #   "totalGB": 7.3983,
      #   "isTotalConsistent": true,
      #   "violations": [],
      #   "averages": {
      #     "activeDays": 7,
      #     "planDays": 10,
      #     "avgPerActiveDay": { "bytes": 1056895061.7, "MB": 1056.90, "GB": 1.0569 },
      #     "avgPerPlanDay": { "bytes": 739826543.2, "MB": 739.83, "GB": 0.7398 }
      #   },
      #   "aggregate": {
      #     "byCountry": [
      #       { "code": "US", "bytes": 6102345678, "MB": 6102.35, "GB": 6.1023 },
      #       { "code": "CA", "bytes": 1295919754, "MB": 1295.92, "GB": 1.2959 }
      #     ],
      #     "byDate": [
      #       { "date": "20250704", "bytes": 1459823645, "MB": 1459.82, "GB": 1.4598 },
      #       { "date": "20250705", "bytes": 1287341890, "MB": 1287.34, "GB": 1.2873 }
      #     ],
      #     # "topCountry": { "code": "US", "bytes": 6102345678, "MB": 6102.35, "GB": 6.1023 },
      #     "peakDate": { "date": "20250704", "bytes": 1459823645, "MB": 1459.82, "GB": 1.4598 }
      #   }
      # }
      # {
      #   "success": true,
      #   "message": "Berhasil mengambil detail order",
      #   "data": {
      #     "code": 0,
      #     "msg": null,
      #     "cid": "012345",
      #     "useSDate": "1754438400000",
      #     "useEDate": "1755302399000",
      #     "totalUsage": "4903782710",
      #     "esimStatus": 0,
      #     "simStatus": 0,
      #     "productType": 0,
      #     "itemList": [
      #       {
      #         "usageDate": "20250806",
      #         "mcc": "204",
      #         "code": "NL",
      #         "zhtw": "荷蘭",
      #         "enus": "Netherlands",
      #         "usage": "649310825"
      #       },
      #       {
      #         "usageDate": "20250809",
      #         "mcc": "262",
      #         "code": "DE",
      #         "zhtw": "德國",
      #         "enus": "Germany",
      #         "usage": "2392331444"
      #       },
      #       {
      #         "usageDate": "20250810",
      #         "mcc": "262",
      #         "code": "DE",
      #         "zhtw": "德國",
      #         "enus": "Germany",
      #         "usage": "1862140441"
      #       }
      #     ],
      #     "product_name": "eSIM Eropa Timur Balkan Big Data | 5GB 10 Hari",
      #     "attribute_variant": "[{\"variant_id\": \"85\", \"variant_name\": \"10 Hari\", \"variant_value\": null}, {\"variant_id\": \"152\", \"variant_name\": \"5GB\", \"variant_value\": null}]"
      #   },
      #   "statusCode": 200
      # }
      expose :cid do |obj|
        obj.dig("data", "cid")
      end

      def use_s_date
        Time.at(object.dig("data", "useSDate").to_i / 1000)
      end

      expose :startISO do |obj|
        use_s_date.utc
      end

      def use_e_date
        Time.at(object.dig("data", "useEDate").to_i / 1000)
      end

      expose :endISO do |obj|
        use_e_date.utc
      end

      def active_days
        Array(object.dig("data", "itemList")).group_by do |data_hash|
          data_hash["usageDate"].to_i
        end.keys.count
      end

      expose :activeDays do |obj|
        active_days
      end

      def sum_usage_bytes
        Array(object.dig("data", "itemList")).map do |data_hash|
          data_hash["usage"].to_i
        end.sum
      end

      expose :sumUsageBytes do |obj|
        sum_usage_bytes
      end

      expose :totalMB do |obj|
        exract_bytes(sum_usage_bytes / active_days)[:mb]
      end

      expose :totalGB do |obj|
        exract_bytes(sum_usage_bytes / active_days)[:gb]
      end

      expose :isTotalConsistent do |obj|
        object.dig("data", "totalUsage").to_i == sum_usage_bytes
      end

      expose :violations do |obj|
        Array(object.dig("data", "itemList")).select do |data_hash|
          current_date = DateTime.strptime(data_hash["usageDate"], "%Y%m%d")

          current_date > use_e_date
        end
      end

      expose :topCountry do |obj|
        Array(object.dig("data", "itemList")).sort_by do |data_hash|
          data_hash["usage"].to_i
        end.last
      end

      expose :peakDate do |obj|
        Array(object.dig("data", "itemList")).sort_by do |data_hash|
          data_hash["usage"].to_i
        end.last
      end

      def plan_days
        # WHY + 1
        ((use_e_date - use_s_date) / 1.day).to_i + 1
      end

      expose :planDays do |obj|
        plan_days
      end

      def exract_bytes(bytes)
        {
          bytes: bytes,
          mb: bytes / 1_000_000.0,
          gb: bytes / 1_000_000_000.0
        }
      end

      expose :avgPerActiveDay do |obj|
        exract_bytes(sum_usage_bytes / active_days)
      end

      expose :avgPerPlanDay do |obj|
        exract_bytes(sum_usage_bytes / plan_days)
      end
    end
  end
end