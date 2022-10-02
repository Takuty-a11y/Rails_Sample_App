require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { User.new(name: 'Example User',
                        email: 'user@example.com',
                        password: 'foobar',
                        password_confirmation: 'foobar') }
  
  it "ユーザーが有効であること" do
    expect(user).to be_valid
  end
  
  it 'nameが必須であること' do
   user.name = ''
   expect(user).to_not be_valid
 end
 
 it 'emailが必須であること' do
   user.email = ''
   expect(user).to_not be_valid
 end
 
 it 'nameは50文字以内であること' do
   user.name = 'a' * 51
   expect(user).to_not be_valid
 end
  
 it 'emailは255文字以内であること' do
   user.email = "#{'a' * 244}@example.com"
   expect(user).to_not be_valid
 end
 
 it 'emailは重複して登録できないこと' do
   #ユーザーのコピーを作成
   duplicate_user = user.dup
   duplicate_user.email = user.email.upcase
   user.save
   expect(duplicate_user).to_not be_valid
 end
 
 it 'passwordが必須であること' do
   user.password = user.password_confirmation = ' ' * 6
   expect(user).to_not be_valid
 end

 it 'passwordは6文字以上であること' do
   user.password = user.password_confirmation = 'a' * 5
   expect(user).to_not be_valid
 end
 
 it "投稿したユーザが削除された場合、そのユーザのMicropostも削除されること" do
   micropost = create(:most_recent)
   user = micropost.user
   expect{ user.destroy }.to change(Micropost, :count).by-1
 end
 
 describe "#authenticated?" do
    it 'digestがnilならfalseを返すこと' do
     expect(user.authenticated?('')).to be_falsy
    end
 end
 
 describe "#follow and #unfollow" do
   let(:user) { FactoryBot.create(:user) }
   let(:other) { FactoryBot.create(:archer) }
   
   it "followするとfollowingがtrueになること" do
     expect(user.following?(other)).to_not be_truthy
     user.follow(other)
     expect(other.followers.include?(user)).to be_truthy
     expect(user.following?(other)).to be_truthy
   end
   
   it "unfollowするとfollowingがfalseになること" do
     user.follow(other)
     expect(user.following?(other)).to_not be_falsy
     user.unfollow(other)
     expect(user.following?(other)).to be_falsy
   end
 end
 
 describe "#feed" do
   let(:posted_by_user) { FactoryBot.create(:post_by_user) }
   let(:posted_by_lana) { FactoryBot.create(:post_by_lana) }
   let(:posted_by_archer) { FactoryBot.create(:post_by_archer) }
   let(:user) { posted_by_user.user }
   let(:lana) { posted_by_lana.user }
   let(:archer) { posted_by_archer.user }
   
   it "フォローしているユーザの投稿が表示されること" do
     lana.microposts.each do |post_following|
       expect(user.feed.include?(post_following)).to be_truthy
     end
   end
   
   it "自分自身の投稿が表示されること" do
     user.microposts.each do |post_self|
       expect(user.feed.include?(post_self)).to be_truthy
     end
   end
   
   it "フォローしていないユーザの投稿が表示されないこと" do
     archer.microposts.each do |post_unfollowing|
       expect(user.feed.include?(post_unfollowing)).to be_falsy
     end
   end
 end
end
