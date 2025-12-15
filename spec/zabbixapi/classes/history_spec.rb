require 'spec_helper'

describe 'ZabbixApi::History' do
  let(:history_mock) { ZabbixApi::History.new(client) }
  let(:client) { double }

  describe '.method_name' do
    subject { history_mock.method_name }

    it { is_expected.to eq 'history' }
  end

  describe '.identify' do
    subject { history_mock.identify }

    it { is_expected.to eq 'itemid' }
  end

  describe '.key' do
    subject { history_mock.key }

    it { is_expected.to eq 'itemid' }
  end

  describe 'constants' do
    it 'defines NUMERIC_FLOAT as 0' do
      expect(ZabbixApi::History::NUMERIC_FLOAT).to eq 0
    end

    it 'defines CHARACTER as 1' do
      expect(ZabbixApi::History::CHARACTER).to eq 1
    end

    it 'defines LOG as 2' do
      expect(ZabbixApi::History::LOG).to eq 2
    end

    it 'defines NUMERIC_UNSIGNED as 3' do
      expect(ZabbixApi::History::NUMERIC_UNSIGNED).to eq 3
    end

    it 'defines TEXT as 4' do
      expect(ZabbixApi::History::TEXT).to eq 4
    end

    it 'defines BINARY as 5' do
      expect(ZabbixApi::History::BINARY).to eq 5
    end
  end

  describe '.get' do
    subject { history_mock.get(data) }

    let(:data) { { itemids: '12345', history: 0 } }
    let(:api_result) do
      [
        { 'itemid' => '12345', 'clock' => '1351090996', 'value' => '0.085', 'ns' => '563157632' }
      ]
    end

    before do
      allow(history_mock).to receive(:log)
      allow(client).to receive(:api_request)
        .with(method: 'history.get', params: { output: 'extend', itemids: '12345', history: 0 })
        .and_return(api_result)
    end

    it 'calls the API with correct parameters' do
      expect(client).to receive(:api_request)
        .with(method: 'history.get', params: { output: 'extend', itemids: '12345', history: 0 })
      subject
    end

    it 'returns the API result' do
      expect(subject).to eq api_result
    end
  end

  describe '.get_latest' do
    subject { history_mock.get_latest(itemid, history_type) }

    let(:itemid) { '12345' }
    let(:history_type) { ZabbixApi::History::NUMERIC_UNSIGNED }
    let(:api_result) do
      [
        { 'itemid' => '12345', 'clock' => '1351090996', 'value' => '100', 'ns' => '563157632' }
      ]
    end

    before do
      allow(history_mock).to receive(:log)
      allow(history_mock).to receive(:get)
        .with(itemids: itemid, history: history_type, sortfield: 'clock', sortorder: 'DESC', limit: 1)
        .and_return(api_result)
    end

    it 'returns the first record' do
      expect(subject).to eq api_result.first
    end

    context 'when no data is returned' do
      let(:api_result) { [] }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '.get_latest_value' do
    subject { history_mock.get_latest_value(itemid, history_type) }

    let(:itemid) { '12345' }
    let(:record) { { 'itemid' => '12345', 'clock' => '1351090996', 'value' => '100', 'ns' => '563157632' } }

    before do
      allow(history_mock).to receive(:get_latest).with(itemid, history_type).and_return(record)
    end

    context 'with NUMERIC_UNSIGNED type' do
      let(:history_type) { ZabbixApi::History::NUMERIC_UNSIGNED }

      it 'returns the value as an integer' do
        expect(subject).to eq 100
      end
    end

    context 'with NUMERIC_FLOAT type' do
      let(:history_type) { ZabbixApi::History::NUMERIC_FLOAT }
      let(:record) { { 'itemid' => '12345', 'clock' => '1351090996', 'value' => '0.085', 'ns' => '563157632' } }

      it 'returns the value as a float' do
        expect(subject).to eq 0.085
      end
    end

    context 'with TEXT type' do
      let(:history_type) { ZabbixApi::History::TEXT }
      let(:record) { { 'itemid' => '12345', 'clock' => '1351090996', 'value' => 'hello', 'ns' => '563157632' } }

      it 'returns the value as-is' do
        expect(subject).to eq 'hello'
      end
    end

    context 'when no record is returned' do
      let(:history_type) { ZabbixApi::History::NUMERIC_UNSIGNED }
      let(:record) { nil }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '.get_range' do
    subject { history_mock.get_range(itemid, time_from, time_till, history_type) }

    let(:itemid) { '12345' }
    let(:time_from) { 1351090000 }
    let(:time_till) { 1351091000 }
    let(:history_type) { ZabbixApi::History::NUMERIC_UNSIGNED }
    let(:api_result) do
      [
        { 'itemid' => '12345', 'clock' => '1351090500', 'value' => '50', 'ns' => '0' },
        { 'itemid' => '12345', 'clock' => '1351090600', 'value' => '60', 'ns' => '0' }
      ]
    end

    before do
      allow(history_mock).to receive(:log)
      allow(history_mock).to receive(:get)
        .with(
          itemids: itemid,
          history: history_type,
          time_from: time_from,
          time_till: time_till,
          sortfield: 'clock',
          sortorder: 'ASC'
        )
        .and_return(api_result)
    end

    it 'returns history data within the time range' do
      expect(subject).to eq api_result
    end
  end

  describe '.count' do
    subject { history_mock.count(itemid, history_type, time_from, time_till) }

    let(:itemid) { '12345' }
    let(:history_type) { ZabbixApi::History::NUMERIC_UNSIGNED }
    let(:time_from) { nil }
    let(:time_till) { nil }

    before do
      allow(history_mock).to receive(:log)
      allow(history_mock).to receive(:get)
        .with({ itemids: itemid, history: history_type, countOutput: true })
        .and_return('42')
    end

    it 'returns the count as an integer' do
      expect(subject).to eq 42
    end
  end

  describe '.create' do
    subject { history_mock.create({}) }

    it 'raises an ApiError' do
      expect { subject }.to raise_error(ZabbixApi::ApiError, 'History does not support create operations')
    end
  end

  describe '.update' do
    subject { history_mock.update({}) }

    it 'raises an ApiError' do
      expect { subject }.to raise_error(ZabbixApi::ApiError, 'History does not support update operations')
    end
  end

  describe '.delete' do
    subject { history_mock.delete({}) }

    it 'raises an ApiError' do
      expect { subject }.to raise_error(ZabbixApi::ApiError, 'History does not support delete operations')
    end
  end
end
