# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "Login", :db do
  let(:repository) { Terminus::Repositories::User.new }

  it "logs out and in", :aggregate_failures do
    visit "/logout"
    check "Logout all Logged In Sessions?"
    click_button "Logout"

    expect(page).to have_content "Please log in to continue."

    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Login"

    expect(page).to have_content "You have been logged in."
  end

  it "logs out but can't log in when account is not verified" do
    repository.update user.id, status_id: 1

    visit "/logout"
    check "Logout all Logged In Sessions?"
    click_button "Logout"
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Login"

    expect(page).to have_content "Your account requires verification before proceeding. " \
                                 "Please contact administration for access"
  end
end
