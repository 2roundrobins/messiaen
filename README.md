# massiaen BETA v0.2
 norns script based on birdsong

![main_gui2](/assets/doc/main_gui.png)

single buffer delay / looper for mimicking birdsong
this is far from finished and I intend to make this at least somewhat workable

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
E2 area position
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

### bird controls

chirp sound can be slightly moved. this is the recorded material, so if you want it to change its timbre of the loop you can do so by changing the possition using E2. volume control is controlled by moving E3. 

### bird info
![bird_info_gui](/assets/doc/bird_info_gui.png)
each birdsong has its own description that will hopefully help you understand the wacky rate changes. you can initiate this by pressing K1 and K2. 

## params

there are a couple of extra goodies in the param section of norns. there you can change a couple of parameters, like;

### bird voice
change the chosen bird, and it's song shape (cuttoff, volume)

### chirp material
basically your recorded material. you can push for seed being audiable, which will let you hear the whole recorded loop if you so choose. you can change this recorded loop by changing the loop size etc.

### tranform birds (forthcoming)
ignore this

### garden (forthcoming)
![garden_gui](/assets/doc/garden_gui2.png)
still in early works, but the idea here is that you can have multiple birds singing to you. if you want to test this first go to bird choir and choose your birdy friends. you can attract the birds to you garden by choosing "yes" on the attract option. you can also toggle garden by pressing the key combo K1 + K3

### forest 
here you can change the ambience file by loading your own enviroment. you can turn off the enviromental sounds by turning to "no" on the plant forest option.

## future

### adding birds
a goal here is also to make messiaen a community driven script with adding birds with the upcoming updates. if you would like to add birds of your own and add them to the pile, then you can do that by following the guide in the birds library -- lib. you can share them by just opening an issue, stating which bird species and your gitHub name, so I can properly credit you in any upcoming updates. GUI illustration will also be provided from my side. 
