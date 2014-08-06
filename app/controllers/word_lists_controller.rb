class WordListsController < ApplicationController
  before_action :set_word_list, only: [:show, :edit, :update, :destroy]

  # GET /word_lists
  # GET /word_lists.json
  def index
    @word_lists = WordList.all
  end

  # GET /word_lists/1
  # GET /word_lists/1.json
  def show
  end

  # GET /word_lists/new
  def new
    @word_list = WordList.new
  end

  # GET /word_lists/1/edit
  def edit
  end

  # POST /word_lists
  # POST /word_lists.json
  def create
    @word_list = WordList.new(word_list_params)

    respond_to do |format|
      if @word_list.save
        format.html { redirect_to @word_list, notice: 'Word list was successfully created.' }
        format.json { render :show, status: :created, location: @word_list }
      else
        format.html { render :new }
        format.json { render json: @word_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /word_lists/1
  # PATCH/PUT /word_lists/1.json
  def update
    respond_to do |format|
      if @word_list.update(word_list_params)
        format.html { redirect_to @word_list, notice: 'Word list was successfully updated.' }
        format.json { render :show, status: :ok, location: @word_list }
      else
        format.html { render :edit }
        format.json { render json: @word_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /word_lists/1
  # DELETE /word_lists/1.json
  def destroy
    @word_list.destroy
    respond_to do |format|
      format.html { redirect_to word_lists_url, notice: 'Word list was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_word_list
      @word_list = WordList.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def word_list_params
      params.require(:word_list).permit(:title, :author, :a_lot_of_words, words_attributes: [:id, :front, :back])
    end
end
