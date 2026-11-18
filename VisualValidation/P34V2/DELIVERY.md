# P3.4 v2 — first-row Xcode reconstruction

Source file: `[Aixd Final] Roolio` (`TQe7uP4Nk5xcOXCSxRzgjt`)

Source section: `visual refinement` (`700:5864`)

Implementation: `Roolio/RoolioApp.swift`

## Page ↔ Figma node map

| Order | SwiftUI route | Figma frame | Node | Figma size |
|---:|---|---|---|---:|
| 1 | `shelf` | `shelf page` | `700:4059` | 402 × 901 |
| 2 | `home` | `Homepage · iPhone 18 Pro` | `700:4180` | 402 × 908 |
| 3 | `detail` | `Game detail` | `700:5191` | 402 × 1220 |
| 4 | `setup` | `Host game - turn your screen` | `700:4402` | 402 × 874 |
| 5 | `invite` | `1.invite` | `700:4252` | 392 × 874 |
| 6 | `first` | `2.who first` | `700:5321` | 402 × 874 |
| 7 | `ready` | `3. all set to go` | `700:4295` | 402 × 874 |
| 8 | `horizontal` | `horizontal` | `700:4416` | 392.86 × 873.44 |

## Newly exported assets and source nodes

All unmodified downloads live under `FigmaExports/P34V2/<frame>/`. App-ready assets live under `Roolio/Assets.xcassets/P34V2/`.

| Asset family | Figma source layer(s) | App assets |
|---|---|---|
| Shelf covers | `700:4064`, `700:4066`, `700:4068`, `700:4070`, `700:4072`, plus cabinet copies `700:4117`, `700:4120`, `700:4123`, `700:4151`, `700:4154` | `P34SplendorCover`, `P34Forbidden`, `P34Cascadia`, `P34Azul`, `P34Wingspan` |
| Shelf replacement covers | `700:4133`, `700:4136`, `700:4139` | `P34TeaWitches`, `P34Wayfinders`, `P34Catan` |
| Wood and cabinet source fills | frame fill `700:4059`, cabinet `700:4108`, Homepage cabinet instance `I719:1250;558:532` | `P34Wood`, `P34Cabinet` |
| Homepage artwork | logo/avatar instances under `700:4180`; featured artwork `I700:4210;599:793`; covers `700:4238`–`700:4242` | `P34Logo`, `P34Avatar`, cover assets above, exact navigation SVGs |
| Game Detail atmosphere and cover | blurred crop `700:5193`; official cover `700:5223`; logo `I700:5199;599:793` | `P34SplendorCover`, `P34SplendorTitle` |
| Game Detail achievement icons | Tutor `700:5263` (`700:5264`, `700:5265`); Table `700:5272` (`700:5273`–`700:5275`); Merchant `700:5282` (`700:5283`); Noble `700:5290` (`700:5291`) | `P34BadgeTutor`, `P34BadgeTable`, `P34BadgeMerchant`, `P34BadgeNoble` |
| Setup illustration | `700:4406` | `P34SetupBox`; root image fill retained as `P34SetupBackground` |
| Invite cover/table | cover `700:4256`; table vectors in instance `I700:4277;619:962`; action vectors `700:4284`–`700:4294` | `P34SplendorCover`, `P34Table`, `P34Felt`, exact shared SVG icons |
| First-player draw card | cover `700:5338`; draw card `700:5358` | `P34SplendorCover`, `P34CardBack` |
| Ready order card | cover `700:4361`; order-card strip `700:4381` | `P34SplendorCover`, `P34OrderCard`, derived source crop `P34OrderMiddle` |
| Horizontal turn animation | image fill `700:4421`; animated container `700:4427` | `HorizontalTurn.gif` |
| Status/navigation vectors | status-bar instances inside each frame; shelf vectors include `I700:4178;609:353;5465:16812`, `…16813`, `…16816` | `P34Cell`, `P34Wifi`, `P34Battery`, `P34Home`, `P34Explore`, `P34Shelf`, `P34Coolibo`, `P34Profile` |

`P34OrderMiddle` is a deterministic crop of the middle card from Figma's original 2172 × 724 source bitmap; it is not a screenshot or redrawn card.

## Screenshot-substitution check

- PASS — no Figma frame export, reference screenshot, overlay, or diff image is included in the app target.
- PASS — repository scan found no `reference.png`, `VisualValidation`, `FigmaExports`, or Figma node-ID references inside `Roolio/` or `Roolio.xcodeproj`.
- PASS — all icons used by the eight pages are exported Figma SVG layers; the four temporary character-based achievement icons were removed.
- PASS — backgrounds are implemented as source image fills plus SwiftUI blur, opacity, gradient, stroke, shadow, and clipping layers.
- PASS — the horizontal prompt uses the original source GIF. `--freeze-motion` only freezes its first frame for repeatable visual comparison; normal app runs preserve the 2-second loop.

## Visual comparison results

The simulator screenshots are captured on iPhone 17 Pro (iOS 26.5), downsampled from 3× to Figma points, then compared against the source render. `compare.py` masks rows 0–58 (the physical Dynamic Island conflicts with the source iPhone 18 status-bar-only template) and 860–873 (Home Indicator hardware chrome). For source frames taller than the 874-point device viewport, the visible top 874 points are compared.

| Page | MAE / 255 | Pixels with max-channel delta > 16 | Output |
|---|---:|---:|---|
| Shelf | 40.841 | 70.557% | `Diff/shelf-overlay.png`, `Diff/shelf-diff.png` |
| Homepage | 23.429 | 59.780% | `Diff/home-overlay.png`, `Diff/home-diff.png` |
| Game Detail | 18.587 | 28.117% | `Diff/detail-overlay.png`, `Diff/detail-diff.png` |
| Setup | 1.934 | 1.607% | `Diff/setup-overlay.png`, `Diff/setup-diff.png` |
| Invite | 26.916 | 25.661% | `Diff/invite-overlay.png`, `Diff/invite-diff.png` |
| Who First | 5.491 | 6.722% | `Diff/first-overlay.png`, `Diff/first-diff.png` |
| All Set | 6.281 | 9.019% | `Diff/ready-overlay.png`, `Diff/ready-diff.png` |
| Horizontal | 3.881 | 2.626% | `Diff/horizontal-overlay.png`, `Diff/horizontal-diff.png` |

Exact machine-readable values are in `results.json`. Run `python3 VisualValidation/P34V2/compare.py` after new captures to regenerate every aligned image, overlay, heat map, and metric.

## Build verification

Final command completed successfully:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project Roolio.xcodeproj -scheme Roolio -sdk iphonesimulator \
  -configuration Debug -derivedDataPath /private/tmp/RoolioDerivedData \
  CODE_SIGNING_ALLOWED=NO build
```

Verified bundle ID: `com.roolio.prototype`.

Verified simulator: iPhone 17 Pro, iOS 26.5 (`468C8081-1E87-4D06-AD82-B00D03BAF403`).

## Archived previous implementation

The pre-existing design was preserved at `ArchivedDesign/2026-11-17/` and is not referenced by the new target implementation.
