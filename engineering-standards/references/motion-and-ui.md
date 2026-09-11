# Reference: Motion and UI/UX

> Pillar 2. Source: `prompts.txt` #2 plus `design-motion-principles` plus the Web Interface
> Guidelines (Vercel).

## Five mandatory states (every async/dynamic UI)
1. **Skeleton/placeholder** while loading (no blank screen, no layout shift).
2. **Lazy loading**: `loading="lazy"` below the fold; `React.lazy` plus `Suspense` for heavy routes
   and components; virtualize large lists.
3. **Enter**: smooth appearance.
4. **Exit**: smooth unmount (`AnimatePresence` or equivalent), never a hard disappear.
5. **Loading and progress**: spinners on actions; bars/indicators on long operations; the submit
   button shows its sending state.

## Motion principles (design-motion-principles)
**Frequency Gate**, decide *whether* to animate before *how*:
| Frequency | Recommendation |
|---|---|
| Rare (monthly) | Expressive motion is welcome |
| Occasional (daily) | Subtle and fast |
| Frequent (hundreds/day) | No animation or instant |
| Keyboard initiated | **Never animate** |

**Durations** (by context): productivity **under 300ms (180ms ideal)**; production polish
**200ms to 500ms**; creative/playful: the duration serves the effect.

**Rules:**
- "The best animation is the one that goes unnoticed" (exception: playful/kids apps).
- **Always honor `prefers-reduced-motion`**, no exceptions.
- Animate **only `transform` and `opacity`**; **never `transition: all`**; correct
  `transform-origin`.
- Animations must be **interruptible**. **Motion Gap Analysis:** hunt for conditional renders
  without `AnimatePresence` and dynamic styles without `transition`.

**Lens per project:** productivity/SaaS uses Emil (speed) plus Jakub (polish); kids/creative uses
Jakub plus Jhey; landing uses Jakub plus Jhey; mobile/e-commerce uses Jakub plus Emil.

## Web Interface Guidelines (review checklist)
**A11y:** `aria-label` on icon only buttons; `<label>` on inputs; `<button>` for actions,
`<a>`/`<Link>` for navigation (never `<div onClick>`); `alt` on images (`alt=""` if decorative);
`aria-hidden` on decorative icons; `aria-live="polite"` on async updates; hierarchical headings plus
a skip link.
**Focus:** visible focus (`focus-visible:ring-*`), never `outline-none` without a replacement; use
`:focus-visible` and `:focus-within`; sticky elements must not obscure the focused element.
**Forms:** `autocomplete` plus `name`; correct `type`/`inputmode`; do not block paste; clickable
labels; `spellCheck={false}` on email/code/username; inline errors plus focus the first one; submit
stays enabled until the request starts; placeholders end with an ellipsis and show an example; warn
about unsaved changes.
**Typography:** use the ellipsis character (not three dots); curly quotes; non breaking spaces in
units/shortcuts/brands; loading states end with an ellipsis; `tabular-nums` in numeric columns;
`text-wrap: balance` on headings.
**Content/layout:** `truncate`/`line-clamp`/`break-words`; flex children with `min-w-0`; handle empty
states; anticipate short and long inputs.
**Images/perf:** explicit `width`/`height` (avoids CLS); `loading="lazy"` below the fold;
`priority`/`fetchpriority="high"` above; virtualize lists over 50 items; `preconnect`/`preload` for
fonts (`font-display: swap`); prefer `<video muted loop playsinline>` over GIF.
**Nav/state:** the URL reflects filters/tabs/pagination (deep link, for example nuqs); destructive
actions require confirmation or an undo window.
**Touch/dark/i18n/hydration:** `touch-action: manipulation`; `overscroll-behavior: contain` in
modals; `color-scheme` plus `theme-color`; `Intl.DateTimeFormat`/`Intl.NumberFormat`; guard date
rendering against hydration mismatch.
**Copy:** active voice; Title Case; numerals for counts; specific labels; error messages include the
next step.

## Supporting tools (see arsenal)
`design-motion-principles` (build/audit motion), `web-design-guidelines` (audit UI),
`shadcn-ui-mcp`/`21st.dev Magic` (components), `chrome-devtools-mcp` (perf/errors in a real browser).
