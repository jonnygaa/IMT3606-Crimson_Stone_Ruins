# IMT3606 - Crimson Stone Ruins


Game Design Document

Crimson Stone Ruins

\


A game design document is a living document which describes the intent of the game design. 

It has two goals, first to document the decisions that have been made about the game and communicate those concepts to the entire team. 

Thus, it needs to be detailed enough for programmers to refer to when they need clarification about an aspect of the game. 

It must be able to be updated as the game is to be built. 

The need to have a game design document increases with the size of the team and length of the project. 

For a student project the intent is to capture as much as possible of your design. 

The game design will be larger than what you can achieve in a semester, but you must then decide what you need to do first. 

This document should be in version control so that you can see it changing and growing. 

Given we are using git you could also use @name to assign parts of the design to individual members of the team.


# Overview

Members:

Alexis Blouin

Dominik Müller

Jonas Nygaard

Louis Ledoux

Mikal Øverland


# Game Concept

The game is about an alchemist who is looking for the recipe to create the philosopher stone. For this he is exploring ruins, to which he got clues that it might be there. He wants the philosopher stone to become immortal.


# Genre

Turn Based Combat

Dungeon Explorer

Roguelite 


# Target Audience

Players who love roguelikes and turn based combat, but do not want to play another deck building game.


# Game Flow Summary

The player will explore a dungeon with multiple floors. In the dungeon are different enemy types, which change depending on how deep the player goes. There are also secrets and items spread across the dungeon to help the player.


# Look and Feel

When the player delves deeper into the dungeon. They find other alchemists, who failed their goals. This often leads to them being infused with an element. 


# Gameplay and Mechanics

- Turn Based Combat with spell crafting

- Ingredients are used for spell crafting and limited use

- Different enemy classes ( Elemental resistances)

- Procedural map generating

- Over world mechanics ( like traps)

- Accessories 

- Learn new spells from books / going deeper into the dungeon

- Spells order is the same across runs


# Gameplay

What is the core of the player's interaction with the game?

The main gameplay is the combat, where the player has to use their ingredients to craft the spells to attack the enemy. For some puzzles, the player has to use this system to craft the correct spell to solve it.


## Priorities to combat scope-creep:

Crafting Spells (High)

Procedural generation. (High)

Grid for different characters.(High)

Spellbook for lookup crafting (middle)

Rings for effect (middle)

Minimap of the level (middle)

Multiple spots for the enemies to move between. (Low)

Dynamic combat order. (Low)

Making our own art. (Low)

\
\
\



## Elements

Fire: AoE, DoT(damage over time),

Lightning: Chain, volatile damage range, crit,

Water: Restorative buff, debuff(freeze/chill) (Knockback, positioning system)

Earth: Armor, defensive, inaccurate, ground effects(AoE debuffs?), slow

Acid: Armor-break, vulnerability, DoT,

Wind: Shuffle to different spots, Semi-stun, 

Pick up spell crafting ingredients and use them in combat to create powerful spells. In the overworld players can explore to find hidden rooms and puzzles. 

\



## Accessories

One type of equipment which can only be swapped out if new one is found

- Improve defense

- Improve dmg for element type

- Increase number of ingredients usable per turn


# Game progression

The ingredients will become progressively stronger. Scaled with levels.


# Mission/challenge Structure

The dungeon will have a linear structure with multiple levels. Where the last level will have a boss enemy.


# Puzzle Structure

The dungeon will have a special room with visual cues for what elements and in what order the player has to use on the door to open it. For this the player would enter combat with the door and it would end after a single turn with either a message “Door has been unlocked” or “No effect”.


# Objectives

Budding alchemist, trying to make a philosopher’s stone. 


# Mechanics

There are different enemy types, some are guards which just stand in one place and do not move. Others will chase the player, when they are inside their room. When contact is made they are place inside a combat room.

Another mechanic is the crafting of spells with ingredients. For this the order of the ingredients have to be in a specific order. As an example the order “Fire-Fire-Wind” would produce a different spell then “Wind-Fire-Fire”. These ingredients also have different qualities which affect the overall spell damage.


# Physics

No physics


# Movement

The player moves on a 2D plane in a 3D world.


# Objects

The player will have access to different elements to use during combat. He will be able to use basic spells or to make a combination of elements to make magic that he learned during his run.

We may want to add objects like rings, clothes, pendant, etc. to allow the player to have a certain advantage on one aspect of the game (attack, critical hit, defense, etc.).


# Actions

The player can interact with chests in the world to have one source to get new ingredients.


# Combat

At the start of each turn, the player uses their resources to attack. These resources can be combined to create spells. When the player has selected the resources to use this turn they will attack and afterward the enemy attacks the player.


# Economy

There is no classic form of economy in the game, like money. Our form of economy is managing the ingredients, since they are limited. New ingredients are obtained by chests and defeating enemies.


# Screen Flow
![alt text](https://github.com/jonnygaa/IMT3606-Crimson_Stone_Ruins/blob/main/README_images/screenOrder.png "Screen order")
Here are the 3 main screens that we will have. There are 3 other possible screens. If we go to a certain dotted line screen, we can only go back to the same screen that we came from.

![alt text](https://github.com/jonnygaa/IMT3606-Crimson_Stone_Ruins/blob/main/README_images/combatScreen.png "Combat Screen")
The combat screen is the place where all the combats are happening, so the player needs to see the different information on his status, his elements and the enemies.

![alt text](https://github.com/jonnygaa/IMT3606-Crimson_Stone_Ruins/blob/main/README_images/walkAroundScreen.png "Walk Around Screen")
The walk screen is when the player is going to explore the dungeon. Less information is needed as the player is not fighting, but it’s still important to see the health since he won’t regenerate by himself. There are also tooltips for the different menus available.

![alt text](https://github.com/jonnygaa/IMT3606-Crimson_Stone_Ruins/blob/main/README_images/spells.png "Spell book")
The book is the place where the player will be able to see the different spells and magics available for his combats.


# Game Options

The only options in the game are for graphics, audio and key bindings. These do not affect gameplay in any way.


# Replay and Saving

The player is able to save the game during the dungeon exploration at any time and can return to it from the main menu.


# The Story, Setting, and Character

The game does not focus on story. But some kind of story is planned but will currently not be implemented.


## Story and Narrative

You play as an alchemist who is chasing to be known across the world for finding the legendary philosopher stone. He heard rumors of its location and set out to find it. Once he reaches the location, he finds that it’s some sort of village ruins with a temple in which he descends.


## Game World

Medieval fantasy world.


## General look and feel of the World

Pixel art style with a darker tone.


## Areas

The dungeon has multiple levels, which become more and more destroyed by the age of time, and becomes moodier the deeper he goes. They are connected to the temple. 


## Characters

We only have the alchemist who wants to be known across the world, as in his younger years everyone ignored and mocked him.


# Levels

## Playing Levels

There are multiple levels in the dungeon with the same structure of randomly generated rooms. At the end of each level is an exit which leads to the next level until the final level with the boss is reached.  


## Training level

We created an extra tutorial level which can be accessed from the main menu. In there, the game mechanics are explained.


# Interface

## Visual System

If you have a HUD, what is on it?  What menus are you displaying? What is the camera model?

The camera is positioned above the player to better display the dungeon and not have issues with dungeon walls covering the player view.

The player can view an inventory with their current ingredients and also see their equipped accessory in the dungeon exploration.

In combat, the player has a circle in front of him where his selected ingredients are displayed. The crafted spells will be shown to the player before using them. 


## Control System

WASD is used to move around in the dungeon. Combat is done just with clicking buttons. Opening chests and accessing tools is done with specific keys.


## Audio, Music, Sound Effects

We have no audio.


# Artificial Intelligence

## Opponent and Enemy AI

The active opponent that plays against the player and therefore requires strategic decision-making.


## Player and Collision Detection, Path-finding.

We use a collision box to prevent the player going out of bounds and detection with enemies. The enemies will just walk to the player location.


# Technical

## Target Hardware

If you have a reason PC with a CPU and integrated GPU, it should handle the game.


## Development Hardware and Software (including game engine)

- Engine Godot 4.4

- Ranges of different laptops with and without dedicated GPUs

- Aseprite


## Network requirements

This is an offline single player game and does not need any network connection.
