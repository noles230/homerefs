require 'field_avgs'
class Building < ActiveRecord::Base
  include FieldAvgs
  define_field_avgs

  CONSTRUCTION = {1=>"Pre-War",2 => "Post-War", 3=>"New Construction"}
  belongs_to :neighborhood
  has_many :reviews
  validates :neighborhood, :presence => true
  validates :address, :presence => true
  validates_format_of :zipcode,
    :with => %r{\d{5}(-\d{4})?},
    :message => "should be 12345 or 12345-1234", :if => "zipcode.present?"

  before_create :normalize
  has_many :building_images

  def self.search(params = {})

    building= where(:zipcode => params[:zipcode].strip) if params[:zipcode].present?
    building= where(:address => params[:address].strip) if params[:address].present?
    building= where(:neighborhood_id => params[:neighborhood].strip) if params[:neighborhood].present?
    building
  end


  def normalize
    self.address = self.address.downcase.strip
    self.zipcode = self.zipcode.strip
  end

  def construction
    CONSTRUCTION[construction_type]
  end

end
