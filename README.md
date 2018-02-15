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
<br/>
### 5 Hair au cul
Il est venu, le temps...de push ça sur heroku !!! Et ouais ma gueule t'as cru qu'on étais des p'tits twittos du dimanche? Bah non on est des gros hackers de ouf t'as vu !!<br/>
Bon rien de bien ouf, mais ça vaut le coup d'être expliqué:<br/>
Donc là on est d'accord, ton appli marche sur ton serveur local, parceque comme t'es pas un **noob** t'as rentré tes clefs dans le .env.<br/>
Mais là ce que tu veux, c'est que d'autres personnes, qui ont pas envie de se faire chier à download, bundle install, db:migrate etc, puissent quand meme envoyer des tweets... Bah qu'est ce qu'on va faire? on va changer les config vars d'Heroku. En gros, on donne nos KEYS à tout le monde sans vraiment les donner. Malin l'abruti non ? Merci la [doc Heroku](https://devcenter.heroku.com/articles/config-vars#setting-up-config-vars-for-a-deployed-application) quand même.<br/>
Pour cela, petit coup de console:<br/>
```
$ cd twittosuce
$ heroku config:set TWITTER_CONSUMER_KEY= "La" TWITTER_CONSUMER_SECRET= "La" TWITTER_ACCESS_TOKEN= "La" TWITTER_ACCESS_SECRET= "La"
``` 
Biensûr, encore un peu de bon sens, faut mettre la clef correspondante pour chaque **"La"**. *Basique*.
Et voilà, maintenant n'importe quel personne qui a le lien de ton app' peut pourrir ton compte twitter, génial non? *Simple*.

