module Ransack
  class Search
    alias_method :ransack_search_build, :build
    alias_method :ransack_method_missing, :method_missing
    
    def method_missing(method_id, *args)
      method_name = method_id.to_s
      writer = method_name.sub!(/\=$/, '')
      # Decode abbreviation (if it is indeed an abbreviation) so Ransack is happy
      decoded_param = self.context.decode_parameter(method_name)
      decoded_str = writer ? "#{decoded_param}=" : decoded_param
      ransack_method_missing(decoded_str.to_sym, *args)
    end
    
    def build(params)
      # Loop through each of the params and test if any contain abbreviations. If so, convert them to the normal Ransack language
      new_params = {}
      collapse_multiparameter_attributes!(params.with_indifferent_access).each do |key, value|
        decoded_param = self.context.decode_parameter(key)
        new_params[decoded_param] = value
      end

      ransack_search_build(new_params)
    end
  end
end