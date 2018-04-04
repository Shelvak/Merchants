class AddCorrelationIdToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :correlation_id, :string, default: nil, limit: 50, index: true
  end
end
