# Roolio

> Learn board games with Roolibo by your side.

Roolio is an iOS board game learning app, paired with **Roolibo**, a physical NFC figurine that serves as the character guide throughout the experience.

Built with SwiftUI in Xcode, Roolio helps players learn physical board games through guided setup, turn reminders, and on-demand rules assistance. The first supported game is **Splendor**.

## Meet Roolibo

Roolibo is our physical NFC figurine and the character at the heart of the learning experience.

Players tap their phone against Roolibo to access the assistant in Roolio, where they can type a question, use voice input, or take a photo to ask about a card or game situation.

## Game Flow

1. **Join a room:** The host creates a room, and everyone else joins with a room code or QR code. The host can start directly; other players see **Waiting for the host**.
2. **Set up the game:** Roolibo guides players through an optional setup tutorial.
3. **Decide who goes first:** Everyone rolls a virtual die. The highest roll starts, with tied players rolling again. This is a custom starting method for the app.
4. **Follow your turn:** Players see **Your Turn** or **Waiting for Your Turn**, along with a timer and a preview of what they can do next.
5. **Tap Roolibo for help:** Tap the NFC figurine with a phone to access text, voice, or photo questions in Roolio. Players can also request to end the game, subject to host confirmation.
6. **Celebrate:** After final scores are confirmed, Roolibo celebrates the winner with an animation in the app.

## Interface

The tutorial is character-led, with Roolibo introducing each step through short, friendly messages.

- One clear primary button at the bottom of each screen.
- Secondary actions such as **Skip Setup** remain easy to find.
- An in-app Roolibo button also provides access to help.
- **End My Turn** and **End Game** are clearly separated.
- Ending the game requires confirmation.

## MVP

- Room creation and joining
- Player and turn synchronization
- Optional Splendor setup tutorial
- Virtual dice and turn order
- Turn status and timer
- NFC entry to the Roolibo assistant
- Text-based rules questions
- Manual score entry and winner animation

Voice input and photo questions are planned for later versions.

Players manage the physical board and manually end their turns. The first version does not automatically track cards, validate moves, or calculate scores.

## Development

- **Platform:** iOS/web prototype
- **Tools:** Xcode and SwiftUI
- **NFC:** evaluate supported tag formats and iPhone tap-to-open behavior during prototyping
- **Backend:** room membership, host permissions, and turn synchronization
- **Assistant:** backend AI integration grounded in curated game rules
- **Content:** structured tutorials that can expand to additional board games
