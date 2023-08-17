#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guessing_game -t --no-align -c"
SECRET_NUM=$(( $RANDOM % 1000 + 1 ))

echo -e "\n~~~~~ Number Guessing Game ~~~~~\n"

echo -e "\nEnter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

if [[ $USER_ID ]]
then
  # get users stats
  GAMES_PLAYED=$($PSQL "SELECT count(user_id) FROM games WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT min(guesses) FROM games WHERE user_id = $USER_ID")

  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
fi

echo -e "\nGuess the secret number between 1 and 1000:"
NUM_GUESSES=0
GUESSED=0

while [[ $GUESSED = 0 ]]
do

  read GUESS

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
  elif [[ $SECRET_NUM = $GUESS ]]
  then
    NUM_GUESSES=$(($NUM_GUESSES + 1))
    echo -e "\nYou guessed it in $NUM_GUESSES tries. The secret number was $SECRET_NUM. Nice job!"
    INSERTED_TO_GAMES=$($PSQL "INSERT INTO games(user_id, guesses) values($USER_ID, $NUM_GUESSES)")
    GUESSED=1
  elif [[ $SECRET_NUM -gt $GUESS  ]]
  then
    NUM_GUESSES=$(($NUM_GUESSES + 1))
    echo -e "\nIt's higher than that, guess again:"
  else
    NUM_GUESSES=$(($NUM_GUESSES + 1))
    echo -e "\nIt's lower than that, guess again:"
  fi
done

