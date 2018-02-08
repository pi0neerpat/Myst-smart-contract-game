# Myst-smart-contract-game

# Purpose

Create a real-life adventure game platform.
Contribute to the blockchain and smart-contract knowledge-base.

# Description

A combination of Blockchain, Geocaching, and The Amazing Race. Games can be created by anyone, and are open to all. Entry fees are used to fund prizes. The description and rules are public, however the specific description and resulting clues are only accessible to participants. Clues are released on a timed schedule.  If the game is not won or enough prize money is not raised, then participants are refunded all fees.

# Inputs:

>>Formalities (public, optional)

Game host contact info (e.g., name, email, social media profile)


>>Description (public, required)

Location-fuzzy (e.g., Los Angeles, CA)

Description-fuzzy (e.g., A small capsule is hidden in a public place in the hills of LA)


>>Rules (public, required)

Entry period (e.g., unlimited, or signups stopped after 3 days)

Entry fee (e.g., 0.01 ETH)

Minimum prize (e.g., game will be canceled and refunded if a large enough prize is not raised)

Game time start (e.g., immediate, a specific date, or once a certain number of participants is reached) 

Game time length (e.g., If not won in 30 days participants are refunded)

Number of clues (e.g, 2)

Clue release (e.g., every 5 days once the game has begun)


>>Clues (private to participants only, required)

Description-specific (e.g., Seek your reward where heavenly bodies make their way into the hearts of many. Yet the treasure you seek is of Earthly goods and thus can only be found by the gazing glass eye.)

Clue1,2,3,...etc. (e.g., telescope)

Answer (e.g., its at [xxxxxxx] behind the [xxxxxxxx])


# Outputs:

Outcome (e.g., game won, or game failed due to timeout or minimum prize not met)

Prize money (e.g., Sent to the first participant who sends the correct message to the contract)

Answer (e.g., same as above- only revealed when game won)


# Difficulties:

TBD


# Major components:

Smart-contract

Front-end UI hosted on a web-page