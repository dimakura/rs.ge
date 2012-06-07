# -*- encoding : utf-8 -*-

# Class with errors and warnings.
class RS::Validable
  attr_accessor :errors, :warnings

  # Add error to the specified field.
  def add_error(fld, msg)
    self.errors = {} unless self.errors
    self.errors[fld.to_sym] = msg
  end

  # Add warning to the specified field.
  def add_warning
    self.warnings = {} unless self.warnings
    self.warnings[fld.to_sym] = msg
  end
end
