ActiveAdmin.register BuildingImage do
  #NOTE active admin will use the name method the model to populate the filter dropdown. If name doesn't exist the collection must be specified
  #Explicitly using collection_for_select semantics
  filter :building, :collection => proc {Building.all.inject({}){|bldgs, b| bldgs[b.address]=b.id; bldgs }}
  index do

    column :building do |b|
      b.building.address
    end

    column "Image" do |b|
      image_tag(b.image.url(:small))
    end

    default_actions
  end

  show  do |building_image|
    attributes_table do
      row :buildiing do
        building_image.building.address
      end
      row :image do
        image_tag(building_image.image.url)
      end
      row :user
      row :id
    end
  end

  form do |f|
    f.inputs "Main" do
      f.input :building, :as => :select, :collection => Building.all.map{|b|[b.address, b.id]}
      f.input :image, :as => :file, :label => "Image"
      f.buttons :commit
    end
  end

end
