# Par AR del CHECK json_valid(col) AND json_type(col) = 'array'.
class JsonArrayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :not_an_array, message: "debe ser una lista") unless value.is_a?(Array)
  end
end
