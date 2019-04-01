class ArticlesController < ApplicationController
  before_action :check_user, only: [:edit, :update, :destroy]
  before_action :check_login, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_ranking_data, only: [:index, :show]
  
  def set_ranking_data
    ids = REDIS.zrevrangebyscore "articles/daily/#{Date.today.to_s}", "+inf", 0, limit: [0, 3]
    @ranking_articles = Article.where(id: ids)
    @scores =[]
    ids.each do |id|
      float = REDIS.zscore "articles/daily/#{Date.today.to_s}", id
      @scores << float.to_i
    end
  end

  
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
    REDIS.zincrby "articles/daily/#{Date.today.to_s}", 1, "#{@article.id}"
  end
  
  def new
    @article = Article.new
  end

  def create
    @article = current_user.articles.build(article_params)
    if @article.save
      redirect_to @article
    else
      render "new"
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])
    if @article.update(article_params)
      redirect_to @article
    else
      render "edit"
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy
    redirect_to root_url
  end
  
  private
  
  def article_params
    params.require(:article).permit(:title, :content)
  end
  
  def check_user
    @article = Article.find(params[:id])
    if @article.user != current_user
      flash[:alert] = "Not yours"
      redirect_to root_url
    end
  end
end
