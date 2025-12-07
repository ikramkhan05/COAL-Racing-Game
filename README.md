Highway Racer 🏎️
A retro-style racing game written in x86 Assembly Language for DOS, featuring dynamic obstacles, collectible coins, fuel management, and an integrated music system.
👥 Developers

Ikram Ul Haq - Roll No: 24L-0767
Rohaan Ahmed - Roll No: 24L-0548

📋 Table of Contents

Features
Requirements
Installation
How to Play
Game Controls
Game Mechanics
File Structure
Technical Details
Screenshots

✨ Features
Core Gameplay

3-Lane Highway System - Navigate through three distinct lanes
Dynamic Obstacles - Avoid oncoming traffic with intelligent collision detection
Collectible Coins - Earn points by collecting yellow coins
Fuel Management - Strategic fuel collection to keep your car running
Real-time Scoring - Track your performance with an on-screen score display

Visual & Audio

VGA Graphics (320x200) - Retro pixel-art style visuals
Custom Car Sprites - Detailed player and opponent car designs
Animated Road - Scrolling road with lane markings
Background Music - Aggressive racing melody with PC speaker
Music Toggle - Enable/disable music with spacebar
Visual Indicators - Fuel bar, score display, and music status

User Interface

BMP Image Support - Custom start and instruction screens
Player Registration - Enter name and roll number
Pause Menu - Pause game with ESC key
Confirmation Dialogs - Stylized quit confirmations
Game Over Screen - Displays final score and game statistics
"Press Any Key to Start" - Smooth game initialization

Advanced Features

Smart Collision Detection - Lane-based collision system
Collision Preview - Check lane safety before switching
Anti-Overlap Spawning - Prevents items from spawning on top of each other
Smooth Movement - Cooldown-based controls for realistic car movement
Multiple Game Over Conditions - Collision or fuel depletion

🖥️ Requirements
Software

DOSBox (version 0.74 or higher recommended)
NASM (Netwide Assembler) for compilation
DOS Environment (provided by DOSBox)

Hardware (Minimum)

1 MB RAM
VGA-compatible graphics
PC Speaker or compatible sound device

Required Files

game.asm - Main game source code
PICTURE.bmp - Start screen image (320x200, 8-bit indexed color)
INSTRUC.bmp - Instruction screen image (320x200, 8-bit indexed color)

🚀 Installation
Step 1: Install DOSBox
Download and install DOSBox from dosbox.com
Step 2: Assemble the Game
bashnasm game.asm -o game.com
```

### Step 3: Prepare Game Files
Ensure these files are in the same directory:
- `game.com` (compiled executable)
- `PICTURE.bmp` (start screen)
- `INSTRUC.bmp` (instructions screen)

### Step 4: Run in DOSBox
```
mount c /path/to/game/directory
c:
game.com
```

## 🎮 How to Play

1. **Start Screen** - Press any key to continue (ESC to quit)
2. **Instructions** - Review game controls (ESC to quit)
3. **Player Registration** - Enter your name and roll number
4. **Ready Screen** - Press any key to start racing
5. **Race** - Avoid obstacles, collect coins and fuel
6. **Game Over** - View your final score and choose to play again or exit

## 🎯 Game Controls

| Key | Action |
|-----|--------|
| **⬅️ Left Arrow** | Move to left lane |
| **➡️ Right Arrow** | Move to right lane |
| **⬆️ Up Arrow** | Move forward |
| **⬇️ Down Arrow** | Move backward |
| **SPACE** | Toggle music ON/OFF |
| **ESC** | Pause game / Open menu |
| **Y** | Confirm quit (when paused) |
| **N** | Resume game (when paused) |
| **ENTER** | Restart game (game over screen) |

## 🎲 Game Mechanics

### Scoring System
- **Coins**: +10 points per coin collected
- **Survival**: Points accumulate over time

### Fuel System
- **Starting Fuel**: 200 units
- **Consumption Rate**: Decreases automatically (configurable)
- **Refill Amount**: 50 units per fuel pickup
- **Critical Levels**:
  - **Green**: Above 50%
  - **Yellow**: 25-50%
  - **Red**: Below 25%

### Collision System
- **Lane-Based Detection** - Checks if target lane is safe before moving
- **Collision Spark Effect** - Visual feedback on collision
- **Game Over on Impact** - Instant game over when hitting obstacles

### Item Spawning
- **Obstacles**: Spawn every 20 frames (configurable)
- **Coins**: Spawn every 60 frames (configurable)
- **Fuel**: Spawn every 90 frames (configurable)
- **Smart Spawning**: Items avoid overlapping at spawn point

## 📁 File Structure
```
highway-racer/
│
├── game.asm              # Main game source code
├── game.com              # Compiled executable
├── PICTURE.bmp           # Start screen image
├── INSTRUC.bmp           # Instructions screen image
└── README.md             # This file
🔧 Technical Details
Architecture

Platform: x86 DOS (16-bit Real Mode)
Assembler: NASM
Video Mode: 0x13 (320x200, 256 colors)
Memory Model: COM executable (org 0x100)

Graphics System

Double Buffering: Uses memory segment 0x7000 as buffer
Direct VGA Access: 0xA000 segment for screen memory
Pixel-Perfect Sprites: Hand-crafted car and item designs

Interrupt Handlers

Keyboard ISR: Custom INT 09h handler for input
Timer ISR: Custom INT 1Ch handler for fuel and music
Proper Cleanup: Restores original ISRs on exit

Music System

PC Speaker: Uses PIT (Programmable Interval Timer)
Melody Data: Frequency-based note array
Dynamic Playback: Timer-driven note progression
Chromatic Scale: Racing-themed aggressive melody

Configuration (Customizable)
assemblyOBSTACLE_INTERVAL    db 20     ; Frames between obstacles
COIN_INTERVAL        db 60     ; Frames between coins
FUEL_INTERVAL        db 90     ; Frames between fuel
MAX_FUEL             dw 200    ; Maximum fuel capacity
FUEL_DECREASE_RATE   db 15     ; Fuel consumption speed
FUEL_REFILL_AMOUNT   dw 50     ; Fuel per pickup
MOVE_COOLDOWN_TIME   db 10     ; Movement delay
🖼️ BMP Requirements
Image Specifications

Resolution: 320x200 pixels
Color Depth: 8-bit (256 colors indexed)
Format: BMP (Bitmap)
Color Palette: VGA-compatible

Creating Custom Screens

Create/edit image in any graphics editor
Scale to 320x200 pixels
Convert to 8-bit indexed color
Save as BMP format
Name as PICTURE.bmp or INSTRUC.bmp

🎨 Color Palette
Color CodeColorUsage0x00BlackBackground0x01BlueOpponent cars0x02GreenFuel indicators (full)0x04RedCollision, fuel (critical)0x06BrownRoad borders0x07Light GrayCar windows0x08Dark GrayRoad surface0x0CLight RedPlayer car0x0EYellowCoins, lane lines0x0FWhiteUI elements
🐛 Known Issues

Music may sound different on different PC speaker implementations
BMP files must be exactly 320x200 to load correctly
Game requires DOS environment (DOSBox recommended)

🔮 Future Enhancements

 Multiple difficulty levels
 High score table
 Power-ups (speed boost, invincibility)
 Different car types
 Weather effects
 Multiplayer support

📝 License
This project is created for educational purposes as part of an Assembly Language course.
🙏 Acknowledgments

Course instructors for guidance on x86 Assembly
DOSBox team for the excellent emulator
Retro gaming community for inspiration

📧 Contact
For questions or feedback, please contact the developers:

Ikram Ul Haq - Roll No: 24L-0767
Rohaan Ahmed - Roll No: 24L-0548


Made with ❤️ and Assembly Language
Enjoy the ride! 🏁
