require 'spec_helper'

RSpec.describe 'read and write' do
  subject { DruidDB::Client.new(config_options) }

  let(:config_options) { { zookeeper: 'zookeeper:2181' } }
  let(:datasource) { 'xwings' }

  let(:intervals) do
    Time.now.utc.iso8601 + '/' + Time.now.utc.advance(minutes: 10).iso8601
  end

  before do
    create_supervisor if subject.supervisor_tasks.exclude?(datasource)
    start_worker if subject.list_datasources.exclude?(datasource)
  end

  it 'writes and reads a point' do
    expect(execute_query).to be_empty
    subject.write_point(datasource, datapoint)
    sleep 30 # TODO: Do something more intelligent
    results = execute_query
    expect(results).not_to be_empty
    expect(results.size).to eq 1
    expect(results.first['result']['units']).to eq 1
  end
end

def create_supervisor
  subject.submit_supervisor_spec('spec/ingestion_specs/xwings_spec.json')
end

def datapoint
  {
    timestamp: Time.now.utc.iso8601,
    manufacturer: 'Incom',
    units: 1
  }
end

def execute_query
  subject.query(
    queryType: 'timeseries',
    dataSource: datasource,
    granularity: 'minute',
    intervals: intervals,
    aggregations: [{ type: 'longSum', name: 'units', fieldName: 'units' }]
  )
end

def start_worker
  subject.write_point(datasource, datapoint) # start worker
  sleep 60 # TODO: Do something more intelligent
end
