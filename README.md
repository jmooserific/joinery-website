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
| `assets/generate.{webp,jpg}` | Simulator capture of a cut being drawn — finished cut on one side, the line still advancing on the other. |
| `assets/solve.{webp,jpg}` | Simulator capture of a board part way through: one joined block, loose pieces around it. |
| `assets/piece.{webp,jpg}` | Simulator capture of one piece close up, illustrating the rim shading in "The pieces are the point". |
| `assets/configure.{webp,jpg}` | Simulator capture of the create sheet, cropped below the picture to the title, credit and the three settings. |

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

### If a walkthrough video is ever added

There is no slot for one now. To add it, put a figure between the TestFlight
line and the first section, and give it the breakout column:

```html
<figure class="video wide">
  <video controls playsinline preload="metadata"
         poster="assets/walkthrough-poster.jpg" width="1280" height="720">
    <source src="assets/walkthrough.webm" type="video/webm">
    <source src="assets/walkthrough.mp4" type="video/mp4">
  </video>
</figure>
```

```css
.video { margin-top: 3.5rem; }
.video video {
  display: block;
  width: 100%;
  height: auto;
  background: var(--panel);
  border: 1px solid var(--rule);
  border-radius: var(--radius-image);
}
```

Ship both sources — Safari needs the MP4. Self-hosted, no player library and no
script, or the privacy page stops being true. `.wide` is the only thing that
uses the grid's breakout tracks; nothing else on the page does at the moment.

### Replacing the screenshots

Each is a `<picture>` with a WebP source and a JPEG fallback, exported 1152px
wide — twice the 576px reading column, so they stay sharp on a 2× display
without upscaling the 1206px-wide simulator capture.

Crop to the content rather than shipping the whole device frame: the status
bar, the notch and the close button are noise, and the app's own ground makes a
better surround than a phone outline. From a fresh simulator capture:

```bash
magick shot.png -crop WxH+X+Y +repage -resize 1152x -strip -quality 78 assets/NAME.jpg
magick shot.png -crop WxH+X+Y +repage -resize 1152x -strip -define webp:method=6 -quality 76 assets/NAME.webp
```

Update `width`/`height` on the `<img>` to the new pixel size, so the page
reserves the right space and doesn't reflow while they load. All three are
`loading="lazy"`; they all sit below the fold.

Images carry a 1px `--rule` border. The board shots bring the app's own ground
with them and would separate from the page without one, but the create sheet is
white to its edges and dissolves into the paper otherwise; the border is on all
of them so the set stays consistent.

Quality 78 is deliberate. The generation shot is the expensive one — fine white
cut lines over canvas texture is close to the worst case for JPEG — and at 100%
it is indistinguishable from quality 82 while saving about 70KB.

## The TestFlight link

It appears twice in `index.html` — once under the subtitle, once in the footer —
and the two are identical on purpose. At launch both become "On the App Store"
pointing at the product page. Two lines, and an HTML comment above each marking
which is which.

## Things this site deliberately doesn't have

No newsletter, no roadmap, no "coming soon", no press kit, no analytics, and no
cookie banner (there are no cookies to consent to). No video either, and no
placeholder standing in for one — nothing on the page announces that something
is coming.
