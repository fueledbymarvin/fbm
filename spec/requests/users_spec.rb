describe 'Users API' do
  let(:user) do 
    user = FactoryGirl.create(:user)
    user.activate!
    user
  end

  context 'unauthenticated user' do
    let(:new_headers) { createHeaders(1, '') }

    describe 'GET #me' do
      before(:each) { get '/api/users/me', {}, new_headers }

      it 'succeeds' do
        expect(response).to be_success
      end

      it 'returns nil' do
        expect(json).to eq(nil)
      end
    end

    describe 'GET #index' do
      before(:each) { get '/api/users', {}, new_headers }

      it 'is forbidden' do
        expect(response.status).to eq(403)
      end

      it 'warns that user must be admin' do
        expect(json['danger']).to eq("Must be an admin to access that page.")
      end
    end

    describe 'GET #show' do
      before(:each) { get "/api/users/#{user.id}", {}, new_headers }

      it 'is forbidden' do
        expect(response.status).to eq(403)
      end

      it 'warns that one can\'t access others\' profiles' do
        expect(json['danger']).to eq("Cannot access other users' information.")
      end
    end

    describe 'POST #create' do
      let(:registrant) { FactoryGirl.build(:user) }
      let(:valid_params) { {email: registrant.email, password: registrant.password, password_confirmation: registrant.password_confirmation} }

      context 'valid params' do
        before(:each) { post '/api/users', valid_params, new_headers }

        it 'succeeds' do
          expect(response).to be_success
        end

        it 'returns the user\'s profile' do
          expect(json['email']).to eq(registrant.email)
        end
      end
    end

    describe 'PUT #update' do
      let(:changed) { FactoryGirl.build(:user) }
      let(:valid_params) { {email: changed.email} }

      before(:each) { put "/api/users/#{user.id}", valid_params, new_headers }

      it 'is forbidden' do
        expect(response.status).to eq(403)
      end

      it 'warns that one can\'t access others\' profiles' do
        expect(json['danger']).to eq("Cannot access other users' information.")
      end
    end
      
    describe 'DELETE #destroy' do
      before(:each) { delete "/api/users/#{user.id}", {}, new_headers }

      it 'is forbidden' do
        expect(response.status).to eq(403)
      end

      it 'warns that one can\'t access others\' profiles' do
        expect(json['danger']).to eq("Cannot access other users' information.")
      end
    end
  end

  context 'authenticated user' do
    let(:headers) { createHeaders(1, user.api_key) }

    describe 'GET #me' do
      before(:each) { get '/api/users/me', {}, headers }

      it 'succeeds' do
        expect(response).to be_success
      end

      it 'returns my profile' do
        expect(json['email']).to eq(user.email)
      end
    end

    describe 'GET #index' do
      before(:each) { get '/api/users', {}, headers }

      it 'is forbidden' do
        expect(response.status).to eq(403)
      end

      it 'warns that user must be admin' do
        expect(json['danger']).to eq("Must be an admin to access that page.")
      end
    end

    describe 'GET #show' do
      context 'getting own profile' do
        before(:each) { get "/api/users/#{user.id}", {}, headers }

        it 'succeeds' do
          expect(response).to be_success
        end

        it 'returns my profile' do
          expect(json['email']).to eq(user.email)
        end
      end

      context 'getting someone else\'s profile' do
        let(:another) { FactoryGirl.create(:user) }
        before(:each) { get "/api/users/#{another.id}", {}, headers }
        it 'is forbidden' do
          expect(response.status).to eq(403)
        end

        it 'warns that one can\'t access others\' profiles' do
          expect(json['danger']).to eq("Cannot access other users' information.")
        end
      end
    end

    describe 'POST #create' do
      let(:registrant) { FactoryGirl.build(:user) }
      let(:valid_params) { {email: registrant.email, password: registrant.password, password_confirmation: registrant.password_confirmation} }
      let(:extra_params) { valid_params.merge({admin: true}) }
      let(:invalid_params) do
        params = valid_params
        params['email'] = 'in@valid'
        params
      end

      context 'valid params' do
        before(:each) { post '/api/users', valid_params, headers }

        it 'succeeds' do
          expect(response).to be_success
        end

        it 'returns the user\'s profile' do
          expect(json['email']).to eq(registrant.email)
        end
      end

      context 'with unallowed params' do
        before(:each) { post '/api/users', extra_params, headers }

        it 'ignores the extra params and succeeds' do
          expect(response).to be_success
        end

        it 'sets the extra params to the default values' do
          expect(json['admin']).to be false
        end
      end

      context 'invalid params' do
        before(:each) { post '/api/users', invalid_params, headers }

        it 'has status unprocessable entity' do
          expect(response.status).to eq(422)
        end

        it 'returns email address invalid' do
          expect(json['email']).to include("is invalid")
        end
      end
    end

    describe 'PUT #update' do
      let(:changed) { FactoryGirl.build(:user) }
      let(:valid_params) { {email: changed.email} }
      let(:extra_params) { valid_params.merge({admin: true}) }
      let(:invalid_params) do
        params = valid_params
        params['password'] = 'fail'
        params
      end

      context 'own profile' do
        context 'valid params' do
          before(:each) { put "/api/users/#{user.id}", valid_params, headers }

          it 'succeeds' do
            expect(response).to be_success
          end

          it 'updates the registrant\'s email' do
            expect(json['email']).to eq(changed.email)
          end
        end

        context 'with unallowed params' do
          before(:each) { put "/api/users/#{user.id}", extra_params, headers }

          it 'ignores the extra params and succeeds' do
            expect(response).to be_success
          end

          it 'leaves the extra params at their original values' do
            expect(json['admin']).to be_false
          end
        end

        context 'invalid params' do
          before(:each) { put "/api/users/#{user.id}", invalid_params, headers }

          it 'has status unprocessable entity' do
            expect(response.status).to eq(422)
          end

          it 'returns password too short' do
            expect(json['password']).to include("is too short (minimum is 5 characters)")
          end
        end
      end
      
      context 'someone else\'s profile' do
        let(:attempt_to_change) { FactoryGirl.create(:user) }

        before(:each) { put "/api/users/#{attempt_to_change.id}", valid_params, headers }

        it 'is forbidden' do
          expect(response.status).to eq(403)
        end
        
        it 'warns that one can\'t access others\' profiles' do
          expect(json['danger']).to eq("Cannot access other users' information.")
        end

        it 'does not change their email' do
          expect(User.find(attempt_to_change.id).email).to eq(attempt_to_change.email)
          expect(User.find(attempt_to_change.id).email).not_to eq(changed.email)
        end
      end
    end

    describe 'DELETE #destroy' do
      context 'own profile' do
        before(:each) { delete "/api/users/#{user.id}", {}, headers }

        it 'succeeds' do
          expect(response).to be_success
        end

        it 'returns deleted user' do
          expect(json['email']).to eq(user.email)
        end
      end

      context 'someone else\'s profile' do
        let(:another) { FactoryGirl.create(:user) }
        before(:each) { delete "/api/users/#{another.id}", {}, headers }

        it 'is forbidden' do
          expect(response.status).to eq(403)
        end

        it 'warns that one can\'t access others\' profiles' do
          expect(json['danger']).to eq("Cannot access other users' information.")
        end
      end
    end
  end

  context 'admin user' do
    let!(:admin) { FactoryGirl.create(:user, admin: true) }
    let(:admin_headers) { createHeaders(1, admin.api_key) }
    let!(:another) { FactoryGirl.create(:user) }

    describe 'GET #index' do
      before(:each) { get '/api/users', {}, admin_headers }

      it 'succeeds' do
        expect(response).to be_success
      end

      it 'returns an array of all users' do
        expect(json.length).to eq(2)
      end

      it 'returns users\' info' do
        expect(json.map { |h| h['email'] }).to include(another.email)
      end
    end

    describe 'GET #show' do
      context 'getting another\'s profile' do
        before(:each) { get "/api/users/#{another.id}", {}, admin_headers }

        it 'succeeds' do
          expect(response).to be_success
        end

        it 'returns his profile' do
          expect(json['email']).to eq(another.email)
        end
      end
    end

    describe 'PUT #update' do
      let(:changed) { FactoryGirl.build(:user) }
      let(:valid_params) { {email: changed.email} }
      
      context 'someone else\'s profile' do
        before(:each) { put "/api/users/#{another.id}", valid_params, admin_headers }

        it 'succeeds' do
          expect(response).to be_success
        end

        it 'updates the user\'s email' do
          expect(json['email']).to eq(changed.email)
        end
      end
    end

    describe 'DELETE #destroy' do
      context 'someone else\'s profile' do
        it 'succeeds' do
          delete "/api/users/#{another.id}", {}, admin_headers
          expect(response).to be_success
        end

        it 'warns that one can\'t access others\' profiles' do
          expect { delete "/api/users/#{another.id}", {}, admin_headers }.to change{User.all.length}.from(2).to(1)
        end
      end
    end
  end
end
