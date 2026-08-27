# Setting up your new profile README

Everything here goes in your **profile repo**: `github.com/sagarbangade/sagarbangade`
(the special repo whose name matches your username).

> ## ⚡ Fast path
>
> ```bash
> chmod +x publish.sh && ./publish.sh
> ```
>
> That does steps 1–2 below for you: fetches the repo, drops the files in the right
> places, commits as `sagarbangade <sagarbangade55@gmail.com>`, pushes, then checks
> whether GitHub actually attributed the commit to you. It shows a diff and asks
> before pushing, and backs up any existing README to `README.previous.md`.
>
> It has to run on **your** machine — I have no network route to GitHub
> (`github.com` doesn't even resolve DNS from my sandbox), which is also why an SSH
> key wouldn't have let me push for you.
>
> Steps 3–4 still need doing by hand in the browser afterward.

---

## 1. Drop in the README

Copy `README.md` to the root of `sagarbangade/sagarbangade` and commit. Most of it
renders immediately — the two exceptions are the snake and the 3D calendar, below.

---

## 2. Enable the contribution snake 🐍

```
sagarbangade/sagarbangade/
└── .github/
    └── workflows/
        └── snake.yml     <- copy workflows/snake.yml here
```

Then:

1. Commit and push `.github/workflows/snake.yml`.
2. Go to the repo's **Settings → Actions → General**. Under *Workflow permissions*,
   select **Read and write permissions** and save. Without this the push to the
   `output` branch fails with a 403.
3. Go to the **Actions** tab → *Generate Contribution Snake* → **Run workflow**.
4. Wait ~40 seconds. It creates an `output` branch containing
   `github-snake.svg`, `github-snake-dark.svg`, and `github-snake.gif`.
5. Refresh your profile. The snake appears, and auto-rebuilds every 12 hours.

The README embeds it with a `<picture>` element, so dark-mode visitors get the
dark palette automatically.

**If it doesn't show up:** open
`https://github.com/sagarbangade/sagarbangade/tree/output` in your browser. If
that branch doesn't exist, the workflow hasn't succeeded yet — check the Actions
tab for a red X and read the log.

---

## 3. Optional: the 3D contribution calendar 🧊

Copy `workflows/profile-3d.yml` to `.github/workflows/profile-3d.yml`, then run it
from the Actions tab once. Unlike the snake, this one commits SVGs straight into
your **main** branch at `profile-3d-contrib/`, which is why the README references
it with a relative path.

It generates several palettes. Swap the filename in the README for whichever you
prefer:

| File | Look |
|---|---|
| `profile-night-rainbow.svg` | dark bg, rainbow bars *(README default)* |
| `profile-night-view.svg` | dark bg, blue bars |
| `profile-night-green.svg` | dark bg, green bars |
| `profile-green-animate.svg` | light bg, animated |
| `profile-season-animate.svg` | light bg, seasonal colors |

If you'd rather not have a bot committing to main every night, skip this one —
the activity graph already covers similar ground.

---

## 4. Verify every link

```bash
chmod +x check-links.sh
./check-links.sh README.md
```

This curls every URL in the README and prints OK / FAIL per line.

**Please actually run this.** The environment I work in has no outbound network —
every host is blocked — so I could not test a single URL myself. The replacements
below are based on well-documented shutdown events, not live checks, and the
script is how you close that gap.

Two expected "failures" on a first run: the `raw.githubusercontent.com/.../output/*.svg`
snake URLs 404 until step 2 completes.

---

## What was broken, and why

| # | Problem | Cause | Fix applied |
|---|---|---|---|
| 1 | `readme-typing-svg.herokuapp.com` — your name banner and the `while(alive)` loop | Heroku removed free dynos on **2022-11-28**; every `*.herokuapp.com` hobby app went dark | → `readme-typing-svg.demolab.com` |
| 2 | `github-readme-streak-stats.herokuapp.com` — your streak card | Same Heroku shutdown | → `streak-stats.demolab.com` |
| 3 | Six `href="https://git.io/typing-svg"` links | GitHub **retired the `git.io` shortener in April 2022**; it no longer redirects | → link to the upstream repos directly |
| 4 | `http://github-profile-summary-cards.vercel.app/...` | Plain `http://`. GitHub proxies README images through Camo, which is unreliable on non-TLS origins | → `https://` |
| 5 | **All 25 language badges linked to `user%3ADenverCoder1`** | The badge block was copied from [DenverCoder1](https://github.com/DenverCoder1)'s profile and the search queries were never rewritten — clicking "Python" on your profile searched *his* repos | → `user%3Asagarbangade` |
| 6 | `<a href="" target="blank">` wrapping the wave GIF in your `<h1>` | Empty `href` (navigates nowhere) and `target="blank"` — a typo for `_blank`, which opens a window literally named "blank" | → removed the dead anchor |

Number 5 is the one worth knowing about. It had been quietly sending your profile
visitors to someone else's repositories.

A note on confidence: items 3–6 I verified by reading your markup, so they're
certain. Items 1–2 rest on the Heroku shutdown, which is thoroughly documented
and well before my knowledge cutoff — but the specific replacement hostnames are
from memory, so let `check-links.sh` confirm them. One encouraging signal: your
README already used `custom-icon-badges.demolab.com`, which is the same
maintainer's other project on the same domain he migrated everything to.

---

## What's new

**Content from your resume that the profile never mentioned:**

- Your current role — Software Engineer at InspironLabs, Bengaluru
- A three-row experience table with the metrics from your resume (+22% engagement, −15% UAT defects)
- Featured Work: Healthcare Platform 2.0 and the E-Learning Platform
- A contact block with email, LinkedIn, and portfolio

**Skills added** (were missing entirely): TypeScript, Next.js, Material UI, Tailwind
CSS, Redux, Storybook, Module Federation, Vite, AWS (EC2/S3/Lambda), Docker, Google
Cloud APIs, Hibernate, Serverless, REST API architecture, NLP/LLM APIs.

**Skills removed:** R, Construct 3, Audacity, Bitwarden, Brave, Dark Reader,
Discord, Inkscape, OBS, Photopea, SonarLint, Stack Overflow, Arch Linux, Android
Studio, Adobe, Google Sheets, Dbeaver. A browser and a password manager aren't
engineering skills, and a 40-badge wall of them buries the ones that matter. If
you want any back, they're one line each.

**New widgets:**

| Widget | Setup |
|---|---|
| Contribution snake (`Platane/snk`) | workflow required |
| skillicons.dev icon rows | none |
| Activity graph | none |
| 3D contribution calendar | workflow required, optional |
| Repo pin cards | none — commented template in the README |
| Profile summary cards (5 cards, collapsible) | none |

---

## Two things to double-check

**The snake action version.** I pinned `Platane/snk@v3`, which was current as of my
knowledge cutoff. If the workflow errors with something like *"unable to resolve
action"*, check the [repo](https://github.com/Platane/snk) for the current major
version and bump it.

**Rate limits on `github-readme-stats`.** The shared Vercel instance is popular
enough to get throttled, so cards occasionally render as an error box. If it
bothers you, [deploy your own instance](https://github.com/anuraghazra/github-readme-stats#deploy-on-your-own)
— it's a two-minute Vercel import — and swap the hostname.

---

## Tuning it

- **Theme color** is `FE3C01` (your orange) with `e6b400` text and `DDDAD5` borders.
  Find-and-replace to change the whole palette at once.
- **Typing lines** live in the `lines=` param of the two `readme-typing-svg` URLs,
  `;`-separated and URL-encoded (`+` for space, `%7C` for `|`).
- **The `<details open>`** on the detailed skills section starts expanded. Remove
  `open` to have it collapsed by default.
- **GIFs** are the heaviest thing in the file. If your profile feels slow, the
  footer trio is the first thing to cut.
