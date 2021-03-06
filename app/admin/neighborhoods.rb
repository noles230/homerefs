ActiveAdmin.register Neighborhood do
  index do
    column :name
    column "No buildings" do |n|
      n.buildings.count
    end
    column "No Reviews"  do |n|
      n.num_reviews
    end
    column :location

    default_actions
  end

  show :title => :name do
    attributes_table do
      row "Buildings Count" do
        neighborhood.buildings.count
      end
      row "Highest Rated Building" do
        neighborhood.highest_rated_address
      end
      row :location
    end
  end


end
