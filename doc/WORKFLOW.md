# The FlutterForge AI Workflow

A step-by-step demo you can record to produce `doc/images/hero.gif` and the supporting screenshots referenced in the README.

---

## Recording script (≈ 30 seconds)

| Step | What the viewer sees                                                                    | Suggested screen label    |
| ---- | --------------------------------------------------------------------------------------- | ------------------------- |
| 1    | Example app running, purple FAB bottom-left, green 🤖 FAB bottom-right.                 | **Normal runtime**        |
| 2    | You tap "Load users" → a Dio request fires and a list of 10 users renders.              | **Live API + DB**         |
| 3    | You tap "Trigger error" → a red snackbar appears; a log row is captured.                | **Automatic error capture** |
| 4    | You tap the purple FAB → the 4-tab **FlutterForge DevTools** dashboard opens.           | **DevTools dashboard**    |
| 5    | You scrub through each tab: **Database → API → State → Logs**.                          | **Everything in one place** |
| 6    | You tap the 🤖 FAB → the snapshot preview screen opens with "Copy AI prompt" CTA.       | **AI-ready snapshot**     |
| 7    | You type `"Login loop after OAuth refresh"` into the problem field.                     | **Context-rich prompt**   |
| 8    | You tap **Copy AI prompt** → snackbar confirms copy.                                    | **One-tap export**        |
| 9    | Cut to ChatGPT / Claude / Cursor; paste; AI responds with a targeted fix.               | **30-second fix**         |

Recommended length: **25–35 s**, no voiceover, subtitles baked in.

---

## Recording tools

**macOS**
- Screen recording: `Cmd ⇧ 5` → Record Selected Portion.
- GIF conversion: `brew install gifsicle ffmpeg`, then:
  ```bash
  ffmpeg -i hero.mov -vf "fps=12,scale=960:-1:flags=lanczos" -c:v pam -f image2pipe - \
    | convert -delay 8 - gif:- | gifsicle --optimize=3 > doc/images/hero.gif
  ```

**Windows / Linux**
- [ScreenToGif](https://www.screentogif.com/) (Windows) or [peek](https://github.com/phw/peek) (Linux).

**Target size**
- Hero GIF: ≤ 5 MB, ≤ 12 FPS, 720–960 px wide.
- Still screenshots: PNG, 2× Retina if possible, cropped tight.

---

## File layout

```
doc/images/
├── hero.gif        # 30-second workflow
├── dashboard.png   # 4-tab DevTools dashboard
├── api.png         # API Inspector — call list + detail view
└── snapshot.png    # Snapshot preview with "Copy AI prompt"
```

The README embeds these paths directly — drop the files in and they render on GitHub and pub.dev.

---

## Scripted demo app taps

The example under [`example/`](../example) is pre-wired for the script above. From `flutter run -d chrome` (or any device):

1. Wait for the splash → you should see the app bar "FlutterForge Example" and three action buttons.
2. Tap **Load users** — a GET to `jsonplaceholder.typicode.com/users` fires; 10 rows appear.
3. Tap **Trigger error** — throws a `StateError`, caught in the UI handler, logged via `FFLogger.error`.
4. Tap the **purple FAB** (bottom-left).
5. Swipe across tabs; the State and Logs tabs both contain events from steps 2–3.
6. Close the dashboard; tap the **green 🤖 FAB** (bottom-right).
7. Type a symptom, tap **Generate snapshot**, then **Copy AI prompt**.
8. Paste into any AI assistant.

That's the full loop — no extra setup required.
