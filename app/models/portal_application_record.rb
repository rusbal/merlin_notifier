class PortalApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :portal, reading: :portal }
end
