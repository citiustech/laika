class Support < ActiveRecord::Base
  strip_attributes!

  belongs_to :patient_data
  belongs_to :contact_type
  belongs_to :relationship
  include PersonLike
  include MatchHelper
  
  def validate_c32(xml)
      errors = []
      support = REXML::XPath.first(xml, "/cda:ClinicalDocument/cda:participant/cda:associatedEntity[cda:associatedPerson/cda:name/text() = $name ] | /cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:guardian[cda:guardianPerson/cda:name/text() = $name]",
          {'cda' => 'urn:hl7-org:v3'},{"name"=>name})
      if support
          if self.address
             add =  REXML::XPath.first(support,"cda:addr",{'cda' => 'urn:hl7-org:v3'})
             if add
                 errors.concat   self.address.validate_c32(add)  
             else
                                               
                 errors <<  ContentError.new(:section=>"Support", 
                                     :subsection=>"address",
                                     :field_name=>"",
                                     :error_message=>"Address not found in the support section #{support.xpath}",
                                     :location=>support.xpath)          
                                          
             
             end
          end
      
          if self.telecom
              errors.concat self.telecom.validate_c32(support)
          end
     # classcode
      error = XmlHelper.match_value(support,"@classCode",(contact_type) ? contact_type.code : nil)
      if error
          errors << ContentError.new(:section=>"Support", 
                                        :subsection=>"#{support.name}",
                                        :field_name=>"contacttype",
                                        :error_message=>error,
                                        :location=>support.xpath)      
                                      
      end
      
      
      error = XmlHelper.match_value(support,"cda:code[@codeSystem='2.16.840.1.113883.5.111']/@code",(relationship) ? relationship.code : nil)
      
      if error
          errors <<  ContentError.new(:section=>"Support", 
                    :subsection=>"#{support.name}",
                    :field_name=>"relationship",
                    :error_message=>error,
                    :location=>support.xpath)                                  
                              
      end
    
      
      else
         # add the error for no support object being there 
          errors <<  ContentError.new(:section=>"Support", 
                                        :subsection=>"",
                                        :field_name=>"",
                                        :error_message=>"Support element does not exist")          
      end
      
      errors
  end
  
  
  def section
      "Support"
  end
  
end
