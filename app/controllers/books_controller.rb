class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  rescue_from ActiveRecord::RecordNotFound do |e|
    redirect_to books_path
  end

  def show
    @book = Book.find(params[:id])
    @book_comment = BookComment.new

    view_count = ViewCount.find_by(user_id: current_user.id, book_id: @book.id)
    unless view_count
      current_user.view_counts.create(book_id: @book.id)
    end
  end

  def index
    @user = current_user
    to = Time.current.at_end_of_day
    from = (to - 6.day).at_beginning_of_day
    @books = Book.includes(:faved_users).sort_by {|book|
      book.faved_users.includes(:favorites).where(created_at: from...to).size
    }.reverse
  end

  def edit
    @book = Book.find(params[:id])
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    if @book.save
      redirect_to book_path(@book), notice: "You have created book successfully."
    else
      @user = current_user
      @books = Book.all
      render :index
    end
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to book_path(@book), notice: "You have updated book successfully."
    else
      render :edit
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path
  end

  private

  def book_params
    params.require(:book).permit(:title, :body)
  end

  def ensure_correct_user
    user = Book.find(params[:id]).user
    unless user == current_user
      redirect_to books_path
    end
  end
end
