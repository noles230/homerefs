class AddNeighborhoodToBuilding < ActiveRecord::Migration
  def change
    add_column :buildings, :neighborhood, :string
  end
end
