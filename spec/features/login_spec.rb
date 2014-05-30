require 'spec_helper'

feature 'Login', js: true do

  background do
    @user = FactoryGirl.build(:user)
    @password = @user.password
    @user.save
    @user.activate!
  end

  scenario 'shows login page' do
    visit '/'
    expect(page).to have_content 'FBM'
  end

  scenario 'shows sign up page' do
    visit '/'
    click_button 'Sign Up'
    expect(page).to have_content 'Register'
  end

  scenario 'valid login' do
    visit '/'
    fill_in 'email', with: @user.email
    fill_in 'password', with: @password
    click_button 'Log In'
    expect(page).to have_content "Hi, #{@user.email}!"
  end

end
