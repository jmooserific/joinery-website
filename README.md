# joinery.moosed.me

Three static pages. Plain HTML and CSS, no build step, no JavaScript, and no
request to any other domain — the privacy page claims the last one, so it has
to keep being true. Don't add a font host, an analytics snippet, or a CDN link
without rewriting that page first.

Served by GitHub Pages from the repository root. `CNAME` holds the domain;
`.nojekyll` keeps Jekyll out of the way.

## Routes

| Route | File | Used by |
|---|---|---|
| `/` | `index.html` | — |
| `/privacy/` | `privacy/index.html` | App Store Connect, Privacy Policy URL |
| `/support/` | `support/index.html` | App Store Connect, Support URL |

Directory indexes rather than `privacy.html`, so the extensionless URL works on
GitHub Pages, Cloudflare Pages, Netlify and anything else without host-specific
rewrite rules. `/privacy` (no trailing slash) redirects to `/privacy/`; both are
safe to paste into App Store Connect, and neither should move once they're in
there.

Every internal link is relative, so the site works from any mount point — the
domain root, a `user.github.io/repo/` project page, or a local server pointed at
a parent directory. The only absolute URLs are the two Open Graph tags, which
have to be absolute for a crawler to resolve them, and the outbound links —
`moosed.me` and the three museum open-access pages the gallery credit points
at. Outbound links are not requests: nothing is fetched from those hosts unless
a reader clicks, so the privacy page's claim holds.

## Working on it locally

```bash
python3 -m http.server 8000
```

Then open <http://localhost:8000/>. A server rather than `file://`: the routes
are directories, and browsers won't resolve `privacy/` to `privacy/index.html`
over `file://`, so cross-page links break there even though the CSS and images
load fine.

## Where the design came from

Nothing here is an invented palette. The tokens in `assets/site.css` are the
shipped app's, and each is commented with its source:

- Colors, rules and the image radius — `docs/design/design_handoff_home_view/README.md`
  and `Joinery/Home/HomeTray.swift` (`TrayPalette`) in the app repo.
- The accent — the app icon's own gradient in `AppIcon.icon/icon.json`, whose
  lower stop converts from Display P3 to exactly `#FF9500`, which is
  `systemOrange`, which is `AccentColor.colorset`. Light and dark use the
  system's two values for it.
- Dark mode reuses the app's own pairing: the ink becomes the ground, and text
  on it takes the app's "text on felt" colors.

If a token here ever disagrees with the app, the app wins.

## Assets

| File | What it is |
|---|---|
| *(inline in `index.html`)* | A real cut from `PuzzleEngine`, 63 pieces (a 64 target lands on a 7×9 grid), seed 9. Drawn with `stroke="currentColor"` so CSS themes it. Sits in the reading column beside the paragraph that explains it. |
| `assets/og.png` | The same engine and seed, 12 pieces, rendered flat for link previews. Far fewer pieces because a 63-piece cut turns to mush at thumbnail size. |
| `assets/icon.svg`, `assets/apple-touch-icon.png`, `assets/favicon.png` | The app icon: `AppIcon.icon/Assets/icon_piece.svg` at the placement and gradient `icon.json` specifies. |
| *(inline in `index.html`)* | The wordmark, outlined. Same string, face and per-pair kern table as `Joinery/Home/HomeWordmark.swift`. |
| `assets/piece.{webp,jpg}` | Pieces close up, rims shaded from one direction — the relief, in "The pieces are the point". |
| `assets/generate.{webp,jpg}` | The cut mid-animation: the left of the picture already in pieces, the grid on the right still plain with knobs pushing out along it. |
| `assets/presets.{webp,jpg}` | The create sheet on Easy: picture, credit, and the three presets. Pairs with `custom`. |
| `assets/custom.{webp,jpg}` | The same sheet on Custom, with the piece count, rotation and snap distance each on its own control. |
| `assets/joinery.mp4` | One puzzle start to finish — picking a painting, watching the cut, solving it. 3:22, silent, 552×1200, no audio track at all. |
| `assets/joinery-poster.jpg` | The frame at 0:18 of that recording, where the cut has just finished across the whole picture. Shown until someone presses play. |

### Regenerating the cut

`tools/cut-export` is a small executable that links the app's `PuzzleEngine` and
prints one cut as SVG. It expects the app checkout beside this one
(`../Joinery`). It is a development tool; the published site has no build step.

```bash
swift run --package-path tools/cut-export CutExport --width 1200 --height 800 --pieces 64 --seed 9
```

`--stroke` divides the width to get the stroke weight (default 620). Paste the
output over the `<svg>` inside `<figure class="cut">`. Changing the seed changes
the cut, which is the point — it is generated, not drawn.

The tool reports **blanks** and **slivers** on stderr, which is how to shop for
a seed. A *blank* is an interior side the algorithm chose to cut without a knob;
on a still picture one reads as a false edge and pulls the eye, so a seed for
this page wants zero. A *sliver* is the short flat side a staggered junction
leaves between a diagonal pair — there are dozens in every cut and they are
meant to be there. Seed 9 at 64 has no blanks; seeds 6, 11 and 12 have two.

### Regenerating the wordmark

`tools/wordmark-export` rebuilds the logotype from the app's kern table. It is
outlines, not live text, for two reasons: the kerning is a *per-pair* table
(round-to-round joins want the most negative, `r`→`y` goes positive so the r's
arm clears the y's diagonal), which no single `letter-spacing` can express; and
SF Pro can't be shipped as a webfont, so live text would fall back to Segoe UI
or Roboto off Apple platforms and the SF-tuned kerning would land on the wrong
letterforms.

```bash
swiftc -O tools/wordmark-export/main.swift -o /tmp/wordmark && /tmp/wordmark
```

Paste the output over the `<svg>` inside `<h1 class="wordmark">`. It fills with
`currentColor`, so it takes the ink in both appearances; the `<h1>` also holds
the word as visually-hidden text, so the heading still has real text in it.

Re-run this if `HomeWordmark.kernEm` changes in the app.

### The walkthrough video

`assets/joinery.mp4` sits directly under the subtitle, in the reading column
rather than the breakout — it is a phone screen, so it takes a phone's width
and is centered in the column, and blown up to the full measure it would be
over 1200px tall. It is first because it is the strongest thing on the page: it
shows the cut being drawn and the puzzle being solved, which is the whole
argument, before a word of the argument is made.

`preload="none"` and a poster frame, so a visit that never presses play costs
one 83KB JPEG rather than 6MB of video. There is no `autoplay`: the page has
one action on it and this isn't it. The recording has no audio track, so
`muted` would be decoration.

MP4 only. The usual reason to ship a WebM beside it is Safari, and Safari is the
one browser guaranteed to have H.264 — a second encode would be bytes in the
repository for no browser that needs them. Self-hosted, no player library and
no script, or the privacy page stops being true.

A simulator screen recording comes out **anamorphic**: 1206×1080 coded pixels
with a `pasp` atom of 180:437, which displays as 496×1080. `scale` works on the
coded size and ignores that, so the target dimensions have to be given
outright, along with `setsar=1` to drop the correction once it has been applied:

```bash
ffmpeg -i ScreenRecording.mp4 \
  -vf "scale=552:1200,setsar=1,fps=30" \
  -c:v libx264 -profile:v high -crf 27 -preset slow \
  -pix_fmt yuv420p -movflags +faststart -an assets/joinery.mp4

ffmpeg -ss 18 -i assets/joinery.mp4 -frames:v 1 -q:v 3 assets/joinery-poster.jpg
```

552×1200 is twice the 272px the video renders at, and holds the 1320:2868 shape
of the screen it came off. 60fps down to 30 halves the bitrate and costs
nothing: the only motion is a finger dragging cardboard. `+faststart` puts the
index at the front so it plays before it has finished arriving; `-an` makes the
absent audio track explicit.

### Replacing the screenshots

Each is a `<picture>` with a WebP source and a JPEG fallback, exported 660px
wide — half of the 1320px iPhone 17 Pro Max capture, and well over twice the
280px each one renders at.

Ship the **whole screen**, uncropped. Cropping to the content was the earlier
rule and it was wrong: a crop is a claim about what the app looks like that the
app never makes, and the status bar and the island are what anyone holding the
phone actually sees. The cost is height — one 6.9-inch screen at the full
reading measure runs past 1200px — so a screen is shown at 17rem, a phone's
width, centered in the column, and renders at 272px.

`.shot` is one screen. `.shots` is a pair side by side at that same width, for
shots that only argue together — the presets and the three dials behind them
are the only pair left. Reach for `.shot` unless the second one is doing work
the first can't.

```bash
magick shot.png -resize 660x1434 -strip -quality 82 -sampling-factor 4:2:0 -interlace Plane assets/NAME.jpg
magick shot.png -resize 660x1434 -strip -define webp:method=6 -quality 80 assets/NAME.webp
```

`width`/`height` on the `<img>` stay 660×1434, so the page reserves the right
space and doesn't reflow while they load. All of them are `loading="lazy"`;
they all sit below the fold. The video does not — it is the first thing under
the subtitle — but `preload="none"` means only its poster is fetched.

Images carry a 1px `--rule` border. The board shots bring the app's own ground
with them and would separate from the page without one, but the create sheet is
white to its edges and dissolves into the paper otherwise; the border is on all
of them, and on the video, so the set stays consistent.

Quality 82 rather than the 78 the crops used. A whole screen at 660px puts the
board's fine cut lines into about a third the pixels they had before, and 78
frays them; the difference is around 20KB a shot.

660px is 2.4× the 272px they render at, not 2×. The extra is for the cut lines
again: they are one device pixel wide in the capture and the first thing to go
soft, and a shot resized to 544 has visibly fewer of them than one resized to
660 and drawn at the same size.

## The TestFlight link

It appears twice in `index.html` — once after the opening two paragraphs, once
in the footer — with the same href and the same words in both, on purpose. At
launch both become "On the App Store" pointing at the product page. Two lines,
and an HTML comment above each marking which is which.

Only the treatment differs. The first is `.button`: the app's own Create
control, accent fill and white label in a full capsule, centered, because it is
the page's one action and it is asking you to go and press exactly that button.
The footer one is a plain link among the other plain links, a way back to the
first rather than a second ask. If a second button ever appears on the page,
neither of them is the action any more.

The white label on `--accent` is the app's pairing, not a web contrast ratio —
it comes out around 2.2:1. Swapping `color: #fff` for `color: var(--ink)` in
`.button` takes it to about 8:1 and keeps the fill, if that trade is ever worth
making.

## Things this site deliberately doesn't have

No newsletter, no roadmap, no "coming soon", no press kit, no analytics, and no
cookie banner (there are no cookies to consent to). No video either, and no
placeholder standing in for one — nothing on the page announces that something
is coming.
