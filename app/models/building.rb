class Building < ActiveRecord::Base

  include FieldAvgs
  define_field_avgs

  CONSTRUCTION = {1=>"Pre-War",2 => "Post-War", 3=>"New Construction"}
  DEFAULT_SORT = "score desc, reviews_count desc"
  belongs_to :neighborhood
  has_many :reviews
  has_many :reviewers,:through => :reviews, :source => :user
  validates :neighborhood, :presence => true
  validates :address, :presence => true
  validates :avg_rent, :numericality => true, allow_blank: true
  validates_format_of :zipcode,
    :with => %r{\d{5}(-\d{4})?},
    :message => "should be 12345 or 12345-1234", :if => "zipcode.present?"

  before_create :normalize
  has_many :building_images
  has_one :default_building_image, :class_name => "BuildingImage", :conditions => proc{["building_images.id = ?", default_image_id || building_images.first ]}
  paginates_per 10

   accepts_nested_attributes_for :building_images


  def self.highest_rated
    self.all.max_by(&:score)
  end

  def self.locate(params = {})

    building= where(:zipcode => params[:zipcode].strip) if params[:zipcode].present?
    building= where(:address => params[:address].strip) if params[:address].present?
    building= where(:neighborhood_id => params[:neighborhood].strip) if params[:neighborhood].present?
    building
  end

  def self.find_by_reviewer_average_rent(op, amt, type=nil)
    Building.all.select { |b| b.reviewer_avg_rent(type).send(op.to_sym, amt) }
  end

  def avg_rent= value
    return if value.blank?
    write_attribute("avg_rent", value)
    update_column(:reviewer_avg_rent, value)
  end

  def self.find_by_avg_rent(op, amt )
    Building.where("reviewer_avg_rent #{op} ?", amt)
  end

  def self.super_search(params)
    self.locate(params).search(params[:search])
  end

  def self.search(search)
    where(' upper(address) like ?', "%#{search.upcase}%")
  end

  def name
    address
  end

  def rent_range
    admin_rent_range || reviewer_rent_range
  end

  def reviewer_average_age
    if reviewers.count > 0
      cnt = reviewers.uniq.count
      (reviewers.uniq.map(&:age).inject{|sum,a|sum+a}.to_f/cnt).round
    else
      0
    end
  end

  def average_years_lived
    if reviews.count > 0
      cnt = reviews.uniq.count
      (reviews.uniq.map(&:years_lived).inject{|sum,a|sum+a}.to_f/cnt).round
    else
      0
    end
  end

  def apt_types
    types = {}
    reviews.each do |r|
      if !r.apt_size.nil?
        key = r.apt_size ==0 ? "Studio" : "#{r.apt_size} BR"
        types[key] = types[key].present? ? types[key]+1 : 1
      end
    end
    types
  end

  def flags_thrown
    flags = {}
    reviews.each do |r|
      key = Review::FLAGS[r.assessment]
      flags[key] = flags[key].present? ? flags[key]+1 : 1
    end
    flags
  end


  def construction
    CONSTRUCTION[construction_type]
  end

  def has_doorman
    doorman ? "Yes" : "No"
  end

  def has_elevator
    elevator ? "Yes" : "No"
  end

  def has_super
    self.super ? "Yes" : "No"
  end

  def is_coop
    self.coop ? "Yes" : "No"
  end


  def reset_reviewer_avg_rent
    self.update_column(:reviewer_avg_rent,  array_avg(reviews.rent_included.map(&:monthly_fee)))
  end


  private

  def normalize
    self.address = self.address.downcase.strip
    self.zipcode = self.zipcode.strip
  end

  def array_avg amts
    (amts.inject(0.0) {|sum, fee| sum + fee}/amts.size).round
  rescue
    0
  end

  def rents type=nil
    type.nil? ? reviews.rent_included : reviews.rent_included.send(type.to_s) 
  end

  def reviewer_rent_range
    return "NA" if reviews.rent_included == []
    min, max =  reviews.rent_included.map(&:monthly_fee).minmax
    min == max ? "$#{min.to_i}" : "$#{min.to_i} - $#{max.to_i}"
  end

  def admin_rent_range
    if rent_min && rent_max
      "$#{rent_min} - $#{rent_max}"
    else
      nil
    end
  end

end
