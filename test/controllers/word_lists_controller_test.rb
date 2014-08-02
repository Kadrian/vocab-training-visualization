require 'test_helper'

class WordListsControllerTest < ActionController::TestCase
  setup do
    @word_list = word_lists(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:word_lists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create word_list" do
    assert_difference('WordList.count') do
      post :create, word_list: { author: @word_list.author, title: @word_list.title }
    end

    assert_redirected_to word_list_path(assigns(:word_list))
  end

  test "should show word_list" do
    get :show, id: @word_list
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @word_list
    assert_response :success
  end

  test "should update word_list" do
    patch :update, id: @word_list, word_list: { author: @word_list.author, title: @word_list.title }
    assert_redirected_to word_list_path(assigns(:word_list))
  end

  test "should destroy word_list" do
    assert_difference('WordList.count', -1) do
      delete :destroy, id: @word_list
    end

    assert_redirected_to word_lists_path
  end
end
