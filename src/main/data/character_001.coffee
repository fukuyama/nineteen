
character =
  image: 'img/character_001.png'
  frame:
    width:  32
    height: 32
  animations:
    up:         {frames: [ 1, 2, 1, 0], next:   'up', frequency:8}
    down:       {frames: [19,20,19,18], next: 'down', frequency:8}
    left:       {frames: [ 6], frequency:8}
    right:      {frames: [12], frequency:8}
    up_left:    {frames: [ 3], frequency:8}
    up_right:   {frames: [15], frequency:8}
    down_left:  {frames: [ 9], frequency:8}
    down_right: {frames: [21], frequency:8}

module.exports = character
