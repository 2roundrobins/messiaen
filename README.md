# massiaen BETA v0.3
 norns script based on birdsong

![main_gui2](/assets/doc/main_gui.png)

single buffer delay / looper for mimicking birdsong
@fellowfinch @sonocircuit with GUI @mechtai.

**this is far from finished and I intend to make this at least somewhat workable**

but here is what you need if you want to test;

## hardware

**required**

- [norns](https://github.com/p3r7/awesome-monome-norns) (231114 or later)
  - **the required norns version is recent, please be sure that your norns is up-to-date before launching**


## install

install directly from gitHub

or

in maiden type:

```
;install https://github.com/2roundrobins/messiaen
```


## start

recommended: launch the script from the norns [SELECT](https://monome.org/docs/norns/play/#select) menu.

## controls

E1 change that bird! 
E2 mood position
E3 chirp volume

K1 is used as combo key
K2 it sings
K3 it flips
K1+K2 toggle info
K1+K3 toggle garden

## instructions 
![bird_gui2](/assets/doc/bird_gui.png)
main gui so you can look at this amazing 8bit bird art!

### recording

recording is now done by exceeding the recording threshold or by playing your instrument a bit louder. by default it's set to -12.0db, but you can freely change this by visiting the PARAMS.

### playing

press K2 and the bird will start singing a random song based on it's species repertoire. you can stop the playing by pressing K2 again. by moving E1 you can change the bird species and the corresponding birdsong. 

### mood

mood which can be changed by turning E2 is meant as birds feistiness. the higher the value, more feisty the bird will be. moving the value downword however shall make the birdsong a bit calmer and longer.

### chirp

this is the general volume control of the bird

### bird info
![bird_info_gui](/assets/doc/bird_info_gui.png)
each birdsong has its own description that will hopefully help you understand the wacky rate changes. you can initiate this by pressing K1 and K2. 

## params

there are a couple of extra goodies in the param section of norns. there you can change a couple of parameters, like;

### birds
you can change the bird control values for your main bird (the one that is shown on the screen) and friendly visitors (birds that you can call through garden mode).

bird: change bird species
level: change the volume
mood: change the feistiness
position: change the bird panning
area: the cutoff frequency

### recording
change the recording threshold accordingly. by default it's -12db.

### garden (forthcoming)
![garden_gui](/assets/doc/garden_gui2.png)
still in early works, but the idea here is that you can have multiple birds singing to you. if you want to test this first select your bird friends in the birds section and position them to taste. you will be able to position the bird by turning the encouder "position birds" and it should position them throughout the garden space automatically (forthcoming). invite the birds by changing the option to "yes" and enjoy. you can change the song density if they are a bit too lively (this also works for main bird). feed birds (forthcoming).
you can also toggle garden by pressing the key combo K1 + K3 on the main screen.

### forest 
here you can change the ambience file by loading your own enviroment. you can turn off the enviromental sounds by turning to "no" on the plant forest option.

## future

### adding birds
a goal here is also to make messiaen a community driven script with adding birds with the upcoming updates. if you would like to add birds of your own and add them to the pile, then you can do that by following the guide in the birds library -- lib. you can share them by just opening an issue, stating which bird species and your gitHub name, so I can properly credit you in any upcoming updates. GUI illustration will also be provided from my side. 
