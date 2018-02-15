class HomeController < ApplicationController
  def index
  end

  def tweet
  	begin 
			text = params.permit(:tweet)
			tweet = Tweet.new(text['tweet'])
			flash[:success] = "Tweet was successfully sent!"
			redirect_to root_path
		rescue
			flash[:danger] = "Tweet was not sent!"
			redirect_to root_path
		end
  end	

end
