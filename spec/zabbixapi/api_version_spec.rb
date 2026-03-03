require 'spec_helper'

describe 'ZabbixApi.api_version' do
  let(:url) { 'http://zabbix.example.com/api_jsonrpc.php' }
  let(:mock_http) { instance_double(Net::HTTP) }
  let(:mock_request) { instance_double(Net::HTTP::Post) }
  let(:response_body) do
    {
      'jsonrpc' => '2.0',
      'result' => '7.4.0',
      'id' => 1
    }.to_json
  end
  let(:response) { instance_double(Net::HTTPResponse, code: '200', body: response_body) }

  before do
    allow(Net::HTTP).to receive(:new).with('zabbix.example.com', 80).and_return(mock_http)
    allow(mock_http).to receive(:use_ssl=)
    allow(mock_http).to receive(:verify_mode=)
    allow(mock_http).to receive(:open_timeout=)
    allow(mock_http).to receive(:read_timeout=)
    allow(mock_http).to receive(:request).and_return(response)

    allow(Net::HTTP::Post).to receive(:new).and_return(mock_request)
    allow(mock_request).to receive(:add_field)
    allow(mock_request).to receive(:body=)
  end

  describe 'successful request' do
    it 'returns the API version string' do
      expect(ZabbixApi.api_version(url: url)).to eq('7.4.0')
    end

    it 'sends correct JSON-RPC request' do
      expected_body = {
        jsonrpc: '2.0',
        method: 'apiinfo.version',
        params: [],
        id: 1
      }
      expect(mock_request).to receive(:body=).with(JSON.generate(expected_body))
      ZabbixApi.api_version(url: url)
    end

    it 'sets Content-Type header' do
      expect(mock_request).to receive(:add_field).with('Content-Type', 'application/json-rpc')
      ZabbixApi.api_version(url: url)
    end

    it 'uses default timeout of 10 seconds' do
      expect(mock_http).to receive(:open_timeout=).with(10)
      expect(mock_http).to receive(:read_timeout=).with(10)
      ZabbixApi.api_version(url: url)
    end

    it 'accepts custom timeout' do
      expect(mock_http).to receive(:open_timeout=).with(30)
      expect(mock_http).to receive(:read_timeout=).with(30)
      ZabbixApi.api_version(url: url, timeout: 30)
    end
  end

  describe 'HTTPS support' do
    let(:https_url) { 'https://zabbix.example.com/api_jsonrpc.php' }

    before do
      allow(Net::HTTP).to receive(:new).with('zabbix.example.com', 443).and_return(mock_http)
    end

    it 'enables SSL for HTTPS URLs' do
      expect(mock_http).to receive(:use_ssl=).with(true)
      expect(mock_http).to receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
      ZabbixApi.api_version(url: https_url)
    end
  end

  describe 'error handling' do
    context 'when HTTP request fails' do
      let(:error_response) do
        instance_double(Net::HTTPResponse, code: '500', body: 'Internal Server Error').tap do |r|
          allow(r).to receive(:[]).and_return(nil)
        end
      end

      before do
        allow(mock_http).to receive(:request).and_return(error_response)
      end

      it 'raises HttpError' do
        expect { ZabbixApi.api_version(url: url) }.to raise_error(
          ZabbixApi::HttpError,
          "HTTP Error: 500 on #{url}"
        )
      end
    end

    context 'when API returns an error' do
      let(:response_body) do
        {
          'jsonrpc' => '2.0',
          'error' => {
            'code' => -32600,
            'message' => 'Invalid Request'
          },
          'id' => 1
        }.to_json
      end

      it 'raises ApiError' do
        expect { ZabbixApi.api_version(url: url) }.to raise_error(ZabbixApi::ApiError)
      end
    end
  end
end
