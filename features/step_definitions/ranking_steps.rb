Given /I am on my user profile/ do
    user1 = User.new(:username => "tester",
                     :email => 'tester1@test.com',
                     :password => 'testtesttest')
    user2 = User.new(:username => "test1",
                     :email => 'tester2@test.com',
                     :password => 'testtesttest')
    user3 = User.new(:username => "test2",
                     :email => 'tester3@test.com',
                     :password => 'testtesttest')
    user4 = User.new(:username => "test3",
                     :email => 'tester4@test.com',
                     :password => 'testtesttest')
    user5 = User.new(:username => "test4",
                     :email => 'tester5@test.com',
                     :password => 'testtesttest')
    follower1 = Followers.new(:user => "test1",
                              :follows => "tester")
    follower2 = Followers.new(:user => "test2",
                              :follows => "tester")
    follower3 = Followers.new(:user => "test3",
                              :follows => "tester")
    user1.save
    user2.save
    user3.save
    user4.save
    user5.save
    follower1.save
    follower2.save
    follower3.save

    visit('/login')
    fill_in('Email', :with=>'tester1@test.com')
    fill_in('Password', :with=>'testtesttest')
    click_button('Sign In')

    uri = URI.parse(current_url)
    "#{uri.path}?#{uri.query}".should == '/users/1?'
end

When /I click on the ranking button/ do
    click_link("Update Info")
    click_link("Rankings")
end

Then /I should see a list of my followers ranked by (.*)/ do |order|
    page.should have_content("tester -- ")
end

When /I click on my ranking/ do
end

Then /I should see a user with a higher ranking on (.*)/ do |sort|
end
