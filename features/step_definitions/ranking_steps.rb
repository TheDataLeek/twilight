Given /I am on my user profile/ do
    user = User.new(:username => "tester",
                    :email => 'tester@test.com',
                    :password => 'testtesttest')
    user.save

    visit('/login')
    fill_in('Email', :with=>'tester@test.com')
    fill_in('Password', :with=>'testtesttest')
    click_button('Sign In')

    uri = URI.parse(current_url)
    "#{uri.path}?#{uri.query}".should == '/users/1?'
end

When /I click on the ranking button/ do
    click_link("Rankings")
end

Then /I should see a list of my followers ranked by (.*)/ do |order|
    pending
end

When /I click on my ranking/ do
end

Then /I should see a user with a higher ranking on (.*)/ do |sort|
end

When /I click on my visualization/ do
end

Then /I should see my influence as a graph/ do
end
