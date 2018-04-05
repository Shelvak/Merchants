class Payment < ActiveRecord::Base
  belongs_to :client

  scope :between, -> (_start, _end) { where(created_at: _start.._end) }
end
