#!/bin/bash
DIR="/home/fred/.local/share/pomo"
ROUNDS=0
TIMER=0
MODE=""
M=0
S=0

COLOR="" # luxafor color
TCOLOR="" # taskbar color

RED="#220000" # luxafor colors
GREEN="#002200"
BLUE="#000022"

TRED="#FF8888" # taskbar colors
TGREEN="#88FF88"
TBLUE="#8888FF"

# start sound
ogg123 -q $DIR/pomsfx/start-clock.ogg &

touch $DIR/time.txt

exit_fn() {
  trap SIGINT
  ogg123 -q $DIR/pomsfx/stop-clock.ogg &
  echo; echo "" > $DIR/time.txt
  exit
}

trap exit_fn EXIT

start_timer() {
  case $MODE in
    WORK)
      COLOR=$RED
      TCOLOR=$TRED
      ;;
    BREAK)
      COLOR=$GREEN
      TCOLOR=$TGREEN
      ;;
    REST)
      COLOR=$BLUE
      TCOLOR=$TBLUE
      ;;
  esac

  luxafor color -x "$COLOR"

  while [[ $TIMER > 0 ]]; do

    M=$((TIMER / 60))
    M=$((M % 60))

    S=$(( TIMER % 60 ))

    printf "<txt><span fgcolor='$TCOLOR'>\n%02d:%02d\n</span></txt>" $M $S > $DIR/time.txt

    sleep 1
    ((TIMER-=1))
  done

  TIMER=0
}

while true; do
  # set light to red and start timer

  MODE="WORK"
  TIMER=1500
  start_timer

  ((ROUNDS+=1))

  if [[ $ROUNDS < 4 ]]; then
    # set light to green and start break
    ogg123 -q $DIR/pomsfx/to-break.ogg &

    MODE="BREAK"
    TIMER=300
    start_timer
  else
    # set light to blue and start long break
    ogg123 -q $DIR/pomsfx/to-rest.ogg &

    MODE="REST"
    TIMER=900
    start_timer

    ROUNDS=0
  fi

  ogg123 -q $DIR/pomsfx/to-session.ogg &
done

