describe 'Sorcery user actions' do
  let(:headers) { createHeaders(1, "") }

  after(:each) { ActionMailer::Base.deliveries.clear }

  describe 'activation' do
    let(:registrant) { FactoryGirl.build(:user) }
    let(:valid_params) { {email: registrant.email, password: registrant.password, password_confirmation: registrant.password_confirmation} }

    describe 'POST #create' do
      let(:invalid_params) do
        params = valid_params
        params[:email] = ""
        params
      end

      context 'valid params' do
        it 'sends an activation needed email' do
          expect{ post '/api/users', valid_params, headers }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end

        it 'sends it to the registrant' do
          post '/api/users', valid_params, headers
          expect(ActionMailer::Base.deliveries.last.to.first).to eq registrant.email
        end

        it 'is from Marvin' do
          post '/api/users', valid_params, headers
          expect(ActionMailer::Base.deliveries.last.from.first).to eq 'm@fueledbymarv.in'
        end

        it 'sends the activation link' do
          post '/api/users', valid_params, headers
          expect(ActionMailer::Base.deliveries.last.body.encoded).to match "#{ENV['FBM_ROOT_URL']}/#/activate/#{registrant.activation_token}"
        end

        it 'has the right subject' do
          post '/api/users', valid_params, headers
          expect(ActionMailer::Base.deliveries.last.subject).to eq 'Welcome!'
        end
      end

      context 'invalid params' do
        it 'does not send an activation email' do
          expect{ post '/api/users', invalid_params, headers }.not_to change { ActionMailer::Base.deliveries.count }
        end
      end
    end

    describe 'GET #activate' do
      context 'valid token' do
        before(:each) { post '/api/users', valid_params, headers }

        it 'activates the user' do
          expect{ get "/api/activate/#{User.last.activation_token}", {}, headers }.to change{ User.last.activation_state }.from('pending').to('active')
        end

        it 'sends it to the registrant' do
          get "/api/activate/#{User.last.activation_token}", {}, headers
          expect(ActionMailer::Base.deliveries.last.to.first).to eq registrant.email
        end

        it 'is from Marvin' do
          get "/api/activate/#{User.last.activation_token}", {}, headers
          expect(ActionMailer::Base.deliveries.last.from.first).to eq 'm@fueledbymarv.in'
        end

        it 'has the right subject' do
          get "/api/activate/#{User.last.activation_token}", {}, headers
          expect(ActionMailer::Base.deliveries.last.subject).to eq 'Your account is active!'
        end
      end
      
      context 'invalid token' do
        before(:each) { get '/api/activate/qwerty', {}, headers }
        
        it 'is not found' do
          expect(response.status).to eq 404
        end

        it 'warns that the token is invalid' do
          expect(json['danger']).to eq 'Invalid activation token.'
        end
      end
    end
    
    describe 'POST #resend_activation' do
      context 'valid email' do
        before(:each) { post '/api/users', valid_params, headers }

        it 'succeeds' do
          post '/api/activate/resend', { email: registrant.email }, headers
        end

        it 'returns the user' do
          post '/api/activate/resend', { email: registrant.email }, headers
          expect(json['email']).to eq registrant.email
        end

        it 'sends an activation needed email' do
          expect{ post '/api/activate/resend', { email: registrant.email }, headers }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end

        it 'sends it to the registrant' do
          post '/api/activate/resend', { email: registrant.email }, headers
          expect(ActionMailer::Base.deliveries.last.to.first).to eq registrant.email
        end

        it 'is from Marvin' do
          post '/api/activate/resend', { email: registrant.email }, headers
          expect(ActionMailer::Base.deliveries.last.from.first).to eq 'm@fueledbymarv.in'
        end

        it 'sends the activation link' do
          post '/api/activate/resend', { email: registrant.email }, headers
          expect(ActionMailer::Base.deliveries.last.body.encoded).to match "#{ENV['FBM_ROOT_URL']}/#/activate/#{registrant.activation_token}"
        end

        it 'has the right subject' do
          post '/api/activate/resend', { email: registrant.email }, headers
          expect(ActionMailer::Base.deliveries.last.subject).to eq 'Welcome!'
        end
      end

      context 'invalid email' do
        before(:each) { post '/api/activate/resend', { email: 'in@valid' }, headers }
        
        it 'is not found' do
          expect(response.status).to eq 404
        end

        it 'warns that the email is invalid' do
          expect(json['danger']).to eq "Email doesn't correspond to any users."
        end
      end
    end
  end

  describe 'password reset' do
    let(:user) do
      user = FactoryGirl.create(:user)
      user.activate!
      user
    end
  end
end
