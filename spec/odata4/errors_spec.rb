require 'spec_helper'

describe OData4::RequestError do
  subject { OData4::RequestError.new(response, 'The server made a boo-boo.') }
  let(:response) { instance_double('Faraday::Response', status: 400) }

  describe '#http_status' do
    it 'returns the status code' do
      expect(subject.http_status).to eq(response.status)
    end
  end

  describe '#response' do
    it 'returns the response' do
      expect(subject.response).to eq(response)
    end
  end

  describe '#message' do
    it 'returns the error message' do
      expect(subject.message).to eq('The server made a boo-boo.')
    end
  end
end

describe OData4::Errors::InternalServerError do
  let(:response) { instance_double('Faraday::Response', status: 500) }

  context 'with custom error message' do
    subject { OData4::Errors::InternalServerError.new(response, 'The server made a boo-boo.')}

    describe '#message' do
      it 'combines default message with custom message' do
        expect(subject.message).to eq('500 Internal Server Error: The server made a boo-boo.')
      end
    end
  end

  context 'without custom error message' do
    subject { OData4::Errors::InternalServerError.new(response) }

    describe '#message' do
      it 'returns the default message' do
        expect(subject.message).to eq('500 Internal Server Error')
      end
    end
  end
end
