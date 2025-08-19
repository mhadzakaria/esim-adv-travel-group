# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EsimDataParserService, type: :service do
  describe 'methods' do
    let(:data) do
      {
        'data' => {
          'cid' => 'some_cid',
          'useSDate' => '1672531200000', # 2023-01-01
          'useEDate' => '1672617599000', # 2023-01-01
          'totalUsage' => 1000,
          'itemList' => [
            { 'usageDate' => '20230101', 'usage' => '250', 'code' => 'US' },
            { 'usageDate' => '20230101', 'usage' => '750', 'code' => 'CA' }
          ]
        }
      }
    end
    let(:service) { described_class.new(data) }

    describe '#use_s_date' do
      it 'returns the start date' do
        expect(service.use_s_date).to eq(Time.at(1_672_531_200))
      end
    end

    describe '#startISO' do
      it 'returns the start date in ISO format' do
        expect(service.startISO).to eq(Time.at(1_672_531_200).utc)
      end
    end

    describe '#use_e_date' do
      it 'returns the end date' do
        expect(service.use_e_date).to eq(Time.at(1_672_617_599))
      end
    end

    describe '#endISO' do
      it 'returns the end date in ISO format' do
        expect(service.endISO).to eq(Time.at(1_672_617_599).utc)
      end
    end

    describe '#active_days' do
      it 'returns the number of active days' do
        expect(service.active_days).to eq(1)
      end
    end

    describe '#sum_usage_bytes' do
      it 'returns the sum of usage in bytes' do
        expect(service.sum_usage_bytes).to eq(data["data"]["totalUsage"])
      end
    end

    describe '#isTotalConsistent' do
      it 'returns true if total usage is consistent' do
        expect(service.isTotalConsistent).to be_truthy
      end
    end

    describe '#convert_usage_date' do
      it 'converts usage date to DateTime object' do
        expect(service.convert_usage_date('20230101')).to eq(DateTime.strptime('20230101', '%Y%m%d'))
      end
    end

    describe '#violations' do
      it 'returns an empty array when there are no violations' do
        expect(service.violations).to be_empty
      end
    end

    describe '#topCountry' do
      it 'returns the top country by usage' do
        expect(service.topCountry).to eq({
                                         "code" => "CA",
                                         "usageDate" => service.convert_usage_date('20230101'),
                                         "bytes" => 750,
                                         "mb" => 0.0008,
                                         "gb" => 0.0
                                       })
      end
    end

    describe '#peakDate' do
      it 'returns the peak date by usage' do
        expect(service.peakDate).to eq({
                                       "code" => "CA",
                                       "usageDate" => service.convert_usage_date('20230101'),
                                       "bytes" => 750,
                                       "mb" => 0.0008,
                                       "gb" => 0.0
                                     })
      end
    end

    describe '#plan_days' do
      it 'returns the number of plan days' do
        expect(service.plan_days).to eq(1)
      end
    end

    describe '#exract_bytes' do
      it 'converts bytes to MB and GB' do
        expect(service.exract_bytes(1_000_000_000)).to eq({
                                                            'bytes' => 1_000_000_000,
                                                            'mb' => 1000.0,
                                                            'gb' => 1.0
                                                          })
      end
    end

    describe '#avgPerActiveDay' do
      it 'returns the average usage per active day' do
        expect(service.avgPerActiveDay).to eq({
                                              'bytes' => 1000,
                                              'mb' => 0.001,
                                              'gb' => 0.0
                                            })
      end
    end

    describe '#avgPerPlanDay' do
      it 'returns the average usage per plan day' do
        expect(service.avgPerPlanDay).to eq({
                                            'bytes' => 1000,
                                            'mb' => 0.001,
                                            'gb' => 0.0
                                          })
      end
    end

    describe '#aggregate' do
      it 'returns the aggregated data' do
        expect(service.aggregate[:by_country]).to match_array([
                                                               { 'code' => 'US', 'usage' => 250, 'bytes' => 250, 'mb' => 0.0003, 'gb' => 0.0 },
                                                               { 'code' => 'CA', 'usage' => 750, 'bytes' => 750, 'mb' => 0.0008, 'gb' => 0.0 }
                                                             ])
        expect(service.aggregate[:by_date]).to eq([
                                                     { 'usageDate' => service.convert_usage_date('20230101'), 'usage' => 1000, 'bytes' => 1000,
                                                       'mb' => 0.001, 'gb' => 0.0 }
                                                   ])
      end
    end
  end
end
