# Kana

A local, offline macOS app for learning **hiragana** and **katakana** with flashcards, mnemonics,
and SM-2 spaced repetition. It can read characters aloud with the Mac's built-in Japanese voices.
Nothing ever touches the network, and there are no third-party dependencies.

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
| `←` `→` `↑` `↓` | Move around the kana chart |
| `Space` | Toggle the character under the cursor |
| `R` | Toggle the whole row under the cursor |
| `S` | "Study ahead" — ignore due dates |
| `⌘A` / `⌘⇧A` | Select every kana / clear the selection |

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

## License

MIT — see `LICENSE`.
