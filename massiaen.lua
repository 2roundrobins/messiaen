--- massiaen v0.1 @fellowfinch
--- llllllll.co/t/url
--- 
---
--- the birds love you!
---
---
---  ▼ instructions below ▼
---
--- E1 change that bird!
--- E2 chirp size
--- E3 chirp volume
---
--- K1 forest me up!
--- K2 it sings
--- K3 it listens (!)
---
--- show the bird what you got
--- by playing some shit into 
--- the buffer (press k3). 
--- it listens (!)
--- enough listening! 
--- make it sing by pressing k2.
--- 

--libs 
Lattice = require ("lattice") -- clock for the randomization paterning 
s = require("sequins") -- the sequence at which the randomization changes

-- VARIABLES
local play_bird = 1
local freeze = 0.3
local loop_start = 0
local loop_end = 0.02
local slew = 0.1
local pan_aut = false
local pos = 1
local brd_change = "wren" -- default, so it always start on wren
local sc = softcut
local rec = 2
local tog = 0
local activate = 0
local low = 1700
local hi = 800
local volume = 0
local rev = 0.3
local display_note = false 
local display_exl = false
local file_lenght = 170
local isPlaying = false
local active_bird = 1 -- active bird is strictly a VALUE as it is used in the rand_bird() functions


--Key combos
local k1_pressed = false
local k2_pressed = false


--files
file = _path.code.."/01mystuff/01brd/robinwren.wav"

--clock table for birds
-- this is basically so it can be canceled by calling the function clock.cancel(ids[current_bird]) that is now hooked up to the Toggle of K2
ids = {}
ids["wren"] = clock.run
ids["robin"]= clock.run
ids["trush"] = clock.run
ids["nightingale"] = clock.run
ids["blackbird"] = clock.run
ids["redstart"] = clock.run
ids["awesomebird"] = clock.run
ids["weird"] = clock.run


--bird table
-- here you can add it in the future as it is the current_bird
--difference between current bird is that current bird looks for a STRING while active_bird looks for a VALUE
birds = {"wren", "robin", "blackbird", "trush", "redstart", "nightingale", "awesomebird", "weird"}

--sequins 
pat1_div_seq = s{1/2,1/2} -- how quickly will the bird change, currently the only one active
--pat2_div_seq = s{1/4,1/8,1/2}
--pat2_rate_seq = s{4,-4,2,-2,s{4,3,2,1,-1,-2,-3,-4}}

-- Init
function init()
  softcut.buffer_clear()
  softcut.enable(1, 1)
  softcut.buffer(1, 1)
  softcut.level(1, 0)
  softcut.rate(1, 1.0)
  softcut.loop(1, 1)
  softcut.loop_start(1, loop_start)
  softcut.loop_end(1, loop_end)
  softcut.position(1, 0)
  softcut.play(1, 1)
  softcut.fade_time(1, 0.2)
  
  --SLEW
  sc.rate_slew_time (1, slew)
  
  --PAN
  sc.pan(1, 0)
  
  --FILTERS
  softcut.pre_filter_dry(1,0.0)
  softcut.pre_filter_lp(1,1.0)
  softcut.pre_filter_fc(1,low)
  softcut.pre_filter_rq(1,10)

--AUDIO IN
  audio.level_adc_cut(1)
  softcut.level_input_cut(1, 1, 1.0)
  softcut.level_input_cut(2, 1, 1.0)
  
--SC RECORD
  softcut.rec_level(1, rec)
  softcut.pre_level(1, freeze)
  softcut.rec(1, 0)
  
  -- eng
  audio.level_eng_cut(rev)
  audio.level_tape_cut(0)
  
  
  --playback buffer
  softcut.buffer_clear()
  softcut.enable(2, 1)
  softcut.buffer(2, 1)
  softcut.level(2, 0.1)
  softcut.rate(2, 1)
  softcut.loop(2, 1)
  softcut.loop_start(2, 0)
  softcut.loop_end(2, file_lenght)
  softcut.position(2, 1)
  softcut.play(2, 0)
  softcut.fade_time(2, 2)
  softcut.buffer_read_stereo(file, 0,1,-1,2,2)
  
  --other init
  init_lattice()
  --lat:start()

end


-- BIRDS
-- Bird song transcription with duration

--NIGHTING GALE
gale_as1 = {
  {rate = 1, duration = 0.20},--eight
  {rate = 12, duration = 0.83},--half  
  {rate = 7, duration = 0.10}, --sixteen  
  {rate = 8, duration = 0.20}, 
  {rate = 1, duration = 0.20},
  {rate = 12, duration =  0.83},
  {rate = 7, duration = 0.10},
  {rate = 8, duration = 0.10},
  {rate = 10, duration = 0.83},
  {rate = (1)/2, duration = 0.20}
}

--EUROPEAN ROBIN
robin_as1 = {
  {rate = 19, duration = 0.105},
  {rate = 17, duration = 0.105},
  {rate = 14, duration = 0.105},
  {rate = 12, duration = 0.105},
  {rate = 9, duration = 0.105},
  {rate = 7, duration = 0.105},
  {rate = 5, duration = 0.105},
  {rate = 2, duration = 0.105},
  {rate = 1, duration = 0.215},
}
robin_as2 = {
  {rate = 14, duration = 0.105},
  {rate = 12, duration = 0.435},
}
robin_as3 = {
  {rate = 1, duration = 0.215},
}

--EUROASIAN WREN
wren_as1 = {
  {rate = 6, duration = 0.18},   
  {rate = 3, duration = 0.18},   
  {rate = 1, duration = 0.18},   
  {rate = 11, duration = 0.36}, }
wren_as2 = {
  {rate = 3, duration = 0.18},
  {rate = 1, duration = 0.18},
  {rate = 11, duration = 0.36},
  {rate = 1, duration = 0.18},
  {rate = 2, duration = 0.004},
  {rate = 1, duration = 0.09}, }
wren_as3 = {  
  {rate = 1.5, duration = 0.09},
  {rate = 1, duration = 0.09},
  {rate = 1.5, duration = 0.09},
  {rate = 1, duration = 0.09},
  {rate = 1.5, duration = 0.09},
  {rate = 1, duration = 0.09},
  {rate = 1.5, duration = 0.09},
  {rate = 1, duration = 0.09},
  {rate = 1.5, duration = 0.09},
  {rate = 1, duration = 0.09},
  {rate = 1.5, duration = 0.09},
  {rate = 1, duration = 0.09},
  {rate = 1.5, duration = 0.09},
  {rate = 1, duration = 0.09},
  {rate = 1.5, duration = 0.09},
  {rate = 5, duration = 0.36},
  {rate = 6, duration = 0.18},}
wren_as4 ={  
  {rate = 11, duration = 0.18},
  {rate = 1, duration = 0.18}, 
  {rate = 11, duration = 0.18},
  {rate = 1, duration = 0.18}, 
  {rate = 11, duration = 0.18},
  {rate = 1, duration = 0.18}, 
  {rate = 11, duration = 0.18},
  {rate = 1, duration = 0.18}, 
  {rate = 11, duration = 0.18},
  {rate = 1, duration = 0.18}, 
  {rate = 11, duration = 0.18},
  {rate = 1, duration = 0.36},
  {rate = (1)/2, duration = 0.36}
}
--SONG TRUSH
trush_as1 = {
  {rate = 10, duration = 0.05}, --grace note
  {rate = 4, duration = 0.1},  --sixteenth
  {rate = 13, duration = 0.05},
  {rate = 7, duration = 0.1},
  {rate = 15, duration = 0.1},
}
trush_as2 = {
  {rate = 10, duration = 0.05}, --grace note
  {rate = 4, duration = 0.1},  --sixteenth
  {rate = 13, duration = 0.05},
  {rate = 7, duration = 0.1},
  {rate = 15, duration = 0.1},
}
trush_as3 = {
  {rate = 7, duration = 0.05},  --32th
  {rate = 8, duration = 0.05},
  {rate = 14, duration = 0.05},
  {rate = 13, duration = 0.05},
  {rate = 12, duration = 0.05},
  {rate = 10, duration = 0.05},
  {rate = 9, duration = 0.1},
}
trush_as4 = {
  {rate = 1, duration = 0.05},  --32th
  {rate = 7, duration = 0.05},
  {rate = 13, duration = 0.05},
  {rate = 14, duration = 0.05},
  {rate = 14, duration = 0.1},
  {rate = 1, duration = 0.05},  --32th
  {rate = 7, duration = 0.05},
  {rate = 13, duration = 0.05},
  {rate = 14, duration = 0.05},
  {rate = 14, duration = 0.1},
}
trush_as5 ={
  {rate = 1, duration = 0.1}
}

--COMMON REDSTART
redstart_as1 = {
  {rate = 15, duration = 0.17},--eight
  {rate = 11, duration = 0.09},--sixtenth
  {rate = 9, duration = 0.17} }
redstart_as2 = {  
  {rate = 12, duration = 0.04},
  {rate = 10, duration = 0.04},
  {rate = 3, duration = 0.04},
  {rate = 8, duration = 0.04},
  {rate = 13, duration = 0.04},
  {rate = 2, duration = 0.04},
  {rate = 1, duration = 0.04},
  {rate = 8, duration = 0.09} 
}
redstart_as3 = {  
  {rate = 1, duration = 0.04}}
  
--BLACKBIRD
blackbird_as1 = {
  {rate = (11) + 12 , duration = 0.052},--32
  {rate = (11) + 12 , duration = 0.052},
  {rate = (11) + 12 , duration = 0.052},
  {rate = 4, duration = 0.052},
  {rate = (9) + 12 , duration = 0.052},
  {rate = (11) + 12 , duration = 0.052},
  {rate = 3, duration = 0.052},
  {rate = (9) + 12 , duration = 0.052},
  {rate = (13) + 12 , duration = 0.052},
  {rate = (10) + 12 , duration = 0.052},
  {rate = 1 , duration = 0.052},}
blackbird_as2 = {  
  {rate = 1 , duration = 0.208},--eight
  {rate = (15) + 12 , duration = 0.052},--eight
  {rate = (17) + 12 , duration = 0.052},
  {rate = (13) + 12 , duration = 0.104}
}
blackbird_as3 = {  
  {rate = 1 , duration = 0.208}
}--eight

--AWESOME BIRD
-- should behave based on scale
awesome_1 = {
    {rate = 1, duration = 1/8},
    {rate = 7, duration = 1/16},   
    {rate = 12, duration = 1/8},   
    {rate = 1, duration = 1/8}, 
    {rate = 12, duration = 1/4},
  }
  awesome_2 = {
    {rate = 7, duration = 1/8},
    {rate = 1, duration = 1/16},   
    {rate = 12, duration = 1/8},   
    {rate = 4, duration = 1/8}, 
    {rate = 1, duration = 1/4}
  }
  awesome_3 = {
    {rate = 7, duration = 1/32},
    {rate = 1, duration = 1/16},   
    {rate = 7, duration = 1/32},   
    {rate = 12, duration = 1/8}, 
    {rate = 1, duration = 1/4},
    {rate = 7, duration = 1/2},
    {rate = 12, duration = 1/16},
    {rate = 4, duration = 1/16},
    {rate = 7, duration = 1/24},
    {rate = 12, duration = 1/32},
    {rate = 4, duration = 1/8},
    {rate = 1, duration = 1/4},
  }
  awesome_4 = {
    {rate = 1, duration = 1/32},
    {rate = 2, duration = 1/32},   
    {rate = 4, duration = 1/32},   
    {rate = 5, duration = 1/32}, 
    {rate = 7, duration = 1/32},
    {rate = 9, duration = 1/32},
    {rate = 11, duration = 1/32},
    {rate = 12, duration = 1/32},
    {rate = 1, duration = 1/4},
    {rate = 12, duration = 1/32},
    {rate = 11, duration = 1/32},
    {rate = 9, duration = 1/32},
    {rate = 7, duration = 1/16},
    {rate = 5, duration = 1/8}, 
    {rate = 4, duration = 1/4},
    {rate = 2, duration = 1/2}, 
    {rate = 1, duration = 1/1},
  }
  awesome_5 = {
    {rate = 1, duration = 1/8},
    {rate = 7, duration = 1/16},   
    {rate = 1, duration = 1/8},   
    {rate = 7, duration = 1/8}, 
    {rate = 12, duration = 1/4}
  }
  
  --WEIRD BIRD
  -- should behave based on scale
  weird = {
    {rate = math.random((12)+2 / 2), duration = 1/4},
    {rate = math.random((24)+2 / 2), duration = 1/4},   
    {rate = math.random((7)+3*2), duration = 1/4},   
    {rate = math.random((24)+2 / 2), duration = 1/4}, 
    {rate = math.random((12)+2 / 2), duration = 1/4},
  }
  

---OTHER FUNCTIONS-------OTHER FUNCTIONS----


--auto pan
function pan_aut()
  if pan_aut == not pan_aut then
    for i = 1,#robin_song_as() do
      sc.pan(1,pan_aut)
    end
  end
end

-- 12TET
function ntor(n)
  return math.pow(2, n / 12)
end

-- Pause
function pause()
  if display_note then
    display_note = false
    redraw()
  end
  sc.level(1, 0)
  clock.sleep(math.random(1) + 0.2)
  sc.level(1, volume)
  print("pause")
  display_note = true
  redraw()
end

--long pause
function pause_l()
  if display_note then
    display_note = false
    redraw()
  end
  sc.level(1, 0)
  clock.sleep(250)
  sc.level(1, volume)
  print("pause")
end

--Playback atmo
function atmo(play)
  if play then
    sc.play(2,1)
  else
    sc.play(2,0)
  end
end

-- play note functions, just so it plays notes from a given table
function play_notes(table)
    for i = 1, #table do
      local current_note = table[i]
      local rate = ntor(current_note.rate) * 3
      sc.rate(1, rate)
      clock.sleep(current_note.duration)
      print(i)
    end
  end

--RANDOMS SEQUENCE for birds
--randomize function -- currently just for wren
function generate_random_sequence()
  local sequence = {wren_as1, wren_as2, wren_as3, wren_as4}
  for i = 1, #sequence do -- loop throught the elements
    local random_index = math.random(i) -- picks a random number
    sequence[i], sequence[random_index] = sequence[random_index], sequence[i] -- swaping the current element with random positions
  end
  return sequence -- give us the sequense
end

--BIRD FUNCTIONS!
function wren_song_as()
  while true do
  sc.level(1,volume)
  local sequence = generate_random_sequence()
    for i = 1, #sequence do
     play_notes(sequence[i])
     pause()
    end
    end
--pause_l()
end

function wren_song_as2()
  while true do
    sc.level(1,volume)
    play_notes(wren_as1)
    pause()
    play_notes(wren_as2)
    pause()
    play_notes(wren_as3)
    pause()
    play_notes(wren_as4)
    --pause_l()
  end
end

function robin_song_as()
  while true do
    sc.level(1,volume)
    play_notes(robin_as1)
    pause()
    play_notes(robin_as2)
    pause()
    play_notes(robin_as3)
    pause()
  end
end

function trush_song_as()
  while true do
  sc.level(1,volume)
  play_notes(trush_as1)
  pause()
  play_notes(trush_as2)
  pause()
  play_notes(trush_as3)
  pause()
  play_notes(trush_as4)
  pause()
  play_notes(trush_as5)
  pause()
  end
end

function redstart_song_as()
  while true do
  sc.level(1,volume)
  play_notes(redstart_as1)
  pause()
  play_notes(redstart_as2)
  pause()
  play_notes(redstart_as3)
  pause()
  end
end

function blackbird_song_as()
  while true do
    sc.level(1,volume)
    play_notes(blackbird_as1)
    pause()
    play_notes(blackbird_as2)
    pause()
    play_notes(blackbird_as3)
    pause()
  end
end

function nightingale_song_as()
  while true do
  sc.level(1,volume)
  play_notes(gale_as1)
  pause_l()
  end
end

--other birds

function awesomebird_song()
  while true do
  sc.level(1,volume)
  play_notes(awesome_1)
  pause()
  play_notes(awesome_2)
  pause()
  play_notes(awesome_3)
  pause()
  play_notes(awesome_4)
  pause()
  play_notes(awesome_5)
  --pause_l()
  end
end

function weird_song()
  while true do
play_notes(weird)
  pause()
  end
end
  
-- ENCODERS
function enc(n, d)
  local loop_size = 0.1
  if n == 2 then
    --params:delta("loop_start", d * 0.01)
    loop_size = util.clamp(loop_size + d * 0.01, 0.01, 3)
    loop_start = util.clamp(loop_start + d * 0.01, 0, loop_end - loop_size)
    loop_end = util.clamp(loop_end + d * 0.01, loop_start + loop_size, 3)
    sc.loop_start(1, loop_start)
    sc.loop_end(1, loop_end)
    print("Loop size:", loop_size)
    print("Loop start:", loop_start)
    print("Loop end:", loop_end)
  elseif n == 3 then
    volume = util.clamp(volume + d / 100, 0, 1) -- Adjust the range for finer control
    print(string.format("Volume: %.2f", volume))
    sc.level(1, volume)
  elseif n == 1 then
    active_bird = util.clamp(active_bird + d, 1, #birds) -- Adjust the range as needed
    brd_change = birds[active_bird]
    print("brd:", brd_change,d,active_bird)
  end
  redraw()
end


-- KEYS
-- TOGGLES HERE
function key(n, z)
  if n==2 and z == 1 then
      if play_bird == 1 then
        play_bird = 0
        print("play")
      if current_bird == "wren" then
        ids["wren"] = clock.run(wren_song_as)
        display_note = true
        display_exl = false
      elseif current_bird == "robin" then
        ids["robin"] = clock.run(robin_song_as)
        display_note = true
        display_exl = false
      elseif current_bird == "trush" then
        ids["trush"] = clock.run(trush_song_as)
        display_note = true
        display_exl = false
      elseif current_bird == "redstart" then
        ids["redstart"] = clock.run(redstart_song_as)
        display_note = true
        display_exl = false
      elseif current_bird == "blackbird" then
        ids["blackbird"] = clock.run(blackbird_song_as)
        display_note = true
        display_exl = false
      elseif current_bird == "nightingale" then
         ids["nightingale"] = clock.run(nightingale_song_as)
        display_note = true
        display_exl = false
      elseif current_bird == "awesomebird" then
        ids["awesomebird"] = clock.run(awesome_song_as)
        display_exl = false
        --clock.run(awesomebird_song)
      elseif current_bird == "weird" then
        id["weird"] = clock.run(current_bird)
        display_exl = false
    end
      else
        play_bird = 1
        clock.cancel(ids[current_bird])
        print("cancel")
      end
    redraw()
   elseif n == 3 and z == 1 then
    if k1_pressed and k2_pressed then
      sc.buffer_clear()
    else
      sc.rec(1, 1)
      if freeze == 1 then
        freeze = 0
        softcut.pre_level(1, freeze)
        sc.level(1, 0)
        sc.fade_time(1, 0.5)
        display_note = false
        display_exl = true
      else
        freeze = 1
        sc.rec(1, 0)
        sc.fade_time(1, 0.2)
        display_note = false
        display_exl = false
      end
      print(freeze)
      redraw()
    end
   elseif n==1 and z==1 then
      if isPlaying then
      -- Stop playing
      softcut.play(2, 0)
      isPlaying = false
      atmo(false)
    else
      softcut.play(2, 1)
      isPlaying = true
      atmo(true) -- Start the second buffer
    end
      print("play atmo")
      redraw()
    end
end

-- CHOIR ---- CHOIR ---- CHOIR --
-- CHOIR ---- CHOIR ---- CHOIR --
-- random function meant to create a choir by randomly changing the birds 
-- active_bird is a variable and therefore the math.random is searching for these variables for the lenght of the birds table (#birds)
-- brd_change is a variable that starts with our default bird (wren) and then is based on whatever the next active_bird is 
-- this is then used in the redraw function and the encoder function

--stores all the clock functions
function store()
  wren_song_as()
  robin_song_as()
  trush_song_as()
  blackbird_song_as()
  redstart_song_as()
  nightingale_song_as()
end


function all() -- starts all the clocks...but doesn't?
  lat:start()
  rand_bird()
end
  
  
--------------------------------------  
function random_play()
  if current_bird == current_bird then
      --ids[current_bird] = clock.run(current_bird)
      clock.run(wren_song_as)
      print("play")
  elseif active_bird ~= active_bird then
    clock.cancel(ids)
    print("cancel")
  end
  redraw()
end
--------------------------------------

function rando()
  if current_bird == "wren" then
        ids["wren"] = clock.run(wren_song_as)
        display_note = true
        display_exl = false
      elseif current_bird == "robin" then
        ids["robin"] = clock.run(robin_song_as)
        display_note = true
        display_exl = false
      elseif current_bird == "trush" then
        ids["trush"] = clock.run(trush_song_as)
        display_note = true
        display_exl = false
      elseif current_bird == "redstart" then
        ids["redstart"] = clock.run(redstart_song_as)
        display_note = true
        display_exl = false
      elseif current_bird == "blackbird" then
        ids["blackbird"] = clock.run(blackbird_song_as)
        display_note = true
        display_exl = false
      elseif current_bird == "nightingale" then
         ids["nightingale"] = clock.run(nightingale_song_as)
        display_note = true
        display_exl = false
    elseif current_bird ~= current_bird then
      clock.cancel(ids[current_bird])
    end
end
    


function cancel_all() -- stops the sequence and clocks
  clock.cancel(active_bird)
  lat:stop()
end

function rand_bird() -- choses a random bird
    active_bird = math.random(#birds)
    brd_change = birds[active_bird]
    rando()
    redraw()
end

function away() -- whatever the current bird is  #birds it will cancecl the clock using the ids
  if play_bird == 1 then
    play_bird = 1
    elseif current_bird == current_bird then
    clock.cancel(ids[current_bird])
  end
end


  -- function for changing the bird
  -- the function looks for the argument "brd_name" so it looks what arguments occupies and then changes it to that argument
  function change_bird(brd_name)
      if brd_name == "wren" then
        current_bird = "wren"
        active_bird = 1
      elseif brd_name == "blackbird" then
        current_bird = "blackbird"
         active_bird = 2
       elseif brd_name == "nightingale" then
        current_bird = "nightingale"
         active_bird = 3
        elseif brd_name == "redstart" then
        current_bird = "redstart"
         active_bird = 4
        elseif brd_name == "trush" then
        current_bird = "trush"
         active_bird = 5
        elseif brd_name == "robin" then
        current_bird = "robin"
         active_bird = 6
        elseif brd_name == "blackbird" then
        current_bird = "blackbird"
         active_bird = 7
        elseif brd_name == "awesomebird" then
        current_bird = "awesomebird"
        active_bird = 8 
        elseif brd_name == "weird" then
        current_bird = "weird"
         active_bird = 9
      end
    redraw()
    end
    
  -- LATTICE 
  -- function to start the lattice occupied by one sprocket which calls for the function rand_bird() and sets the division of change
  function init_lattice()
    lat = Lattice:new{
      auto = true, --its a master clock
      meter = 4,
      ppqn = 96 -- pusles per quarter note
    }
  
    random_bird_time = lat:new_sprocket{
      action = function(t) 
       rand_bird() 
       random_bird_time:set_division(pat1_div_seq())
      end,
      division = 1,
      enabled = true
    }
    
  end
  

-- GUI
function redraw()
  screen.clear()
  screen.move(10, 50)
  screen.text("pos: ")
  screen.move(118, 50)
  screen.text_right(string.format("%.1f", loop_start))
  screen.move(10, 60)
  screen.text("volume: ")
  screen.move(118, 60)
  screen.text_right(string.format("%.2f", volume))
   if brd_change == "weird" then
    screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/weird1.png", 38, 18)
    screen.move(65, 10)
    screen.text_center("weird boi")
    current_bird = "weird"
  elseif brd_change == "awesomebird" then
    screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/awesome1.png", 38, 18)
    screen.move(65, 10)
    screen.text_center("good boi")
    current_bird = "awesomebird"
  elseif brd_change =="redstart" then
    screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/redstart1.png", 38, 18)
    screen.move(65, 10)
    screen.text_center("common redstart")
    current_bird = "redstart"
  elseif brd_change == "trush" then
    screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/trush1.png", 38, 18)
    screen.move(65, 10)
    screen.text_center("song thrush")
    current_bird = "trush"
  elseif brd_change == "robin" then
    screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/robin1.png", 38, 20)
    screen.move(65, 10)
    screen.text_center("european robin")
    current_bird = "robin"
  elseif brd_change =="nightingale" then
    screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/gale1.png", 38, 20)
    screen.move(65, 10)
    screen.text_center("nightingale")
    current_bird = "nightingale"
  elseif brd_change == "blackbird" then
    screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/blackbird1.png", 38, 18)
    screen.move(65, 10)
    screen.text_center("euroasian blackbird")
    current_bird = "blackbird"
  elseif brd_change == "wren" then --- this is new use it at every brd change!
    screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/wren1.png", 38, 20)
    screen.move(65, 10)
    screen.text_center("euroasian wren")
    current_bird = "wren"
  end
  if display_note then
    screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/note.png", 90, 20)
  end
  if display_exl then
    screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/exl.png", 90, 20)
  end
  screen.update()
  print(current_bird)
end


--PARAMS
--BEWARE!!! only as proof of concept!
--must do a redo! otherwise shit might get fucked up when updating norns!!!
params:add_separator("bird_control", "bird control")

--filt
params:add_separator("cave", "cave")
params:add_control("cutoff", "filter cutoff", controlspec.new(20, 20000, 'exp', 0, 17000, "Hz"))
params:set_action("cutoff", function(x) softcut.pre_filter_fc(1, x) end)
params:add_control("level_eng_cut", "reverb", controlspec.new(0, 1, 'lin', 0, rev, "db"))
params:set_action("level_eng_cut", function(x) audio.level_eng_cut(rev) end)
--loopsize
params:add_separator("chirp_material", "chirp material")
params:add_control("loop_start", "loop start", controlspec.new(0, 4, 'lin', 0.01, 0, "sec")) -- I'll need to add params:delta 
params:set_action("loop_start", function(x) softcut.loop_start(1, x) params:set("loop_end", loop_start + loop_end) end)

params:add_control("loop_end", "loop end", controlspec.new(0.1, 4.1, 'lin', 0.01, 0.02, "sec"))
params:set_action("loop_end", function(x) softcut.loop_end(1, x) end)
--ambience
params:add_separator("forest", "forest")
params:add_file("append_file", ">> plant forest", "")
params:set_action("append_file", function(path) load_splice(path) end) -- must add function to load file
params:add_control("level", "level", controlspec.new(0, 1, 'lin', 0.1, 0.5, "db")) -- I'll need to add params:delta 
params:set_action("level", function(x) softcut.level(2, x) end)
params:add_control("cutoff", "filter cutoff", controlspec.new(20, 20000, 'exp', 0, 20000, "Hz"))
params:set_action("cutoff", function(x) softcut.pre_filter_fc(2, x) end)

params:add_separator("bird", "bird")
params:add_option("current_bird", "current bird", {"wren", "blackbird", "nightin gale", "robin", "song trush", "awesome boi", "weird boi"}, 1)
--need to set action!!!
params:add_group("birds_params", "nest", 11)
params:add_separator("bird", "bird")
params:add_option("wren", "wren", {"yes", "no"}, 1)
params:add_option("blackbird", "blackbird", {"yes", "no"}, 1)
params:add_option("nightin gale", "nightin gale", {"yes", "no"}, 1)
params:add_option("robin", "robin", {"yes", "no"}, 1)
params:add_option("song trush", "song trush", {"yes", "no"}, 1)
params:add_option("awesome boi", "awesome boi", {"yes", "no"}, 1)
params:add_option("wierd boi", "weird boi", {"yes", "no"}, 1)
--choir options
params:add_separator("choir", "choir")
params:add_option("bird_choir", "choir", {"yes", "no"}, 1)
params:add_control("change_duration", "time", controlspec.new(0, 2, 'lin', 0.01, 0.0, "sec"))
