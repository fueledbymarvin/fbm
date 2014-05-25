describe User do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:user)).to be_valid
  end

  describe 'validations' do
    it 'is invalid without an email' do
      expect(FactoryGirl.build(:user, email: nil)).to_not be_valid
    end

    it 'is invalid if email is not unique' do
      user = FactoryGirl.create(:user)
      expect(FactoryGirl.build(:user, email: user.email)).to_not be_valid
    end

    it 'is invalid if email is invalid' do
      expect(FactoryGirl.build(:user, email: "in@valid")).to_not be_valid
    end

    it 'is invalid if password is shorter than 5 char' do
      expect(FactoryGirl.build(:user, password: "shor")).to_not be_valid
    end

    it 'is invalid if password and confirmation do not match' do
      expect(FactoryGirl.build(:user, password: "password", password_confirmation: "fail")).to_not be_valid
    end
  end
    
  describe '#reset_password_attrs' do
    subject(:user) do
      user = FactoryGirl.create(:user, reset_password_token: "token", reset_password_token_expires_at: DateTime.now, reset_password_email_sent_at: DateTime.now)
      user.reset_password_attrs
      user
    end

    it 'has no reset_password_token' do
      expect(user.reset_password_token).to be nil
    end

    it 'has no reset_password_token_expires_at' do
      expect(user.reset_password_token_expires_at).to be nil
    end

    it 'has no reset_password_email_sent_at' do
      expect(user.reset_password_email_sent_at).to be nil
    end
  end

  describe '#gen_key' do
    subject(:user) { FactoryGirl.create(:user) }

    it 'has an api key' do
      expect(user.api_key).not_to be_blank
    end
  end
end
