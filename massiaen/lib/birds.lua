function play_birdsongs(bird)

    local songcount = 0
    while true do
      softcut.level(1, volume)
      local song = math.random(1, #bird)
      -- play notes
      for i = 1, #bird[song] do
        local current_note = bird[song][i]
        local rate = ntor(current_note.rate) * 3
        softcut.rate(1, rate)
        clock.sleep(current_note.duration)
      end
      softcut.level(1, 0)
      clock.sleep(math.random(1) + 0.2)
    end
  end


bird = {}

--wren
bird.wren = {}
for i = 1, 4 do
  bird.wren[i] = {}
end

bird.wren[1] = {
    {r = 6, d = 0.18},   
    {r = 3, d = 0.18},   
    {r = 1, d = 0.18},   
    {r = 11, d = 0.36}, }
bird.wren[2] = {
    {r = 3, d = 0.18},
    {r = 1, d = 0.18},
    {r = 11, d = 0.36},
    {r = 1, d = 0.18},
    {r = 2, d = 0.004},
    {r = 1, d = 0.09}, }
bird.wren[3] = {  
    {r = 1.5, d = 0.09},
    {r = 1, d = 0.09},
    {r = 1.5, d = 0.09},
    {r = 1, d = 0.09},
    {r = 1.5, d = 0.09},
    {r = 1, d = 0.09},
    {r = 1.5, d = 0.09},
    {r = 1, d = 0.09},
    {r = 1.5, d = 0.09},
    {r = 1, d = 0.09},
    {r = 1.5, d = 0.09},
    {r = 1, d = 0.09},
    {r = 1.5, d = 0.09},
    {r = 1, d = 0.09},
    {r = 1.5, d = 0.09},
    {r = 5, d = 0.36},
    {r = 6, d = 0.18},}
bird.wren[4]={  
    {r = 11, d = 0.18},
    {r = 1, d = 0.18}, 
    {r = 11, d = 0.18},
    {r = 1, d = 0.18}, 
    {r = 11, d = 0.18},
    {r = 1, d = 0.18}, 
    {r = 11, d = 0.18},
    {r = 1, d = 0.18}, 
    {r = 11, d = 0.18},
    {r = 1, d = 0.18}, 
    {r = 11, d = 0.18},
    {r = 1, d = 0.36},
    {r = (1)/2, d = 0.36}
  }

--european robin
bird.robin = {}
for i = 1, 3 do
  bird.robin[i] = {}
end

bird.robin[1] = {
    {r = 19, d = 0.105},
    {r = 17, d = 0.105},
    {r = 14, d = 0.105},
    {r = 12, d = 0.105},
    {r = 9, d = 0.105},
    {r = 7, d = 0.105},
    {r = 5, d = 0.105},
    {r = 2, d = 0.105},
    {r = 1, d = 0.215},
  }
bird.robin[2] = {
    {r = 14, d = 0.105},
    {r = 12, d = 0.435},
  }
bird.robin[3] = {
    {r = 1, d = 0.215},
  }

--song trush
bird.trush = {}
for i = 1, 5 do
  bird.trush[i] = {}
end
 
bird.trush[1] = {
    {r = 10, d = 0.05}
    {r = 4, d = 0.1},  
    {r = 13, d = 0.05},
    {r = 7, d = 0.1},
    {r = 15, d = 0.1},
  }
bird.trush[2] = {
    {r = 10, d = 0.05}, 
    {r = 4, d = 0.1}, 
    {r = 13, d = 0.05},
    {r = 7, d = 0.1},
    {r = 15, d = 0.1},
  }
bird.trush[3] = {
    {r = 7, d = 0.05},
    {r = 8, d = 0.05},
    {r = 14, d = 0.05},
    {r = 13, d = 0.05},
    {r = 12, d = 0.05},
    {r = 10, d = 0.05},
    {r = 9, d = 0.1},
  }
bird.trush[4]= {
    {r = 1, d = 0.05},
    {r = 7, d = 0.05},
    {r = 13, d = 0.05},
    {r = 14, d = 0.05},
    {r = 14, d = 0.1},
    {r = 1, d = 0.05}, 
    {r = 7, d = 0.05},
    {r = 13, d = 0.05},
    {r = 14, d = 0.05},
    {r = 14, d = 0.1},
  }
bird.trush[5] ={
    {r = 1, d = 0.1}
  }
  

 --nightingale
bird.gale = {}
for i = 1, 3 do
  bird.gale[i] = {}
end 

bird.gale[1] = {
    {r = 1, d = 0.20},
    {r = 12, d = 0.83},  
    {r = 7, d = 0.10},
    {r = 8, d = 0.20}, 
    {r = 1, d = 0.20},
    {r = 12, d =  0.83},
    {r = 7, d = 0.10},
    {r = 8, d = 0.10},
    {r = 10, d = 0.83},
    {r = (1)/2, d = 0.20}
  }

  bird.gale[2] = { 
    {r = 1, d = 0.20},
    {r = 12, d = 0.83},
    {r = 7, d = 0.10},   
    {r = 8, d = 0.20}, 
    {r = 1, d = 0.20},
    {r = 12, d =  0.83},
    {r = 7, d = 0.10},
    {r = 8, d = 0.10},
    {r = 10, d = 0.83},
    {r = (1)/2, d = 0.20}
  }

  bird.gale[3] = { 
    {r = 1, d = 0.20},
    {r = 12, d = 0.83},
    {r = 7, d = 0.10}, 
    {r = 8, d = 0.20}, 
    {r = 1, d = 0.20},
    {r = 12, d =  0.83},
    {r = 7, d = 0.10},
    {r = 8, d = 0.10},
    {r = 10, d = 0.83},
    {r = (1)/2, d = 0.20}
  }


--blackbird
bird.blackbird = {}
for i = 1, 4 do
  bird.blackbird[i] = {}
end 

bird.blackbird[1] = {
    {r = (11) + 12 , d = 0.052},
    {r = (11) + 12 , d = 0.052},
    {r = (11) + 12 , d = 0.052},
    {r = 4, d = 0.052},
    {r = (9) + 12 , d = 0.052},
    {r = (11) + 12 , d = 0.052},
    {r = 3, d = 0.052},
    {r = (9) + 12 , d = 0.052},
    {r = (13) + 12 , d = 0.052},
    {r = (10) + 12 , d = 0.052},
    {r = 1 , d = 0.052},}
bird.blackbird[2] = {  
    {r = 1 , d = 0.208},
    {r = (15) + 12 , d = 0.052},
    {r = (17) + 12 , d = 0.052},
    {r = (13) + 12 , d = 0.104}
  }
bird.blackbird[3] = {  
    {r = 1 , d = 0.208}
  }
bird.blackbird[4] = {
      {r = (9) + 12 , d = 0.052, pb = 0},
      {r = (11) + 12 , d = 0.052, pb = 0.3},
      {r = 3, d = 0.052},
      {r = (9) + 12 , d = 0.052, pb = 0},
      {r = (13) + 12 , d = 0.052, pb = 0.2},
      {r = (10) + 12 , d = 0.052, pb = 0},
      {r = 1 , d = 0.052, pb = 1},}
  
--chafinch
bird.finch = {}
for i = 1, 3 do
  bird.finch[i] = {}
end 

bird.finch[1] = {
    {r = 18, d = 0.025},
    {r = 0, d = 0.008},
    {r = 18, d = 0.025},
    {r = 0, d = 0.011},
    {r = 17, d = 0.020},
    {r = 0, d = 0.002},
    {r = 17, d = 0.015},
    {r = 0, d = 0.002},
    {r = 17, d = 0.012},
    {r = 0, d = 0.002},
    {r = 17, d = 0.010},
    {r = 0, d = 0.002},
    {r = 17, d = 0.050},
    {r = 12, d = 0.025},
    {r = 19, d = 0.025},
    {r = 0, d = 0.040},
    {r = 11, d = 0.020},
    {r = 0, d = 0.002},
    {r = 10, d = 0.015},
    {r = 0, d = 0.002},
    {r = 9, d = 0.012},
    {r = 0, d = 0.002},
    {r = 10, d = 0.020},
    {r = 0, d = 0.020},
    {r = 9, d = 0.025},
    {r = 0, d = 0.020},
    {r = 8, d = 0.030},
    {r = 7, d = 0.020},
    {r = 0, d = 0.020},
    {r = 1.5, d = 0.045},
  }

  bird.finch[2] = { -- needs change
    {r = 18, d = 0.025},
    {r = 0, d = 0.008},
    {r = 18, d = 0.025},
    {r = 0, d = 0.011},
    {r = 17, d = 0.020},
    {r = 0, d = 0.002},
    {r = 17, d = 0.015},
    {r = 0, d = 0.002},
    {r = 17, d = 0.012},
    {r = 0, d = 0.002},
    {r = 17, d = 0.010},
    {r = 0, d = 0.002},
    {r = 17, d = 0.050},
    {r = 12, d = 0.025},
    {r = 19, d = 0.025},
    {r = 0, d = 0.040},
    {r = 11, d = 0.020},
    {r = 0, d = 0.002},
    {r = 10, d = 0.015},
    {r = 0, d = 0.002},
    {r = 9, d = 0.012},
    {r = 0, d = 0.002},
    {r = 10, d = 0.020},
    {r = 0, d = 0.020},
    {r = 9, d = 0.025},
    {r = 0, d = 0.020},
    {r = 8, d = 0.030},
    {r = 7, d = 0.020},
    {r = 0, d = 0.020},
    {r = 1.5, d = 0.045},
  }

  bird.finch[3] = { -- needs change
    {r = 18, d = 0.025},
    {r = 0, d = 0.008},
    {r = 18, d = 0.025},
    {r = 0, d = 0.011},
    {r = 17, d = 0.020},
    {r = 0, d = 0.002},
    {r = 17, d = 0.015},
    {r = 0, d = 0.002},
    {r = 17, d = 0.012},
    {r = 0, d = 0.002},
    {r = 17, d = 0.010},
    {r = 0, d = 0.002},
    {r = 17, d = 0.050},
    {r = 12, d = 0.025},
    {r = 19, d = 0.025},
    {r = 0, d = 0.040},
    {r = 11, d = 0.020},
    {r = 0, d = 0.002},
    {r = 10, d = 0.015},
    {r = 0, d = 0.002},
    {r = 9, d = 0.012},
    {r = 0, d = 0.002},
    {r = 10, d = 0.020},
    {r = 0, d = 0.020},
    {r = 9, d = 0.025},
    {r = 0, d = 0.020},
    {r = 8, d = 0.030},
    {r = 7, d = 0.020},
    {r = 0, d = 0.020},
    {r = 1.5, d = 0.045},
  }

--great tit
bird.g_tit = {}
for i = 1, 3 do
  bird.g_tit[i] = {}
end 

bird.g_tit[1] = {
  {r = (6) + 12 , d = 0.52},
  {r = (1) + 12 , d = 0.52},
  {r = (6) + 12 , d = 0.52},
  {r = (1.2) + 12 , d = 0.52},
  {r = (6) + 12 , d = 0.52},
  {r = (6) + 12 , d = 0.52},
}
bird.g_tit[2] = {
  {r = (6) + 12 , d = 0.52},
  {r = 0 , d = 0.025}, 
  {r = (1.1) + 12 , d = 0.52},
  {r = 0 , d = 0.025}, 
  {r = (6) + 12 , d = 0.52},
  {r = 0 , d = 0.025}, 
  {r = (1.3) + 12 , d = 0.52},
  {r = 0 , d = 0.025}, 
  {r = (6.1) + 12 , d = 0.52},
  {r = 0 , d = 0.25}, 
  {r = (6) + 12 , d = 0.52},
}
bird.g_tit[3]= {
  {r = (6) + 12 , d = 0.25},
  {r = 0 , d = 0.25}, 
  {r = (6) + 12 , d = 0.25},
  {r = 0 , d = 0.025},
  {r = (9) + 12 , d = 0.25},
  {r = 0 , d = 0.025}, 
  {r = (6) + 12 , d = 0.25},
  {r = 0 , d = 0.025}, 
  {r = (9) + 12 , d = 0.25},
  {r = 0 , d = 0.025}, 
  {r = (6) + 12 , d = 0.25},
  {r = 0 , d = 0.025}, 
  {r = (9) + 12 , d = 0.25},
  {r = 0 , d = 0.025}, 
  {r = (6) + 12 , d = 0.25},
  {r = 0 , d = 0.25},
  {r = (6) + 12 , d = 0.25},
  {r = 0 , d = 0.025},
  {r = (9) + 12 , d = 0.25},
}

---- special birds ----
--needs extra work--


--awesome bird
bird.awesome = {}
for i = 1, 5 do
  bird.awesome[i] = {}
end 

bird.awesome[1] = {
    {r = 1, d = 1/8},
    {r = 7, d = 1/16},   
    {r = 12, d = 1/8},   
    {r = 1, d = 1/8}, 
    {r = 12, d = 1/4},
  }
bird.awesome[2] = {
    {r = 7, d = 1/8},
    {r = 1, d = 1/16},   
    {r = 12, d = 1/8},   
    {r = 4, d = 1/8}, 
    {r = 1, d = 1/4}
  }
bird.awesome[3] = {
    {r = 7, d = 1/32},
    {r = 1, d = 1/16},   
    {r = 7, d = 1/32},   
    {r = 12, d = 1/8}, 
    {r = 1, d = 1/4},
    {r = 7, d = 1/2},
    {r = 12, d = 1/16},
    {r = 4, d = 1/16},
    {r = 7, d = 1/24},
    {r = 12, d = 1/32},
    {r = 4, d = 1/8},
    {r = 1, d = 1/4},
  }
bird.awesome[4] = {
    {r = 1, d = 1/32},
    {r = 2, d = 1/32},   
    {r = 4, d = 1/32},   
    {r = 5, d = 1/32}, 
    {r = 7, d = 1/32},
    {r = 9, d = 1/32},
    {r = 11, d = 1/32},
    {r = 12, d = 1/32},
    {r = 1, d = 1/4},
    {r = 12, d = 1/32},
    {r = 11, d = 1/32},
    {r = 9, d = 1/32},
    {r = 7, d = 1/16},
    {r = 5, d = 1/8}, 
    {r = 4, d = 1/4},
    {r = 2, d = 1/2}, 
    {r = 1, d = 1/1},
  }
bird.awesome[5] = {
    {r = 1, d = 1/8},
    {r = 7, d = 1/16},   
    {r = 1, d = 1/8},   
    {r = 7, d = 1/8}, 
    {r = 12, d = 1/4}
  }

--weird bird
bird.weird = {}
for i = 1, 2 do
  bird.weird[i] = {}
end 

bird.weird[1] = {
    {r = math.random((12)+2 / 2), d = 1/4},
    {r = math.random((24)+2 / 2), d = 1/4},   
    {r = math.random((7)+3*2), d = 1/4},   
    {r = math.random((24)+2 / 2), d = 1/4}, 
    {r = math.random((12)+2 / 2), d = 1/4},
  }

  bird.weird[2] = {
    {r = math.random((12)+2 / 2), d = 1/4}, --needs change
    {r = math.random((24)+2 / 2), d = 1/4},   
    {r = math.random((7)+3*2), d = 1/4},   
    {r = math.random((24)+2 / 2), d = 1/4}, 
    {r = math.random((12)+2 / 2), d = 1/4},
  }
