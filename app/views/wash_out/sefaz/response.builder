xml.instruct! :xml, :version => "1.0", :encoding => "utf-8"
xml.tag! "soap:Envelope", "xmlns:soap" => 'http://www.w3.org/2003/05/soap-envelope',
                          "xmlns:xsi" => 'http://www.w3.org/2001/XMLSchema-instance',
                          "xmlns:xsd" => 'http://www.w3.org/2001/XMLSchema' do
  if !header.nil?
    xml.tag! "soap:Header" do
      xml.tag! "tns:#{@action_spec[:response_tag]}" do
        wsdl_data xml, header
      end
    end
  end
  xml.tag! "soap:Body" do
    xml.tag! "#{@action_spec[:response_tag]}", "xmlns" => @namespace do
      wsdl_data xml, result
    end
  end
end
