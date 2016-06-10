# Serialise template objects
module TemplateRepresenter
  include BaseRepresenter

  property :id
  property :created_at
  property :updated_at
  property :name
  property :os_type
  property :os_distro
  property :onapp_os_distro
  property :min_memory
  property :min_disk
  property :hourly_cost
end
