# Kana

A local, offline macOS app for learning **hiragana** and **katakana** with flashcards, mnemonics,
and SM-2 spaced repetition. It can read characters aloud with the Mac's built-in Japanese voices.

**Note: AI Generated Work**

See `spec.md` for the full design and the decisions behind it.

## Run it

```sh
./build.sh --run         # builds ./Kana.app and opens it
```

That's it. `Kana.app` is a normal double-clickable app — you can drag it to `/Applications`.

Other useful commands:

```sh
./build.sh                        # build only
swift run Kana                    # dev loop, no bundle
swift run Kana --verify-data      # check the 208-card dataset, then exit
CONFIG=debug ./build.sh           # debug build
SWIFT_FLAGS="--arch arm64 --arch x86_64" ./build.sh   # universal binary
```

## Keyboard

The app is designed to be driven without a mouse.

**Home screen**

| Key | Action |
|-----|--------|
| `⏎` | Start a session |
| `H` `K` `M` | Hiragana / Katakana / Mixed |
| `1` `2` `3` | Scope: All / Selected / Struggling |
| `A` | Cycle the answer mode |
| `T` | In Mixed, which script the chart shows |
| `←` `→` `↑` `↓` | Move around the kana chart — it scrolls to keep the cursor row in view |
| `Space` | Toggle the character under the cursor |
| `R` | Toggle the whole row under the cursor |
| `⇧`-click a row label | Select or clear every row since the last one you clicked |
| `G` | Heat map — tint every kana by how well you know it |
| `⌘A` / `⌘⇧A` | Select every kana / clear the selection |

The heat map (`G`, or the switch in the chart card) colours the chart by how hard each card is
fighting back: green when it is solid, yellow then amber as it gets shaky, red when it keeps beating
you, and a faint neutral for anything you have not really started. How *faint* the colour is tells
you how much history is behind it, so one lucky answer does not read as mastery. Each row label
carries a dot with the row's average.

Sessions always study ahead: due dates order the queue but never hold a card back, so you can keep
going when nothing is due yet. When the plan reaches past the schedule, the Study screen warns how
many queued cards are not due.

**During a session**

| Key | Action |
|-----|--------|
| `Space` | Reveal the answer, then continue |
| `1` `2` `3` `4` | Grade Again / Hard / Good / Easy, or pick a multiple-choice option |
| `⏎` | Submit a typed answer, or continue |
| `R` | Replay the character's audio |
| `W` | Play the example word's audio |
| `Esc` | End the session |

**Anywhere:** `⌘1` Study · `⌘2` Progress · `⌘3` Settings · `⌘N` new session.

## Where things live

```
Sources/Kana/
  Model/     Kana types, the library index, SM-2 scheduler, deck building, session engine, app state
  Data/      the 208 authored cards — one file per script and kind
  Views/     SwiftUI screens (home, session, progress, settings)
  Audio/     AVSpeechSynthesizer wrapper
  Keyboard/  the app-wide key monitor
  DataVerifier.swift   the --verify-data integrity check
```

Your progress lives in a single JSON file:

```
~/Library/Application Support/Kana/state.json
```

Delete it to start over, or use **Settings → Reset all progress**. Settings can also reveal it in
Finder.

## Editing the content

Each card is one line in `Sources/Kana/Data/*.swift`:

```swift
.hira("あ", "a", [], "a", .basic, "mnemonic text", "あめ", "ame", "rain"),
//     kana romaji alternates rowID kind  mnemonic  exampleWord exampleRomaji meaning
```

`alternates` are extra accepted spellings for typing mode (し accepts both `shi` and `si`).

After editing, run:

```sh
swift run Kana --verify-data
```

It checks the card count, the exact gojūon order of every row, duplicate ids, empty fields, that
every example word really contains its own kana, and that no alternate duplicates its primary
rōmaji. It prints `PASS` or a list of specific problems.

## Tuning the schedule

`Sources/Kana/Model/Scheduler.swift` holds the learning steps, starting ease, and the per-grade
interval and ease adjustments described in `spec.md` §7. Daily new/review limits are in the app
under **Settings** (`0` = unlimited, which is the default).

## Requirements

macOS 14 or newer, and a Japanese voice installed (Kyoko ships with macOS). If audio is silent,
check **System Settings → Accessibility → Spoken Content → System Voice → Manage Voices**.

## Window

The window is a native macOS split view: a sidebar for **Study / Progress / Settings** — with the
number of queued cards badged on *Study* and today's counters pinned at the bottom — and a detail
column where each screen owns its own toolbar items and title. `⌘1`–`⌘3` switch screens exactly as
before; every keyboard command in the table above is unchanged.

On macOS 26 the sidebar, toolbar and cards use the system Liquid Glass material. macOS 14 and 15
render the same layout with standard materials, so nothing in the app requires the newer OS.

The binary also names the SDK it was built against (see `linkedSDKVersion` in `Package.swift`),
because AppKit takes the era of its window chrome from that field rather than from the system it is
running on — SwiftPM would otherwise record the deployment target and leave the app with older
window controls on a brand-new macOS.

## App icon

`仮名` — the kanji spelling of *kana* — stacked vertically in white on the app's vermilion
(`Theme.accent`), like a hanko seal. It sits on Apple's icon grid: an 824 × 824 body inside a
1024 × 1024 canvas with superellipse corners, no baked drop shadow (the system adds one), and a
Liquid Glass specular across the top edge, drawn over the glyph the way a real surface catches
light.

It's drawn by a script rather than kept as opaque binaries:

```sh
Icon/make-icon.sh          # redraws the SVG + PNG sizes, then rebuilds AppIcon.icns
./build.sh                 # copies it into Kana.app/Contents/Resources
```

`Icon/generate-icon.swift` is the source of truth — the glyph, the two palettes and the geometry are
constants at the top of the file. Its vector output is `Icon/KanaIcon.svg` (light) and
`Icon/KanaIcon-Dark.svg`, if you'd rather work in a drawing app.

One appearance ships: `AppIcon.icns`, which `Info.plist` names so Finder, Launchpad and the Dock all
use it. macOS renders that icon in every appearance itself, so it looks the same closed and open —
the app deliberately never touches its own icon at runtime, because anything it did there would work
against the system's rendering and visibly change the icon the moment you launched it.

`Icon/KanaIcon-Dark.svg` is the authored dark appearance, kept as a vector source rather than
shipped: the day the icon travels as a *compiled asset catalog* instead of a lone `.icns`, that file
is what a dark (and tinted) layer would be built from. `actool` compiles those catalogs and needs
Xcode's first-launch components (`xcodebuild -runFirstLaunch`), which aren't installed here.

## License

MIT — see `LICENSE`.
