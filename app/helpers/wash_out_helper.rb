module WashOutHelper

  def wsdl_data_options(param)
    case controller.soap_config.wsdl_style
    when 'rpc'
      if param.map.present? || !param.value.nil?
        { :"xsi:type" => param.namespaced_type }
      else
        { :"xsi:nil" => true }
      end
    when 'document'
      {}
    else
      {}
    end
  end

  def wsdl_data_attrs(param)
    param.map.reduce({}) do |memo, p|
      if p.respond_to?(:attribute?) && p.attribute?
        memo.merge p.attr_name => p.value
      else
        memo
      end
    end
  end

  def wsdl_data(xml, params)
    params.each do |param|
      next if param.attribute?

      tag_name = param.name
      param_options = {}

      param_options.merge! wsdl_data_attrs(param)
      if param.struct?
        if param.multiplied
          param.map.each_with_index do |p,idx|
            attrs = wsdl_data_attrs p
            if p.is_a?(Array) || p.map.size > attrs.size
              blk = proc { wsdl_data(xml, p.map) }
            end

            attrs.reject! { |_, v| v.nil? }
            if vv = param.map.flatten.select{|p| p.name == "valuedata"}[idx]
              xml.tag! tag_name, vv.value, param_options.merge(attrs)
            else
              xml.tag! tag_name, param_options.merge(attrs), &blk
            end
          end
        else
          if vv = param.map.detect{|p| p.name == "valuedata"}
            xml.tag! tag_name, vv.value, param_options
          else
            if param.map.blank?
            else
              xml.tag! tag_name, param_options do
                wsdl_data(xml, param.map)
              end
            end

          end

        end
      else
        if param.multiplied
          param.value = [] unless param.value.is_a?(Array)
          param.value.each do |v|
            xml.tag! tag_name, v, param_options
          end
        else
          xml.tag! tag_name, param.value, param_options
        end
      end


    end
  end

  def wsdl_type(xml, param, defined=[])
    more = []

    prefix = "xsd:"

    if custom_wsdl_style?(param)
      prefix = ""
    end

    if param.struct?
      if !defined.include?(param.basic_type)
        xml.tag! "#{prefix}complexType", :name => param.basic_type do
          attrs, elems = [], []
          param.map.each do |value|
            more << value if value.struct?
            if value.attribute?
              attrs << value
            else
              elems << value
            end
          end

          if elems.any?
            xml.tag! "#{prefix}sequence" do
              elems.each do |value|
                xml.tag! "#{prefix}element", wsdl_occurence(value, false, :name => value.name, :type => value.namespaced_type)
              end
            end
          end

          attrs.each do |value|
            xml.tag! "#{prefix}attribute", wsdl_occurence(value, false, :name => value.attr_name, :type => value.namespaced_type)
          end
        end

        defined << param.basic_type
      elsif !param.classified?
        raise RuntimeError, "Duplicate use of `#{param.basic_type}` type name. Consider using classified types."
      end
    end

    more.each do |p|
      wsdl_type xml, p, defined
    end
  end

  def wsdl_occurence(param, inject, extend_with = {})
    return extend_with if custom_wsdl_style?(param)

    data = {"#{'xsi:' if inject}nillable" => 'true'}
    if param.multiplied
      data["#{'xsi:' if inject}minOccurs"] = 0
      data["#{'xsi:' if inject}maxOccurs"] = 'unbounded'
    end
    extend_with.merge(data)
  end

  def custom_wsdl_style?(param)
    !param.soap_config.config[:wsdl_style].in?(['rpc', 'document'])
  end

end
