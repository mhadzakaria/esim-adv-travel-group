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
          'totalUsage' => 10000.0,
          'itemList' => [
            { 'usageDate' => '20230101', 'usage' => '2500', 'code' => 'US' },
            { 'usageDate' => '20230101', 'usage' => '7500', 'code' => 'CA' }
          ]
        }
      }
    end
    let(:service) { described_class.new(data) }

    describe '#startISO' do
      it 'returns the start date in ISO format' do
        expect(service.startISO).to eq(Time.at(1_672_531_200).utc)
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

    context 'when active_days is 0' do
      let(:data) { { 'data' => { 'itemList' => [] } } }
      it 'returns 0' do
        expect(service.active_days).to eq(0)
      end
    end

    describe '#isTotalConsistent' do
      it 'returns true if total usage is consistent' do
        expect(service.isTotalConsistent).to be_truthy
      end
    end

    context 'when isTotalConsistent is false' do
      let(:data) do
        {
          'data' => {
            'totalUsage' => 1001,
            'itemList' => [
              { 'usageDate' => '20230101', 'usage' => '500', 'code' => 'US' },
              { 'usageDate' => '20230101', 'usage' => '500', 'code' => 'CA' }
            ]
          }
        }
      end
      it 'returns false' do
        expect(service.isTotalConsistent).to be_falsy
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

    context 'when some data not match with start and end date / plan dates' do
      let(:data) do
        {
          'data' => {
            'useEDate' => '1672531200000', # 2023-01-01
            'itemList' => [
              { 'usageDate' => '20230102', 'usage' => '500', 'code' => 'US' }
            ]
          }
        }
      end
      it 'violations should not empty' do
        expect(service.violations).not_to be_empty
      end
    end

    describe '#topCountry' do
      it 'returns the top country by usage' do
        expect(service.topCountry).to eq({
                                         "code" => "CA",
                                         "usageDate" => service.convert_usage_date('20230101'),
                                         "bytes" => 7500,
                                         "mb" => 0.0075,
                                         "gb" => 0.0
                                       })
      end
    end

    describe '#peakDate' do
      it 'returns the peak date by usage' do
        expect(service.peakDate).to eq({
                                       "code" => "CA",
                                       "usageDate" => service.convert_usage_date('20230101'),
                                       "bytes" => 7500,
                                       "mb" => 0.0075,
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
                                              'bytes' => 10000.0,
                                              'mb' => 0.01,
                                              'gb' => 0.0
                                            })
      end
    end

    describe '#avgPerPlanDay' do
      it 'returns the average usage per plan day' do
        expect(service.avgPerPlanDay).to eq({
                                            'bytes' => 10000.0,
                                            'mb' => 0.01,
                                            'gb' => 0.0
                                          })
      end
    end

    describe '#aggregate' do
      it 'returns the aggregated data' do
        expect(service.aggregate[:by_country]).to match_array([
                                                               { 'code' => 'US', 'usage' => 2500, 'bytes' => 2500, 'mb' => 0.0025, 'gb' => 0.0 },
                                                               { 'code' => 'CA', 'usage' => 7500, 'bytes' => 7500, 'mb' => 0.0075, 'gb' => 0.0 }
                                                             ])
        expect(service.aggregate[:by_date]).to eq([
                                                     { 'usageDate' => service.convert_usage_date('20230101'), 'usage' => 10000.0, 'bytes' => 10000.0,
                                                       'mb' => 0.01, 'gb' => 0.0 }
                                                   ])
      end
    end

    describe '#by_country_aggregate' do
      context 'when usage is not sorted' do
        let(:data) do
          {
            'data' => {
              'itemList' => [
                { 'usageDate' => '20230101', 'usage' => '500', 'code' => 'US' },
                { 'usageDate' => '20230101', 'usage' => '1000', 'code' => 'CA' },
                { 'usageDate' => '20230101', 'usage' => '250', 'code' => 'MX' }
              ]
            }
          }
        end

        it 'returns the countries sorted by usage' do
          result = service.by_country_aggregate
          expect(result.first['code']).to eq('CA')
          expect(result.first['bytes']).to eq(1000)
        end
      end
    end
  end
end
