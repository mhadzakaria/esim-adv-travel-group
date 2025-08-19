# frozen_string_literal: true

module Api
  module Entities
    class Esim < Grape::Entity
      expose :cid do |obj|
        parser(obj).cid
      end

      expose :startISO do |obj|
        parser(obj).startISO
      end

      expose :endISO do |obj|
        parser(obj).endISO
      end

      expose :activeDays do |obj|
        parser(obj).active_days
      end

      expose :totalMB do |obj|
        parser(obj).exract_bytes(parser(obj).sum_usage_bytes)["mb"]
      end

      expose :totalGB do |obj|
        parser(obj).exract_bytes(parser(obj).sum_usage_bytes)["gb"]
      end

      expose :isTotalConsistent do |obj|
        parser(obj).isTotalConsistent
      end

      expose :violations do |obj|
        parser(obj).violations
      end

      expose :topCountry do |obj|
        parser(obj).topCountry
      end

      expose :peakDate do |obj|
        parser(obj).peakDate
      end

      expose :planDays do |obj|
        parser(obj).plan_days
      end

      expose :avgPerActiveDay do |obj|
        parser(obj).avgPerActiveDay
      end

      expose :avgPerPlanDay do |obj|
        parser(obj).avgPerPlanDay
      end

      expose :aggregate do |obj|
        parser(obj).aggregate
      end

      private

      def parser(obj)
        @parser ||= EsimDataParserService.new(obj)
      end
    end
  end
end