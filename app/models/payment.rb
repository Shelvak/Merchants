class Payment < ActiveRecord::Base
  has_paper_trail

  belongs_to :client

  scope :between, -> (_start, _end) { where(created_at: _start.._end) }
end
