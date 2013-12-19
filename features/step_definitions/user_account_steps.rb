Given /I am a new user to the site/ do
    visit('/')
    find_link("Login").visible?
end

And /I am on the (.*) page/ do |page|
    if(page == 'home')
	visit('/')
    else	
        visit(page)
    end
end

And /I have filled in my twitter information/ do
    fill_in("Username", :with=>"tester")
    fill_in("Email", :with=>"tester@test.com")
    fill_in("Password", :with=>"testtesttest")
    fill_in("Confirm Password", :with=>"testtesttest")
end

When /I press (.*)/ do |button|
    click_button(button)
end

Then /I should have a new account/ do
    page.should have_content("Welcome tester")
end

And /I should be on my user profile/ do
    uri = URI.parse(current_url)
    "#{uri.path}?#{uri.query}".should == '/users/1?'
end
