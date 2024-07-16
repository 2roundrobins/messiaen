# messiaen
 norns script based on birdsong

![main_gui2](/assets/doc/main_gui.png)

single buffer delay / looper for mimicking birdsong
[@fellowfinch](https://github.com/2roundrobins), [@sonocircuit](https://github.com/sonocircuit) with GUI illustrations [@mechtai.](https://github.com/mech-tai)


## HARDWARE / INTALL

**required**

- [norns](https://github.com/p3r7/awesome-monome-norns) (240424 or later)
  - **the required norns version is recent, please be sure that your norns is up-to-date before launching**

install directly from gitHub

or

in maiden type:

```
;install https://github.com/2roundrobins/messiaen
```
## BIRD DELAY
the messiaen script takes its name from the contemporary french composer and ornithologist [Olivier Messiaen](https://en.wikipedia.org/wiki/Olivier_Messiaen), whose work "Catalogue d'oiseaux" for solo piano is devoted to birds and the regions they inhabit. messiaen, being an avid bird watcher and collector of their songs, transcribed many bird calls, songs, and chirps in vast quantities and used their musical qualities as the basis of his pieces. focusing on the melody, harmonics, and textures of some bird species, i have tried to honor this practice by creating a script where the complexity and characteristics of birdsong translate to rate changes within the softcut's playheads.

simply record a sound into norns and let the birds sing

### featured bird species
the script features the following bird species;

| bird species | scientific name  | transcriber  |
| ------------ | ---------------- | ------------- |
| Eurasian wren| _Troglodytes troglodytes_ | @fellowfinch AKA 2roundrobins |
| European robin | _Erithacus rubecula_ | @fellowfinch AKA 2roundrobins |
| Eurasian blackbird | _Turdus merula_| @fellowfinch AKA 2roundrobins |
| Eurasian chaffinch | _Fringilla coelebs_  | @fellowfinch AKA 2roundrobins  |
|Great Tit | _Parus major_ | @fellowfinch AKA 2roundrobins |
| Greenfinch| _Chloris chloris_| @fellowfinch AKA 2roundrobins |
|Willow Warbler |  _Phylloscopus trochilus_  | @fellowfinch AKA 2roundrobins   |


if you would like to add your own birds to the species, I suggest reading the [MESSIAEN COMMUNITY PROJECT](#messiaen-community-project)

## MAIN SCREEN

![bird_gui2](/assets/doc/bird_gui.png)

### controls

- e1 changes the bird 
- e2 mood AKA feistiness amount
- e3 chirp volume

- k1 is used as a combo key
- k2 the bird sings
- k3 triggers threshold recording
- k1+k2 toggle info
- k1+k3 toggle garden


### recording

recording is done by exceeding the recording threshold or by pressing k3. when you press k3, a symbol shall appear on the right side of your screen »((» - this shows that it is in rec arm mode. once you exceed the threshold, it will grab a very short snippet of material and throw it into the delay. by default, the threshold is set to -12.0 db, but you can freely change it by visiting the params.

### singing and bird selection

press k2 and the bird will start singing a random birdsong based on its species repertoire. you can stop the singing by pressing k2 again. by moving e1 you can change the bird species and the corresponding birdsong. 

### mood

mood, which can be changed by turning e2, is simply bird's »feistiness«. the higher the mood value, the feistier the bird will act, resulting in more staccatto notes. moving the value downward, however, shall make the birdsong a bit calmer and longer.

### chirp

this is the general volume control of the bird

### bird info
![bird_info_gui](/assets/doc/bird_info.png)
each birdsong has its own description that will hopefully help you understand the wacky rate changes. you can initiate this by holding k1 and pressing k2.

## PARAMS

there are a couple of extra controls in the PARAMS section of norns. there you can change a couple of parameters, such as;

### birds
you can change the bird control values for your main bird (the one that is shown on the main screen) and friendly visitors (birds that you can call through garden mode).

`bird`: changes bird species

`level`: changes the volume of birdsong

`mood`: changes the feistiness

`position`: changes the bird panning

`distance`: alters the LPF cutoff frequency

### recording
change the recording threshold accordingly by default it's -12db.

### garden
![garden_gui](/assets/doc/garden_gui2.png)
garden is a place of gathering. you can call different bird species and place them in your »garden«. evoke garden mode in params or by pressing the key combo k1 + k3 on the main screen.

workflow suggestion: first, try to position the birds by visiting each friendly visitor in params and choosing their parameters (species, mood, distance, etc...). this way you shall have a more distinctive sonic picture when you finally call your birds to the garden. fine-tune them to taste once they start singing.

#### song density
lower density means a longer pause between songs, while higher density results in more chaotic behavior.

#### feed birds
this controls the handling of your recorded material. you can still record new material by pressing k3 in garden mode

`simultanious`:the recorded material is fed to each bird simultaneously.

`sequential`:the recorded material is fed to birds sequentially.

`random`:the recorded material is fed to a random visitor.

### forest 
here you can change the ambience file by loading your own enviroment. you can turn off the enviromental sounds by turning to "no" on the plant forest option.



## MESSIAEN COMMUNITY PROJECT
the goal here is to make messiaen a community-driven script, where users can catalogue birdcalls of different species or extend the library of already existing species present in the script. if you would like to transcribe new bird species for the script and add them to the library, then you can do so by following the guide in the birds library (--lib.), or by following my method of birdsong-to-rates transcription process.

### proposed methodology
please note that this is my own method of doing it and i don't doubt there are better or even easier ways of transcribing and automating the process. i've worked with what i had and hopefully will refine or completely change the method for the better in the future. however, if you feel like starting somewhere, you can by following this short basic guide.

#### know your birds
coming from a non-scientific background, i've spent quite some time studying birdcalls and reading on birdspecies that are present in this script. you can of course transcribe the birds quite easily by looking at a spectrogram and processing audio files, but i found that having some insight into the characteristics and nuances of birds and their song proves rewarding, as well as essential when you fine-tune the timbre and rate changes in softcut.

#### transcribing
various sources helped me with transcription, however my main method was using the 12-tet ntor formula in lua, which simply translates the SC rates to ratio of 12-tet intervals. using a mixture of izotope rx, melodyne and my ears i was able to transcribe the birdsong to a somewhat understandable notation and from there i moved to translating the results to SC rates in code.

slowing down the audio files can help with more complex birdsong such as eurasian blackbird or european robin.

_note: there is probably an easier way to transcribe these to rates and if you know a better method please let me know!_

#### code
there are some instructions in the birds.lua file that you can find in the lib folder. since, the current script is built around this method it is crucial to follow it in such a way. this might change in the future.

```
--[[

welcome to the bird tables
here you can add your own bird

1. add the <name> of your bird to the bird.names table.

2. create a table containing the birdsong parameters and bird name

bird.<name> = {}
bird.<name>.name = "<name>"
for i = 1, <number of birdsongs> do
  bird.<name>[i] = {}
end

use the following template where,
- r is rate
- d is duration
- pb is pitchbend
- ft is fade time

bird.NAME[i] = {
  {r = 0, d = 0.2, pb = 0, l = 0.5, ft = 0.2},   
  {r = 0, d = 0.2, pb = 0, l = 0.5, ft = 0.2},   
  {r = 0, d = 0.2, pb = 0, l = 0.5, ft = 0.2},   
  {r = 0, d = 0.2, pb = 0, l = 0.5, ft = 0.2}
}

]]--
```

### sharing
you can share the library either by opening an issue, stating which bird species and your github name, so i can properly credit you in any upcoming updates. gui illustration will also be provided from @mechtai

you can also get in touch with me via discord @fellowfinch 
or just join the server
https://discord.gg/KtqJGGDR

## CREDITS
* a lot of birdsong recordings used for transcription on this projects were taken from personal sound acrhive, Messiaen's own transcriptions and Adrian Thomas's RSPB Guide To Birdgsong
* script illustration were done by [@mechtai.](https://github.com/mech-tai)
* a huge thanks goes to [@sonocircuit](https://github.com/sonocircuit) for hours of time helping and mentoring in making this project alive
* to kind testers and helpful comments [@dndrks](https://github.com/dndrks), [@smonthms](https://github.com/smonthms), [@jaseknighter](https://github.com/jaseknighter)
* a big thank you to the support on lines community and sleep discord server

## REFERENCES
* Chadwick, R. Hill, P. Olivier Messiaen's Catalogue d'oiseaux From Conception to Performance, Cambridge University Press.
* Barnes, S. Bird Watching With Your Eyes Closed - An Introduction to Birdsong. Self Published.
* Ackerman, J. The Birdway - A New Look At How Birds Talk, Work, Play, Parent and Think. Penguin Press.
* Thomas, A. RSPB Guide to Birdsong. Blumsburry Wildlife
