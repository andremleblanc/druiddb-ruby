require 'spec_helper'

describe Druid::Writer::Base do
  subject { Druid::Writer::Base.new(config) }
  let(:config) { Druid::Configuration.new }
  let(:datasource_a) { 'writer_base_a' }
  let(:datapoint_1) { { dimensions: dimensions_1, metrics: metrics_1 } }
  let(:datapoint_2) { { dimensions: dimensions_1, metrics: metrics_2 } }
  let(:datapoint_obj_1) { Druid::Writer::Tranquilizer::Datapoint.new(datapoint_1) }
  let(:datapoint_obj_2) { Druid::Writer::Tranquilizer::Datapoint.new(datapoint_2) }
  let(:dimensions_1) { { manufacturer: 'ACME', owner: 'Wile E. Coyote' } }
  let(:metrics_1) { { anvils: 1 } }
  let(:metrics_2) { { anvils: 1, dynamite: 10 } }
  let(:time) { Time.now.utc.beginning_of_hour }
  let(:tranquilizer_1) { Druid::Writer::Tranquilizer::Base.new(tranquilizer_config_1) }
  let(:tranquilizer_2) { Druid::Writer::Tranquilizer::Base.new(tranquilizer_config_2) }
  let(:tranquilizer_config_1) { { config: config, datasource: datasource_a, datapoint: datapoint_obj_1 } }
  let(:tranquilizer_config_2) { { config: config, datasource: datasource_a, datapoint: datapoint_obj_2 } }
  let(:n) { 2 }
  let(:next_interval) { Time.now.utc.advance(hours: 1) }

  describe '#remove_tranquilizer_for_datasource' do
    let(:tranquilizer) { double('tranquilizer') }

    context 'when there is a tranquilizer for the datasource' do
      it 'calls remove_tranquilizer with the tranquilizer' do
        expect(subject).to receive(:tranquilizer_for_datasource).with(datasource_a).and_return(tranquilizer)
        expect(subject).to receive(:remove_tranquilizer).with(tranquilizer)
        subject.remove_tranquilizer_for_datasource(datasource_a)
      end
    end

    context 'when there is not a tranquilizer for the datasource' do
      it 'does not call remove_tranquilizer' do
        expect(subject).to receive(:tranquilizer_for_datasource).with(datasource_a)
        expect(subject).not_to receive(:remove_tranquilizer)
        subject.remove_tranquilizer_for_datasource(datasource_a)
      end
    end
  end

  describe '#write_point' do
    context 'writing points to the same datasource' do
      context 'with no schema change' do
        it 'builds a tranquilzer the first time and then reuse it' do
          expect(Druid::Writer::Tranquilizer::Base).to receive(:new).once.and_return(tranquilizer_1)
          expect(tranquilizer_1).to receive(:send).exactly(n).times
          n.times { subject.write_point(datasource_a, datapoint_1) }
          expect(subject.tranquilizers.size).to eq 1
        end
      end

      context 'with schema change' do
        it 'builds a tranquilzer the first time and reuse it until the schema changes' do
          expect(Druid::Writer::Tranquilizer::Base).to receive(:new).twice.and_return(tranquilizer_1, tranquilizer_2)
          expect(tranquilizer_1).to receive(:send).exactly(n).times
          expect(tranquilizer_2).to receive(:send).exactly(n).times

          n.times { subject.write_point(datasource_a, datapoint_1) }
          n.times { subject.write_point(datasource_a, datapoint_2) }
          expect(subject.tranquilizers.size).to eq 1
        end
      end
    end

    context 'writing points to multiple datasources' do
      let(:datasource_b) { 'writer_base_b' }

      context 'with no schema change' do
        let(:tranquilizer_config_2) { { config: config, datasource: datasource_b, datapoint: datapoint_obj_1 } }

        it 'builds a tranquilizer for each datasource and reuse them' do
          expect(Druid::Writer::Tranquilizer::Base).to receive(:new).twice.and_return(tranquilizer_1, tranquilizer_2)
          expect(tranquilizer_1).to receive(:send).exactly(n).times
          expect(tranquilizer_2).to receive(:send).exactly(n).times

          n.times { subject.write_point(datasource_a, datapoint_1) }
          n.times { subject.write_point(datasource_b, datapoint_1) }
          expect(subject.tranquilizers.size).to eq 2
        end
      end

      context 'with schema change' do
        let(:tranquilizer_3) { Druid::Writer::Tranquilizer::Base.new(tranquilizer_config_3) }
        let(:tranquilizer_config_3) { { config: config, datasource: datasource_b, datapoint: datapoint_obj_1 } }

        let(:tranquilizer_4) { Druid::Writer::Tranquilizer::Base.new(tranquilizer_config_4) }
        let(:tranquilizer_config_4) { { config: config, datasource: datasource_b, datapoint: datapoint_obj_2 } }

        it 'builds a tranquilizer for each datasource and reuse them and rebuild when the schema changes' do
          expect(Druid::Writer::Tranquilizer::Base).to receive(:new).exactly(4).times.and_return(tranquilizer_1, tranquilizer_2, tranquilizer_3, tranquilizer_4)
          expect(tranquilizer_1).to receive(:send).exactly(n).times
          expect(tranquilizer_2).to receive(:send).exactly(n).times
          expect(tranquilizer_3).to receive(:send).exactly(n).times
          expect(tranquilizer_4).to receive(:send).exactly(n).times

          n.times { subject.write_point(datasource_a, datapoint_1) }
          n.times { subject.write_point(datasource_a, datapoint_2) }
          n.times { subject.write_point(datasource_b, datapoint_1) }
          n.times { subject.write_point(datasource_b, datapoint_2) }
          expect(subject.tranquilizers.size).to eq 2
        end
      end
    end
  end
end
