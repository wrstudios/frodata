shared_examples 'a geographic property' do |type_name|
  let(:subject) { klass.new(property_name, coordinates) }

  describe '#type' do
    it { expect(subject.type).to eq(type_name) }
  end

  describe '#srid' do
    it { expect(subject.srid).to eq(srid) }
  end

  describe '#value' do
    it { expect(subject.value).to eq(coordinates) }
  end

  describe '#value=' do
    it { expect { subject.value = 'invalid' }.to raise_error(ArgumentError) }

    it {
      subject.value = new_value_as_text
      expect(subject.value).to eq(new_value)
      expect(subject.srid).to eq(0)
    }

    it {
      subject.value = new_value
      expect(subject.value).to eq(new_value)
      expect(subject.srid).to eq(4326)
    }
  end

  describe '#url_value' do
    it { expect(subject.url_value).to eq(property_as_text) }
  end

  describe '#json_value' do
    it 'renders property value as a hash' do
      expect(subject.json_value).to eq(property_as_json)
    end
  end

  describe '#to_xml' do
    let(:builder) do
      Nokogiri::XML::Builder.new do |xml|
        xml.entry(FrOData::Entity::XML_NAMESPACES) do
          subject.to_xml(xml)
        end
      end
    end
    let(:xml) { Nokogiri::XML(builder.to_xml) }
    let(:property_xml) { xml.root.element_children.first.to_s }

    it { expect(property_xml).to be_equivalent_to(property_as_xml) }
  end

  describe '.from_xml' do
    let(:subject) { klass.from_xml(property_xml) }
    let(:xml_doc) do
      Nokogiri::XML::Builder.new do |xml|
        xml.entry(FrOData::Entity::XML_NAMESPACES)
      end.to_xml
    end
    let(:property_xml) do
      document = Nokogiri::XML(xml_doc)
      document.root << property_as_xml
      document.remove_namespaces!.root.element_children.first
    end

    it { expect(subject.value).to eq(coordinates) }
    it { expect(subject.srid).to eq(srid) }
  end
end
