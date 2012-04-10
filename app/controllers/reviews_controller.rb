class ReviewsController < ApplicationController

  def home

  end

  def index
    @reviews = Review.all
  end

  def show
    @review = Review.find(params[:id])
  end

  def new
    @review = Review.new
    @building = Building.find(params[:bldg])
  end

  def edit
    @review = Review.find(params[:id])
  end

  def create
    @review = Review.new(params[:review])


    respond_to do |format|
      if @review.save
        format.html {redirect_to @review, notice: 'Review was successfully created.'}
        format.json { render :json => @review}
      else
        render action: "new"
      end
    end
  end

  def update
    @review = Review.find(params[:id])

    respond_to do |format|
      if @review.update_attributes(params[:review])
        format.html {redirect_to @review, notice: 'Review was successfully updated.'}
        format.json { render :json => @review}
      else
        format.html {render action: "edit"}
      end
    end
  end

  def destroy
    @review = Review.find(params[:id])
    @review.destroy

    redirect_to reviews_url
  end
end
