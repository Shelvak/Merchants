#monkeypatch
module PaperTrail
  class Version < ActiveRecord::Base
    include PaperTrail::VersionConcern
    attr_accessible :item_type, :item_id, :event, :whodunnit, :object, :object_changes, :created_at, :correlation_id
  end
end
