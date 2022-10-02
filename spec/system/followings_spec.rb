require 'rails_helper'

RSpec.describe "Followings", type: :system do
  before do
    driven_by(:rack_test)
    @user = FactoryBot.send(:create_relationships)
    log_in @user
  end

  describe "followingページ" do
    it "followingの数とフォローしているユーザへのリンクが表示されていること" do
      visit following_user_path(@user)
      expect(@user.following).to be_empty
      expect(page).to have_content '10 following'
      @user.following.each do |user|
        expect(page).to have_link user.name, href: user_path(user)
      end
    end
  end
  
  describe "followersページ" do
    it "followersの数とフォローしているユーザへのリンクが表示されていること" do
      visit following_user_path(@user)
      expect(@user.followers).to be_empty
      expect(page).to have_content '10 followers'
      @user.followers.each do |user|
        expect(page).to have_link user.name, href: user_path(user)
      end
    end
  end
end
