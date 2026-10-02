# Kana — a macOS spaced-recognition trainer for hiragana & katakana

Status: **agreed with the user 2026-09-29**. §2 records every decision the user made explicitly;
§4–§12 is the resulting design. This file is the contract for the build.

**Revision 2** — the user asked for keyboard-first interaction ("minimum mouse inputs when
learning"). That added §6, and let me collapse the old four-way scope into a cleaner three-way
model (§9) that still covers "specific characters", "whole rows", and "all mixed in".

---

## 1. Goal

A **local, offline, macOS-only** SwiftUI app that drills hiragana and katakana using flashcards,
mnemonics, and spaced recognition. It speaks characters through the Mac's built-in Japanese
text-to-speech voices. It can drill everything, one gojūon row at a time, an arbitrary hand-picked
set of characters, or only the characters the learner keeps getting wrong — and it can be driven
end to end without touching the mouse.

## 2. Locked decisions

| # | Question | Decision |
|---|----------|----------|
| 1 | Character coverage | **Full set, 104 per script** (46 basic + 25 dakuten/handakuten + 33 yōon) → **208 cards** |
| 2 | Answer style | **All three**, switchable: flip & self-grade, multiple choice, type the rōmaji |
| 3 | Scheduling | **SM-2, four grades** (Again / Hard / Good / Easy) |
| 4 | "Struggling" | `lapses ≥ 3` **or** (`reviews ≥ 5` **and** `accuracy < 70%`) |
| 5 | Where weak cards surface | Dedicated **Struggling session** + a **⚠ badge** everywhere else. No hidden boost inside normal sessions. |
| 6 | Mixed mode | **Alternate per session** — a session is entirely hiragana *or* entirely katakana, alternating. |
| 7 | Daily limits | **Unlimited by default**, with an adjustable limit in Settings. |
| 8 | Packaging | **Swift Package + `build.sh` → double-clickable `Kana.app`**. No Xcode project. |
| 9 | Mnemonics | **Authored for every card** in `Sources/Kana/Data/`. No placeholders. |
| 10 | Input | **Keyboard-first** (§6): every study action is on a key; the mouse is optional. |
| 11 | Platforms | macOS 14+ (built and tested on macOS 27, Swift 6.4, Xcode 27) |
| 12 | App icon | **`仮名` seal** on Apple's icon grid, drawn by `Icon/generate-icon.swift` (no binaries to hand-edit). One `.icns` ships and macOS renders it in every appearance itself — the app never swaps its icon at runtime. A dark appearance is authored (`KanaIcon-Dark.svg`) for a compiled asset catalog, which `actool` can't build here (needs Xcode's first-launch components) |

## 3. Non-goals

- No kanji, no vocabulary decks, no stroke-order diagrams, no writing practice.
- No accounts, no sync, no analytics, no auto-update.
- **No network access of any kind.** Zero third-party dependencies (`Package.swift` has no
  `dependencies:`). All content is authored in-repo, per the brief's "keep within this directory"
  constraint.
- No Xcode project file.

## 4. Content model

A card is one (`script`, `kana`) pair. Rows are the gojūon groups:

| Kind | Rows | Cards per script |
|------|------|------------------|
| `basic` | あ行 か行 さ行 た行 な行 は行 ま行 や行 ら行 わ行 ん | 46 |
| `dakuten` | が行 ざ行 だ行 ば行 ぱ行 | 25 |
| `yoon` | きゃ行 しゃ行 ちゃ行 にゃ行 ひゃ行 みゃ行 りゃ行 ぎゃ行 じゃ行 びゃ行 ぴゃ行 | 33 |

The わ行 row holds わ and を; ん is its own single-character row. Row IDs are shared across scripts
(`ka` is かきくけこ and カキクケコ).

Per-card fields:

```swift
script · kana · romaji · alternates · rowID · kind
mnemonic        // one original English hook, alluding to the shape
exampleWord     // a real, common Japanese word containing this kana, in the same script
exampleRomaji · exampleMeaning
```

`alternates` are **extra accepted spellings** for typing mode, excluding the primary rōmaji —
e.g. し → `shi`, `[si]`; ち → `chi`, `[ti]`; じゃ → `ja`, `[zya]`.

## 5. Answer modes

Chosen on the home screen, snapshotted when a session starts. "Mixed" cycles flip → choice → type
one card at a time.

| Mode | Interaction | Grade written to the scheduler |
|------|-------------|-------------------------------|
| **Flip** | Show kana → reveal → learner picks a grade | the chosen grade |
| **Multiple choice** | 4 rōmaji buttons; distractors prefer the same row, then the same kind | correct → `Good`, wrong → `Again` |
| **Type** | Text field; accepts `romaji` + `alternates`, case/space/hyphen-insensitive | correct → `Good`, wrong → `Again` |

Every mode reveals the rōmaji, mnemonic, and example word after answering, so the mnemonic is always
seen. Choice distractors are de-duplicated by rōmaji spelling, so じ/ぢ never give two identical
buttons.

## 6. Keyboard control

Implemented with a single app-wide `NSEvent` local monitor plus menu-bar commands. The monitor
**stands down whenever a text field has focus**, so typing mode still works normally.

### Menu bar (works anywhere)

| Key | Action |
|-----|--------|
| `⌘1` / `⌘2` / `⌘3` | Study / Progress / Settings |
| `⌘,` | Settings |
| `⌘N` | Start a session with the current settings |
| `⌘A` / `⌘⇧A` | Select all kana / clear selection (home, kana chart only) |
| `⌘Q` | Quit (system) |

### Home screen

| Key | Action |
|-----|--------|
| `⏎` | Start session |
| `H` `K` `M` | Script: hiragana / katakana / mixed |
| `1` `2` `3` | Scope: All / Selected / Struggling |
| `A` | Cycle answer mode |
| `T` | In Mixed, which script the kana chart shows |
| `←` `→` `↑` `↓` | Move the chart cursor; the view scrolls to keep the cursor row in sight |
| `Space` | Toggle the character under the cursor |
| `R` | Toggle the whole row under the cursor |
| `⇧`-click a row label | Select or clear every row since the last one you clicked |
| `G` | Heat map on/off |

### Study session

| Key | Action |
|-----|--------|
| `Space` | Reveal the answer (flip) · continue to the next card (after feedback) |
| `1` `2` `3` `4` | Grade Again / Hard / Good / Easy (flip) · pick option 1–4 (choice) |
| `⏎` | Submit the typed answer · continue |
| `R` | Replay the character's audio |
| `W` | Play the example word's audio (after the answer is shown) |
| `Esc` | End the session and show the summary |

On the summary: `⏎` starts another session, `Esc` returns home.

Every grade button is labelled with its key and the interval it would produce ("Good · 3d"), so the
keyboard path is as informative as the mouse path. The footer of each screen shows the available
keys, so nothing is discoverable-only.

## 7. Scheduling — SM-2, four grades

Grades map to SM-2 qualities `Again=2, Hard=3, Good=4, Easy=5`.

**New / learning cards** use learning steps of **1 min, 10 min**:

| Grade | Effect |
|-------|--------|
| Again | back to step 0, due in 1 min |
| Hard | repeat the current step |
| Good | advance one step; past the last step → graduate to review, interval 1 day |
| Easy | graduate immediately, interval 4 days |

**Review cards** (ease starts at 2.5, floored at 1.3, capped at 3.0):

| Grade | Interval | Ease |
|-------|----------|------|
| Again | `max(1, round(interval × 0.5))`, lapses +1, back to learning | −0.20 |
| Hard | `max(interval + 1, round(interval × 1.20))` | −0.15 |
| Good | `round(interval × ease)` | — |
| Easy | `round(interval × ease × 1.30)` | +0.10 |

The ease used is the value *before* this review's adjustment. Intervals are stored in days
(fractional for learning steps); `due` is an absolute `Date`.

**Inside a session**, a card that is still in the learning phase is re-queued after 3 cards (if
graded Again) or 6 cards (otherwise), so failures come back in the same sitting.

## 8. Struggling detection

```swift
var isStruggling: Bool { lapses >= 3 || (reviews >= 5 && accuracy < 0.70) }
```

Evaluated per card, live. The Struggling scope ignores the script filter, the row/character
selection, and due dates — it queues exactly the flagged cards, worst accuracy first.

## 9. Deck building

Three scopes, one selection set:

- **All** — every card of the selected script.
- **Selected** — the kana chart (§12) is shown; `Space` toggles a character, `R` toggles a whole
  row. This is how you "learn them in rows" *and* how you "select specific characters"; both write
  to the same selection set, which is the whole point.
- **Struggling** — flagged cards across both scripts.

```
pool  = cards matching (script filter) ∩ (selection, when scope is Selected)
queue = learning (oldest first)  +  reviews (oldest first)  +  up to N unseen cards
```

- Script filter: Hiragana / Katakana / Mixed. In Mixed, the store remembers the last session's
  script and alternates; chart selections for both scripts are kept.
- Study ahead is always on: the due-date filter is dropped, so a session can run when nothing is
  due. While the plan reaches past the schedule, the home screen warns how many queued cards are
  not due yet.
- Daily counters (`newIntroduced`, `reviews`) reset at local midnight. `0` = unlimited.
- If the queue is empty — the daily limits have been reached — the home screen says why rather than
  starting a dead session.

## 10. Speech

`AVSpeechSynthesizer` with a `ja-JP` voice — Kyoko by default when installed, otherwise the first
installed Japanese voice; the user can pick any installed Japanese voice in Settings. Triggered by:

- the speaker button on the displayed character (always available),
- the speaker button on the example word, after the answer is revealed,
- optionally, automatically when a card appears (`speakOnAppear`).

All local system synthesis; nothing leaves the machine.

## 11. Persistence

One JSON file: `~/Library/Application Support/Kana/state.json`

```json
{ "version": 1, "settings": {…}, "lastScript": "hiragana",
  "scriptMode": "hiragana", "scope": "selected", "mixedChartScript": "hiragana",
  "selectedKanaIDs": ["hiragana:あ", "…"],
  "dailyLog": { "2026-09-29": { "newIntroduced": 3, "reviews": 47 } },
  "cards": { "hiragana:あ": { "phase": "review", "reviews": 9, "ease": 2.6, "intervalDays": 21, "due": "…" } } }
```

The chart selection and deck setup are saved alongside progress, so relaunching resumes the same
deck rather than silently emptying a "Selected" session.

Written atomically, debounced ~0.75 s, flushed on quit. A missing or corrupt file is treated as a
fresh install rather than a crash.

## 12. Screens

The window is a two-column `NavigationSplitView`: the sidebar lists the three screens (a queue-count
badge on Study, today's counters pinned below it) and the detail column hosts the current screen,
which owns its own toolbar items, title and subtitle. On macOS 26 the sidebar, toolbars and cards
use the system Liquid Glass material; macOS 14–15 render the same layout with standard materials,
which is why `Package.swift` keeps `macOS(.v14)` and every glass API sits behind an availability
check. The keyboard contract in §6 is unchanged by any of this.

- **Study** — home (script, scope, kana chart, answer mode, today's counters, deck size, start) →
  session (character, reveal, answer controls keyed `1`–`4`, audio buttons, progress) → summary
  (accuracy, per-card delta, `⏎` to go again).
- **Progress** — totals (new / learning / mature / struggling), per-row accuracy bars with ⚠
  markers, and a table of all 208 cards (reviews, accuracy, lapses, ease, interval, due).
- **Settings** — daily new/review limits (`0` = unlimited), default answer mode, Japanese voice +
  rate, auto-play toggles, "reset all progress", "reveal data file in Finder".

The chart's heat map (`G`, or the switch in the chart card) tints every kana by how hard that card is
fighting back. The hue is the card's struggle score — seven tenths miss rate, a fifth
forgot-outright lapses, the rest how far the scheduler has pushed the ease down — running green → yellow → amber →
red; the *opacity* carries how much evidence sits behind that score, and a card with no history stays
a faint neutral so the studied cards are the ones that read. Row labels carry the row's average.

## 13. Build & run

```sh
./build.sh                     # swift build -c release, assembles ./Kana.app, ad-hoc signs it
./build.sh --run               # …then opens it
swift run Kana                 # dev loop, no bundle
swift run Kana --verify-data   # dataset integrity check; prints PASS/FAIL and exits
```

The binary records the SDK it was built against (`linkedSDKVersion` in `Package.swift`, passed to
the linker as `-platform_version`). AppKit chooses the era of its window chrome — and a number of
its other behaviours — from that field rather than from the running OS, and SwiftPM would otherwise
record the deployment target, leaving the app with older window controls on a new macOS. The
deployment target itself stays at macOS 14.

`--verify-data` asserts: 208 cards, 104 per script, exactly the expected kana in gojūon order per
row, unique IDs, no empty mnemonic or example word, every example word actually contains its kana,
and every alternate is distinct from the primary.

## 14. Acceptance criteria

1. `./build.sh` produces `Kana.app`; double-clicking it opens a window (not a background process).
2. Hiragana, Katakana and Mixed sessions all start and produce cards; Mixed flips script between
   consecutive sessions.
3. All three answer modes grade correctly, feed SM-2, and show the mnemonic + example afterwards.
4. Typing accepts `shi`/`si`, `chi`/`ti`, `tsu`/`tu`, `fu`/`hu`, `ja`/`zya`, `ji`/`di`-class variants.
5. Audio speaks a Japanese voice for both the character and the example word.
6. The kana chart's `Space`/`R` selection produces exactly the picked cards; Struggling produces
   only flagged cards, ignoring the script filter.
7. Killing and relaunching preserves every card's schedule and every setting.
8. A full session can be completed using only `Space`, `1`–`4`, `⏎`, `R`, `W`, `Esc`.
9. `swift run Kana --verify-data` prints PASS.

## 15. Original brief (verbatim, for reference)

> Build a local swift ui app - that runs on mac only. The goal of the app is to allow the user to
> use spaced recognition techniques to study hiragana and katakana. Use flashcards and mnemonics.
> One mode to learn hiragana & one for katakana, but option to mix the two too! Can we also use the
> macs build in text to speach model (japanese) to read them out. Have options to select specific
> characters or learn them in rows/all mixed in, as well as an option to learn ones the user is
> struggling with by automatically picking them up.
> - Keep within this directory and do not use the internet without my permission for anything.
