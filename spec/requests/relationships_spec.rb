require 'rails_helper'

RSpec.describe "Relationships", type: :request do
  describe "#create" do
    let(:user) { FactoryBot.create(:user) }
    let(:other) { FactoryBot.create(:archer) }
    
    content "未ログインの場合" do
      it "登録されないこと" do
        expect {
          post relationships_path
        }.to_not change(Relationships, :count)
      end
      
      it "ログインページにリダイレクトすること" do
        post relationships_path
        expect(response).to redirect_to login_path
      end
    end
    
    it "1件増加すること" do
      log_in user
      expect {
        post relationships_path, params: { followed_id: other.id }
      }.to change(Relationship, :count).by 1
    end
    
    it "Ajaxでも登録できること" do
     log_in user
     expect {
       post relationships_path, params: { followed_id: other.id }, xhr: true
     }.to change(Relationship, :count).by 1
   end
  end
  
  describe "#destroy" do
    let(:user) { FactoryBot.create(:user) }
    let(:other) { FactoryBot.create(:archer) }
    
    it "1件減少すること" do
      log_in user
      user.follow(other)
      relationship = user.active_relationships.find_by(followed_id: other.id)
      expect {
        delete relationship_path(relationship)
      }.to change(Relationship, :count).by-1
    end
    
    it "Ajaxでも削除できること" do
      log_in user
      user.follow(other)
      relationship = user.active_relationships.find_by(followed_id: other.id)
      expect {
        delete relationship_path(relationship), xhr: true
      }.to change(Relationship, :count).by-1
   end
  end
end
