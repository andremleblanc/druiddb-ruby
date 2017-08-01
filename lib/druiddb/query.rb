module DruidDB
  class Query
    attr_reader :aggregations,
                :broker,
                :dimensions,
                :end_interval,
                :fill_value,
                :granularity,
                :query_opts,
                :query_type,
                :range,
                :result_key,
                :start_interval

    def initialize(opts)
      @aggregations = opts[:aggregations].map{|agg| agg[:name]}
      @broker = opts[:broker]
      @dimensions = opts[:dimensions]
      @fill_value = opts[:fill_value]
      @granularity = opts[:granularity]
      @range = parse_range(opts[:intervals])
      @query_type = opts[:queryType]
      @end_interval = calculate_end_interval
      @start_interval = calculate_start_interval
      @query_opts = opts_for_query(opts)
    end

    def execute
      result = broker.query(query_opts)
      fill_query_results(result)
    end

    private

    # TODO: Can this be made smarter? Prefer to avoid case statements.
    # Cases found here: http://druid.io/docs/latest/querying/granularities.html
    def advance_interval(time)
      case granularity
      when 'second'
        time.advance(seconds: 1)
      when 'minute'
        time.advance(minutes: 1)
      when 'fifteen_minute'
        time.advance(minutes: 15)
      when 'thirty_minute'
        time.advance(minutes: 30)
      when 'hour'
        time.advance(hours: 1)
      when 'day'
        time.advance(days: 1)
      when 'week'
        time.advance(weeks: 1)
      when 'month'
        time.advance(months: 1)
      when 'quarter'
        time.advance(months: 3)
      when 'year'
        time.advance(years: 1)
      else
        raise Druid::QueryError, 'Unsupported granularity'
      end
    end

    def calculate_end_interval
      iso8601_duration_end_interval(range)
    end

    def calculate_start_interval
      time = iso8601_duration_start_interval(range)
      start_of_interval(time)
    end

    def fill_empty_intervals(points, opts = {})
      interval = start_interval
      result = []

      while interval <= end_interval do
        # TODO:
        # This will search the points every time, could be more performant if
        # we track the 'current point' in the points and only compare the
        # current point's timestamp
        point = find_or_create_point(interval, points)
        aggregations.each do |aggregation|
          point[result_key][aggregation] = fill_value if point[result_key][aggregation].blank?
          point[result_key].merge!(opts)
        end
        result << point
        interval = advance_interval(interval)
      end

      result
    end

    # NOTE:
    # This responsibility really lies in Druid, but until the feature works
    # reliably in Druid, this is serves the purpose.
    # https://github.com/druid-io/druid/issues/2106
    def fill_query_results(query_result)
      return query_result unless query_result.present? && fill_value.present?
      parse_result_key(query_result.first)

      #TODO: handle multi-dimensional group by
      if group_by?
        result = []
        dimension_key = dimensions.first
        groups = query_result.group_by{ |point| point[result_key][dimension_key] }
        groups.each do |dimension_value, dimension_points|
          result += fill_empty_intervals(dimension_points, { dimension_key => dimension_value })
        end
        result
      else
        fill_empty_intervals(query_result)
      end
    end

    def find_or_create_point(interval, points)
      point = points.find{ |point| point['timestamp'].to_s.to_time == interval.to_time }
      point.present? ? point : { 'timestamp' => interval.iso8601(3), result_key => {} }
    end

    def group_by?
      query_type == 'groupBy'
    end

    def iso8601_duration_start_interval(duration)
      duration.split('/').first.to_time.utc
    end

    def iso8601_duration_end_interval(duration)
      duration.split('/').last.to_time.utc
    end

    def opts_for_query(opts)
      opts.except(:fill_value, :broker)
    end

    def parse_range(range)
      range.is_a?(Array) ? range.first : range
    end

    def parse_result_key(point)
      @result_key = point['event'].present? ? 'event' : 'result'
    end

    # TODO: Can this be made smarter? Prefer to avoid case statements.
    # Cases found here: http://druid.io/docs/latest/querying/granularities.html
    def start_of_interval(time)
      case granularity
      when 'second'
        time.change(usec: 0)
      when 'minute'
        time.beginning_of_minute
      when 'fifteen_minute'
        first_fifteen = [45, 30, 15, 0].detect{ |m| m <= time.min }
        time.change(min: first_fifteen)
      when 'thirty_minute'
        first_thirty = [30, 0].detect{ |m| m <= time.min }
        time.change(min: first_thirty)
      when 'hour'
        time.beginning_of_hour
      when 'day'
        time.beginning_of_day
      when 'week'
        time.beginning_of_week
      when 'month'
        time.beginning_of_month
      when 'quarter'
        time.beginning_of_quarter
      when 'year'
        time.beginning_of_year
      else
        time
      end
    end

    class << self
      def create(opts)
        new(opts).execute
      end
    end
  end
end
