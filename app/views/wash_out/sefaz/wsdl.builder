xml.instruct!
xml.wsdl :definitions, 'xmlns:s' => 'http://www.w3.org/2001/XMLSchema',
                'xmlns:soap12' => "http://schemas.xmlsoap.org/wsdl/soap12/",
                'xmlns:http' => "http://schemas.xmlsoap.org/wsdl/http/",
                'xmlns:mime' => "http://schemas.xmlsoap.org/wsdl/mime/",
                'xmlns:tns' => @namespace,
                'xmlns:soap' => 'http://schemas.xmlsoap.org/wsdl/soap/',
                'xmlns:tm' => "http://microsoft.com/wsdl/mime/textMatching/",
                'xmlns:soapenc' => 'http://schemas.xmlsoap.org/soap/encoding/',
                'xmlns:wsdl' => 'http://schemas.xmlsoap.org/wsdl/',
                'targetNamespace' => @namespace do
  xml.wsdl :types do
    xml.tag! "s:schema", :elementFormDefault => "qualified", :targetNamespace => @namespace do
      defined = []
      # @map.each do |operation, formats|
      #   (formats[:in] + formats[:out]).each do |p|
      #     wsdl_type xml, p, defined
      #   end
      # end
      xml.tag! "s:element", :name => "nfeDistDFeInteresse" do
        xml.tag! "s:complexType" do
          xml.tag! "s:sequence" do
            xml.tag! "s:element",  :minOccurs => "0",  :maxOccurs => "1",  :name => "nfeDadosMsg" do
              xml.tag! "s:complexType", :mixed => "true" do
                xml.tag! "s:sequence" do
                  xml.tag! "s:any"
                end
              end
            end
          end
        end
      end
      xml.tag! "s:element", :name => "nfeDistDFeInteresseResponse" do
        xml.tag! "s:complexType" do
          xml.tag! "s:sequence" do
            xml.tag! "s:element",  :minOccurs => "0",  :maxOccurs => "1",  :name => "nfeDistDFeInteresseResult" do
              xml.tag! "s:complexType", :mixed => "true" do
                xml.tag! "s:sequence" do
                  xml.tag! "s:any"
                end
              end
            end
          end
        end
      end
    end
  end

  @map.each do |operation, formats|
    xml.wsdl :message, :name => "#{formats[:in_tag]}" do
      formats[:in].each do |p|
        xml.wsdl :part, wsdl_occurence(p, true, :name => "parameters", :element => formats[:in_object_name])
      end
    end
    xml.wsdl :message, :name => "#{formats[:out_tag]}" do
      formats[:out].each do |p|
        xml.wsdl :part, wsdl_occurence(p, true, :name => "parameters", :element => formats[:out_object_name])
      end
    end
  end

  xml.wsdl :portType, :name => "#{@name}" do
    @map.each do |operation, formats|
      xml.wsdl :operation, :name => operation do
        xml.wsdl :input, :message => "tns:#{formats[:in_tag]}"
        xml.wsdl :output, :message => "tns:#{formats[:out_tag]}"
      end
    end
  end

  xml.wsdl :binding, :name => "#{@name}", :type => "tns:#{@name}" do
    xml.tag! "soap:binding", :transport => 'http://schemas.xmlsoap.org/soap/http'
    @map.each_key do |operation|
      xml.wsdl :operation, :name => operation do
        xml.tag! "soap:operation", :soapAction => "#{@namespace}/#{operation}", :style => :document
        xml.wsdl :input do
          xml.tag! "soap:body",
                    :use => "literal"
        end
        xml.wsdl :output do
          xml.tag! "soap:body",
                    :use => "literal"
        end
      end
    end
  end

  xml.wsdl :binding, :name => "#{@name}12", :type => "tns:#{@name}" do
    xml.tag! "soap12:binding", :transport => 'http://schemas.xmlsoap.org/soap/http'
    @map.each_key do |operation|
      xml.wsdl :operation, :name => operation do
        xml.tag! "soap12:operation", :soapAction => "#{@namespace}/#{operation}", :style => :document
        xml.wsdl :input do
          xml.tag! "soap12:body",
                    :use => "literal"
        end
        xml.wsdl :output do
          xml.tag! "soap12:body",
                    :use => "literal"
        end
      end
    end
  end


  service_url = "#{Vportal::Setting.get_setting(:general)[:protocol].downcase}://#{Vportal::Setting.get_setting(:general)[:base_url]}/nf/ws_api/sefaz/nfe_distribuicao_dfes/action"
  xml.wsdl :service, :name => @service_name do
    xml.wsdl :port, :name => "#{@name}", :binding => "tns:#{@name}" do
      xml.tag! "soap:address", :location => service_url #WashOut::Router.url(request, @controller_path)
    end
    xml.wsdl :port, :name => "#{@name}12", :binding => "tns:#{@name}12" do
      xml.tag! "soap12:address", :location => service_url #WashOut::Router.url(request, @controller_path)
    end
  end
end
