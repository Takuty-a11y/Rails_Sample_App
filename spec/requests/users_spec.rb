require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /signup" do
    it "サインアップページを開かれること" do
      get signup_path
      expect(response).to have_http_status(:ok)
    end
  end
  
  describe "GET /users" do
    let(:user) { FactoryBot.create(:user) }
    
    it "ログインユーザでなければログインページにリダイレクトすること" do
      get users_path
      expect(response).to redirect_to login_path
    end
    
    it "activateされていないユーザは表示されないこと" do
      not_activation_user = FactoryBot.create(:malory)
      log_in(user)
      get users_path
      expect(response.body).to_not include not_activation_user
    end
    
    describe "pagination" do
     before do
       30.times do
         create(:continuous_users)
       end
       log_in user
       get users_path
     end
    
     it "div.paginationが存在すること" do
       expect(response.body).to include '<div class="pagination">'
     end
   
     it "ユーザごとのリンクが存在すること" do
       User.paginate(page: 1).each do |user|
         expect(response.body).to include "<a href=\"#{user_path(user)}\">"
       end
     end
   end
  end
  
  describe "GET /users/{id}" do
    it '有効化されていないユーザの場合はrootにリダイレクトすること' do
     user = FactoryBot.create(:user)
     not_activated_user = create(:malory)
  
     log_in user
     get user_path(not_activated_user)
     expect(response).to redirect_to root_path
   end
  end
  
  describe "GET /users/{id}/edit" do
   it "タイトルがEdit user | Ruby on Rails Tutorial Sample Appであること" do
     log_in user
     get edit_user_path(user)
     expect(response.body).to include full_title('Edit user')
   end
  
   context "未ログインの場合" do
     it "flashが空でないこと" do
       get edit_user_path(user)
       expect(flash).to_not be_empty
     end
  
     it "未ログインユーザはログインページにリダイレクトされること" do
       get edit_user_path(user)
       expect(response).to redirect_to login_path
     end
   end
   
   context "別のユーザの場合" do
     let(:other_user) { FactoryBot.create(:archer) }
     
     it "flashが空であること" do
       log_in user
       get edit_user_path(other_user)
       expect(flash).to be_empty
    end
    
    it "root_pathにリダイレクトされること" do
       log_in user
       get edit_user_path(other_user)
       expect(response).to redirect_to root_path
    end
   end
 end
 
 describe "GET /users/{id}/following" do
   let(:user) { FactoryBot.create(:user) }
   
   it "未ログインならログインページにリダイレクトすること" do
    get following_user_path(user)
    expect(response).to redirect_to login_path
   end
 end
 
 describe "GET /users/{id}/followers" do
   let(:user) { FactoryBot.create(:user) }
   
   it "未ログインならログインページにリダイレクトすること" do
    get following_user_path(user)
    expect(response).to redirect_to login_path
   end
 end
  
  describe "POST /users #create" do
    it "無効なユーザー登録はされないこと" do
      expect {
       post users_path, params: { user: { name: '',
                                          email: 'user@invlid',
                                          password: 'foo',
                                          password_confirmation: 'bar' } }
     }.to_not change(User, :count)
    end

    context "有効な値の場合" do
     let(:user_params) { { user: { name: 'Example User',
                                   email: 'user@example.com',
                                   password: 'password',
                                   password_confirmation: 'password' } } }
                                   
      before do
        ActionMailer::Base.deliveries.clear
      end
  
     it "登録されること" do
       expect {
         post users_path, params: user_params
       }.to change(User, :count).by 1
     end
     
     it "メールが1件存在すること" do
       post users_path, params: user_params
       expect(ActionMailer::Base.deliveries.size).to eq 1
     end

     it "登録時点ではactivateされていないこと" do
       post users_path, params: user_params
       expect(User.last).to_not be_activated
     end
     it "users/showにリダイレクトされること" do
       post users_path, params: user_params
       #user = User.last
       expect(response).to redirect_to root_path
     end
     
     it "flashが表示されること" do
       post users_path, params: user_params
       expect(flash).to be_any
     end
     
     it "ログイン状態であること" do
        post users_path, params: user_params
        expect(logged_in?).to be_truthy
     end
   end
 end
 
 describe "PATCH /users" do
   let(:user) { FactoryBot.create(:user) }
   
   it "タイトルがEdit user | Ruby on Rails Tutorial Sample Appであること" do
     get edit_user_path(user)
     expect(response.body).to include full_title('Edit user')
   end
   
   it "admin属性は更新できないこと" do
     log_in user = FactoryBot.create(:archer)
     expect(user).to_not be_admin

     patch user_path(user), params: { user: { password: 'password',
                                              password_confirmation: 'password',
                                              admin: true } }
     user.reload
     expect(user).to_not be_admin
   end
   
   context "別のユーザの場合" do
     let(:other_user) { FactoryBot.create(:archer) }
     
    before do
      log_in user
      patch user_path(other_user), params: { user: { name: other_user.name,
                                                    email: other_user.email } }
    end
    
    it "flashが空であること" do
      expect(flash).to be_empty
    end
    
    it "rootにリダイレクトすること" do
      expect(response).to redirect_to root_path
    end
   end
   
   context "未ログインの場合" do
    it "flashが空でないこと" do
        patch user_path(user), params: { user: { name: user.name,
                                                email: user.email } }
        expect(flash).to_not be_empty
    end
    
    it "未ログインユーザはログインページにリダイレクトされること" do
      patch user_path(user), params: { user: { name: user.name,
                                            email: user.email } }
      expect(response).to redirect_to login_path
    end
    
    it "ログインすると編集ページにリダイレクトされること" do
      get edit_user_path(user)
      log_in user
      expect(response).to redirect_to edit_user_path(user)
    end
   end
   
   context "無効な値の場合" do
    before do
      log_in user
      patch user_path(user), params: { user: { name: '',
                                               email: 'foo@invlid',
                                               password: 'foo',
                                               password_confirmation: 'bar' } }
    end
    
     it "更新できないこと" do
       user.reload
       expect(user.name).to_not eq ''
       expect(user.email).to_not eq ''
       expect(user.password).to_not eq 'foo'
       expect(user.password_confirmation).to_not eq 'bar'
     end
     
     it "更新アクション後にeditのページが表示されていること" do
       expect(response.body).to include full_title('Edit user')
     end
     
     it "The form contains 4 errors.と表示されていること" do
       expect(response.body).to include 'The form contains 4 errors.'
     end
   end
   
   context "有効な値の場合" do
     before do
       @name = 'Foo Bar'
       @email = 'foo@bar.com'
       patch user_path(user), params: { user: { name: @name,
                                                email: @email,
                                                password: '',
                                                password_confirmation: '' } }
     end
   
     it "flashが表示されていること" do
       expect(flash).to be_any
     end
     
     it "Users#showにリダイレクトすること" do
       expect(response).to redirect_to user
     end
     
     it "更新できること" do
       user.reload
       expect(user.name).to eq @name
       expect(user.email).to eq @email
     end
   end
 end
 
 describe "DELETE /users/{id}" do
   let!(:user) { FactoryBot.create.(:user) }
   let!(:other_user) { FactoryBot.create(:archer) }
   
   context "未ログインの場合" do
     it "削除できないこと" do
       expect{ delete user_path(user) }.to_not change(User, :count)
     end
     
     it "ログインページにリダイレクトすること" do
       delete user_path(user)
       expect(response).to redirect_to login_path
     end
   end
   
   context "adminユーザでない場合" do
     it "削除できないこと" do
       log_in other_user
       expect{ delete user_path(user) }.to_not change(User, :count)
     end
     
     it "rootページにリダイレクトすること" do
       log_in other_user
       delete user_path(user)
       expect(response).to redirect_to root_path
     end
   end
   
   context "adminユーザである場合" do
     it "他のユーザを削除できること" do
       log_in user
       expect {
         delete user_path(other_user)
       }.to change(User, :count).by-1
     end
   end
 end
end
