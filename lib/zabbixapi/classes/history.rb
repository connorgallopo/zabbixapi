class ZabbixApi
  class History < Basic
    # History value types
    NUMERIC_FLOAT    = 0
    CHARACTER        = 1
    LOG              = 2
    NUMERIC_UNSIGNED = 3
    TEXT             = 4
    BINARY           = 5

    # The method name used for interacting with History via Zabbix API
    #
    # @return [String]
    def method_name
      'history'
    end

    # The id field name used for identifying specific History objects via Zabbix API
    #
    # @return [String]
    def identify
      'itemid'
    end

    # The key field name used for History objects via Zabbix API
    # Note: History doesn't have a unique identifier per record
    #
    # @return [String]
    def key
      'itemid'
    end

    # Get history data from Zabbix API
    #
    # @param data [Hash] Should include itemids and optionally other filter parameters
    # @option data [Integer] :history History value type (0-5, default: 3)
    #   - 0: numeric float
    #   - 1: character
    #   - 2: log
    #   - 3: numeric unsigned (default)
    #   - 4: text
    #   - 5: binary
    # @option data [Array, Integer, String] :itemids Item IDs to retrieve history for
    # @option data [Array, Integer, String] :hostids Filter by host IDs
    # @option data [Integer] :time_from Return values after this timestamp (inclusive)
    # @option data [Integer] :time_till Return values before this timestamp (inclusive)
    # @option data [String, Array] :sortfield Sort by 'itemid', 'clock', or 'ns'
    # @option data [String] :sortorder Sort order 'ASC' or 'DESC'
    # @option data [Integer] :limit Maximum number of records to return
    # @option data [Boolean] :countOutput Return count instead of data
    # @raise [ApiError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Array<Hash>] Array of history objects with itemid, clock, value, ns
    # @return [Integer] Count if countOutput is true
    def get(data)
      log "[DEBUG] Call get with parameters: #{data.inspect}"

      params = {
        output: 'extend'
      }

      # History type (0-5), defaults to 3 (numeric unsigned)
      params[:history] = data[:history] if data[:history]

      # Filter parameters
      params[:itemids] = data[:itemids] if data[:itemids]
      params[:hostids] = data[:hostids] if data[:hostids]
      params[:time_from] = data[:time_from] if data[:time_from]
      params[:time_till] = data[:time_till] if data[:time_till]

      # Sorting and limiting
      params[:sortfield] = data[:sortfield] if data[:sortfield]
      params[:sortorder] = data[:sortorder] if data[:sortorder]
      params[:limit] = data[:limit] if data[:limit]

      # Count output
      params[:countOutput] = data[:countOutput] if data[:countOutput]

      @client.api_request(method: 'history.get', params: params)
    end

    # Get the latest value for an item
    #
    # @param itemid [Integer, String] The item ID to get history for
    # @param history_type [Integer] History value type (0-5, default: 3)
    # @raise [ApiError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Hash, nil] The latest history record or nil if no data
    def get_latest(itemid, history_type = NUMERIC_UNSIGNED)
      log "[DEBUG] Call get_latest with itemid: #{itemid}, history_type: #{history_type}"

      result = get(
        itemids: itemid,
        history: history_type,
        sortfield: 'clock',
        sortorder: 'DESC',
        limit: 1
      )

      result.first
    end

    # Get the latest value as a numeric type
    #
    # @param itemid [Integer, String] The item ID to get history for
    # @param history_type [Integer] History value type (0-5, default: 3)
    # @raise [ApiError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Float, Integer, nil] The latest value converted to numeric, or nil if no data
    def get_latest_value(itemid, history_type = NUMERIC_UNSIGNED)
      record = get_latest(itemid, history_type)
      return nil unless record

      case history_type
      when NUMERIC_FLOAT
        record['value'].to_f
      when NUMERIC_UNSIGNED
        record['value'].to_i
      else
        record['value']
      end
    end

    # Get history data within a time range
    #
    # @param itemid [Integer, String] The item ID to get history for
    # @param time_from [Integer] Start timestamp (Unix epoch)
    # @param time_till [Integer] End timestamp (Unix epoch)
    # @param history_type [Integer] History value type (0-5, default: 3)
    # @raise [ApiError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Array<Hash>] Array of history records
    def get_range(itemid, time_from, time_till, history_type = NUMERIC_UNSIGNED)
      log "[DEBUG] Call get_range with itemid: #{itemid}, time_from: #{time_from}, time_till: #{time_till}"

      get(
        itemids: itemid,
        history: history_type,
        time_from: time_from,
        time_till: time_till,
        sortfield: 'clock',
        sortorder: 'ASC'
      )
    end

    # Get the count of history records for an item
    #
    # @param itemid [Integer, String] The item ID to count history for
    # @param history_type [Integer] History value type (0-5, default: 3)
    # @param time_from [Integer, nil] Optional start timestamp
    # @param time_till [Integer, nil] Optional end timestamp
    # @raise [ApiError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Integer] Count of history records
    def count(itemid, history_type = NUMERIC_UNSIGNED, time_from = nil, time_till = nil)
      log "[DEBUG] Call count with itemid: #{itemid}"

      params = {
        itemids: itemid,
        history: history_type,
        countOutput: true
      }
      params[:time_from] = time_from if time_from
      params[:time_till] = time_till if time_till

      get(params).to_i
    end

    # History is read-only, create is not supported
    def create(_data)
      raise ApiError, 'History does not support create operations'
    end

    # History is read-only, update is not supported
    def update(_data, _force = false)
      raise ApiError, 'History does not support update operations'
    end

    # History is read-only, delete is not supported
    def delete(_data)
      raise ApiError, 'History does not support delete operations'
    end
  end
end
