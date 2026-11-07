# Development Roadmap

## Milestone 1: Battle Prototype

Goal: one playable battle between the constable and a bandit.

- Basic player HP and BP.
- Enemy HP and shield.
- Weakness hits with blade and fire.
- Broken state.
- Restart button.

## Milestone 2: West Market Walkable Scene

Goal: a tiny Chang'an West Market map.

- Player movement.
- Three NPCs.
- One investigation point.
- One warehouse entrance.

## Milestone 3: Investigation Flow

Goal: connect story and combat.

- Dialogue box.
- Interrogate action.
- Clue flags.
- Warehouse battle unlocks after enough clues.

## Milestone 4: Visual Direction

Goal: make the prototype feel Tang-inspired.

- Lantern-lit market palette.
- Constable and bandit concept art.
- Simple UI frame style.
- First music and sound placeholders.

## Milestone 5: Narrative Bible

Goal: define the full game story foundation before expanding content.

- World premise and main theme.
- Eight playable character concepts.
- Four-hour chapter structure for each character.
- Shared main plot object: the Xuan Die evidence ledger.
- Chapter writing template for future quests, dialogue, and maps.

## Milestone 6: Box-Garden Chapter Design

Goal: turn each character chapter into a small explorable multi-map space rather than a linear quest chain.

- One hub map per character chapter.
- Three to five sub-maps with clue chains between them.
- Map state changes as clues are found.
- Revisit old maps before the chapter boss.
- Endgame returns to the eight chapter areas as one connected Chang'an.

## Milestone 7: Chapter 1 Vertical Slice

Goal: turn the current West Market demo into the first playable version of Shen Yan's chapter, "West Market Lights Out".

- Add `data/chapter_01_zh_cn.json` for chapter text, clues, interactables, and achievements.
- Add a chapter phase state machine: intro patrol, crime scene, warehouse ready, ending.
- Expand the investigation from two clues to four clue lines.
- Add hidden interactions and first achievement checks.
- Connect investigation quality to the warehouse boss intro.
- Return to West Market after the fight and show the chapter ending.
