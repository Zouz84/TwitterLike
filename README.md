Download moi tout ça > ajoute tes keys dans le `.env`> Bundle install > rake db:migrate (on sait jamais) > rails S > [LocalHost](http://localhost:3000/).

J'ai donné le lien HEROKU sur mon formulaire de correction. Par contre ça tweet de mon compte à moi... Vous pouvez le verifier en le visitant: https://twitter.com/Seizar84. 

### Etape 1 : Structure
commandes :
rails new twittosuce<br/>
*Change le gem file *<br/>
Bundle install —without production *(ou bundle update)*<br/>
rails generate controller home index tweet<br/>
rails db:migrate
<br/>
<br/>
### Etape 2 - On connecte les fichiers entre eux
on créer une page index.html.erb dans le dossier home<br/>
à l’aide de la commande :<br/>
`touch app/views/home/index.html.erb` <br/>
on route ce fichier ‘index.html.erb’ dans notre fichier 'routes.rb'.<br/>
où on ajoute :<br/>
root ’home#index’<br/>
et "post '/tweet' => 'home#tweet'"
<br/>
<br/>
### Etape 3 - Services
On créé un dossier services dans le dossier **app**<br/>
mkdir app/services<br/>
dans ce dossier on créer un fichier 'tweet.rb’ avec:<br/>
touch app/services/tweet.rb<br/>
dans ce même fichier on définie une classe appelée : **Tweet** <br/>
```ruby
class Tweet
# on définie ensuite nos méthodes :

def initialize
# qui va effectuer lui même la methode perform.
end

def twitter_connection
# cette méthode prendra nos clés API pour pouvoir nous connecter
end

def sent_tweet
# Va rentrer les API de connection à twitter dans une variable 'client'. Afin de pouvoir mettre à jour le profil twitter avec le tweet envoyé.
end

end

def perform
# qui contient la def sent_tweet ci-dessus
end
end
```

#### 3.2 On remplit nos méthodes :<br/>
Disons que nous n'allons pas commencer par le commencement.<br/>
Tout d'abord on va se lier à twitter en renseignant les API twitter dans la fonction '*twitter_connection*'.<br/>
<br/>
Dans le controller 'home' nous allons définir deux variables, '*text*' et '*tweet*'. La première sera une variable permettant un attribut :tweet, la seconde est la variable qui définit une nouvelle instance, un nouveau tweet.<br/>
A cela apparait un flash de confirmation si la fonction tweet.newa bien été effectuée. Sinon on instaure un modèle de rescue qui indique qu'il y a une erreur, mais qui nous permet de continuer depuis la meme page. Ce qui nous donne:<br/>
```ruby
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
  ```
  
En gros, pour faire simple:
* On créer la methode **twitter_connection** pour se lier à twitter
* On créer la methode **sent_tweet(tweet)** qui va prendre en compte notre *'tweet'* et donner cette info à twitter.
* La méthode **perform** "effectue" la méthode *sent_tweet(tweet)*.
* Enfin la methode **initialize(tweet)** active le tout en appelant *perform*

Ce qui nous donne ceci : 
```ruby
class Tweet

	def initialize(tweet)
		perform(tweet)
	end

	def twitter_connection
		Twitter::REST::Client.new do |config|
		  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
		  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
		  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
		  config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
		end
	end

	def send_tweet(tweet)
		client = twitter_connection
		client.update(tweet)
	end

	def perform(tweet)
		send_tweet(tweet)
	end

end
```
### 4 Dotenv

On créer le fichier.env que l’on va mettre dans notre dossier racine de l'app, et qui sera également stipulé dans le fichier  .gitignore (pour pas balancer nos Clés sur Github et se faire voler 200€ de caution pardes malotrus. Ah non c'est autre chose ça?).<br/>
`cd twittosuce`<br/>
`touch .env`<br/>
Tu met les clés en face des trous (*toujours! le gauche en premier, toujours!*)<br/>
```ruby
TWITTER_API_KEY=" TA CLE ICI "
TWITTER_API_SECRET=" TA CLE ICI "
TWITTER_TOKEN=" TA CLE ICI "
TWITTER_TOKEN_SECRET=" TA CLE ICI "
```
Tu vas ensuite dans le fichier .gitignore et tu ajoute :<br/>
`.env`<br/>
petit commit des familles: <br/>
```git init
git add .
git commit -m « first commit »
```
on crée l’app heroku<br/>
`heroku create`<br/>
petit test de contrôle :  tape dans le terminal : <br/>
`rails c`
et 
`Tweet.new("Salut, toi!").perform`<br/>
### 5 Le formulaire 
Ensuite on va donner une interface à notre application, en créant un formulaire (qui va prendre notre ‘content’ et le submit sur twitter) 
Pour cela on va avoir besoin de note controller (tweet_controller.rb) et de notre new.html.erb
Le contrôleur : 
Ici on va définir nos méthodes (petit coup de formulaire classique) 
on définir une méthode 
new : qui créer un nouveau tweet 
create : qui crée un nouveau tweet à partir de notre input 
private : qui défini les params pour le ‘content’
mise en forme : 
class TweetsController < ApplicationController
    def new
    @tweet = Tweet.new
  end
  def create
    @tweet = Tweet.new(tweet_params)
    if @tweet.save
      
      SendTweet.new("#{@tweet.content}").perform
      redirect_to root_path 
    else render 'new'
    end
  end
  private
    def tweet_params
      params.permit(:content)
    end
end
5.2 Le visuel (new.html.erb)
qui inclue les message d’erreur classique 
et notre formulaire => input + submit
comme ceci : 
<h1>Ton Titre mon gros</h1>
<%= form_tag (tweets_path) do %>
 
  <% if @tweet.errors.any? %>
    <div id="error_explanation">
      <h2>
        <%= pluralize(@tweet.errors.count, "error") %> prohibited
        this user from being saved:
      </h2>
        <% @tweet.errors.full_messages.each do |msg| %>
          <p><%= msg %></p>
        <% end %>
    </div>
  <% end %>
<div class="row">
  <div class="col-md-6 col-md-offset-3">
    
  <p> <%= label_tag 'content', "ton tweet mon petit"  %> </p>
  <p> <%= text_field_tag(:content) %> </p>
<p> <%= submit_tag 'Partage avec le monde entier', class: "btn btn-primary"%></p>
  </div>
</div>
<% end %>
On teste ça à coup de :
Rails server & localhost:3000
Voila la ça marche en locale


