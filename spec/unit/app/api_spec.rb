require_relative '../../../app/api'
require 'rack/test'

module ExpenseTracker
  RSpec.describe 'API' do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    def parse_body
      JSON.parse(last_response.body)
    end

    let(:ledger) { instance_double('ExpenseTracker::Ledger') }

    describe 'POST /expenses' do
      context 'when the expense is successfully recorded' do
        let(:expense) { { 'some' => 'data' } }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(true, 417, nil))
        end

        it 'returns the expense id' do
          post '/expenses', JSON.generate(expense)

          parsed = parse_body
          expect(parsed).to include('expense_id' => 417)
        end
        it 'responds with a 200' do
          post '/expenses', JSON.generate(expense)

          expect(last_response.status).to eq(200)
        end
      end

      context 'when the expense fails validation' do
        let(:expense) { { 'some' => 'data' } }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(false, 417, 'Expense incomplete'))
        end

        it 'returns an error message' do
          post '/expenses', JSON.generate(expense)

          parsed = parse_body
          expect(parsed).to include('error' => 'Expense incomplete')
        end
        it 'responds with a 422' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(422)
        end
      end
    end

    describe 'GET /expenses/:date' do
      let(:today) { Date.today }
      let(:tomorrow) { Date.today.next_day(1) }

      context 'when expenses exists on the given date' do
        it 'returns the expense records as JSON'
        it 'responds with a 200 (OK)'
      end

      context 'when there are no expenses on the given date' do
        it 'returns an empty array as JSON' do
          get "/expenses/#{today}"

          parsed = parse_body

          expect(parsed).to eq([])
        end
        it 'responds with a 200 (OK)' do
          get "/expenses/#{today}"

          expect(last_response.status).to eq(200)
        end
      end
    end
  end
end
