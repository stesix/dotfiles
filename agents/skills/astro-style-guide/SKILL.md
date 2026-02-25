# Astro Styling Best Practices (for LLM agents)

Source: https://docs.astro.build/en/guides/styling/

## Goal
Agent-only checklist for producing maintainable Astro UI code with correct scoping, import order, and predictable CSS behavior.
Applies to `.astro` components, layouts, and Markdown layouts (not a general CSS primer).
Execution contract: apply rules silently; only explain when the user explicitly asks.

## Core rules
- Default to scoped `<style>` in `.astro` components; it prevents leaks and allows low-specificity selectors.
- Use `<style is:global>` only for site-wide CSS, typically in layouts or dedicated global files.
- Prefer `:global()` inside a scoped `<style>` when you need to target children or slotted content.
- Use `class:list` to compose dynamic classes in `.astro` templates.
- Use `define:vars` for CSS variables derived from component frontmatter.
- Do not assume `class` props pass through to child components; accept `class` explicitly and spread `...rest` on the outermost element for the default scoped style strategy (not required if `scopedStyleStrategy` is `class` or `where`).
  - When combining `class:list` and `class`, include the prop in the list to avoid clobbering.
- Scoped styles do not apply to child components; wrap children in a styled element when needed.
- Avoid placing `<style is:global>` in leaf components unless required.
- Avoid using `:global()` for component root styling unless required.

## Decision flow (scoping)
- Style only this component? Use scoped `<style>`.
- Style slotted/child content from this component? Use `:global()` inside scoped `<style>`.
- Style the whole site or Markdown defaults? Use `<style is:global>` in a layout.

## When to ask
- If the project already uses a global CSS strategy or design system, follow it.
- If the component intentionally blocks `class` passthrough, document why.

## Micro examples
- Pass through `class`:
  ```astro
  ---
  const { class: className, ...rest } = Astro.props;
  ---
  <div class={className} {...rest} />
  ```
- Inline styles:
  ```astro
  <p style={{ color: "brown", textDecoration: "underline" }}>Text</p>
  ```
- Combine `class:list` with `class`:
  ```astro
  ---
  const { class: className } = Astro.props;
  ---
  <div class:list={[className, 'card', isActive && 'is-active']} />
  ```
- Scoped + `:global()` for child content:
  ```astro
  <style>
    article :global(h2) { margin-top: 2rem; }
  </style>
  ```

## External styles
- Import local stylesheets in frontmatter with ESM `import` at the top of the script.
- For package styles that omit extensions (e.g., `package-name/styles`), add the package to `vite.ssr.noExternal`.
- Use `<link>` for `/public` assets or external URLs when you intentionally want to skip Astro processing, bundling, and optimization.
  - `<link>` hrefs must be absolute (no relative paths).

## Cascade and precedence
- Precedence order: `<link>` in `<head>` (lowest), imported styles, scoped `<style>` (highest).
- When importing multiple CSS files in the same file, later imports win if specificity is equal.
- Side-effect global CSS imports apply even if the component is not rendered; avoid in leaf components.
- For shared global styles, import them in the layout (not in leaf components).
- Keep style imports at the very top of frontmatter for predictability.
- Keep selector specificity low; scoped styles already add attribute selectors.

## Markdown styling
- Style Markdown via the layout: import CSS or use `<style is:global>` in the layout.
- If using Tailwind, use the typography plugin for Markdown-rich pages.

## Tailwind guidance
- Astro >= 5.2: use `astro add tailwind` to install Tailwind 4 Vite plugin.
- Tailwind 4 usage: `@import "tailwindcss";` in a global CSS file and import that file in the layout.
- Legacy Tailwind 3: keep `@astrojs/tailwind` integration and `tailwindcss@3` only for Tailwind 3 compatibility.
- If the project already uses Tailwind 3, do not upgrade; follow the existing setup.
- Astro < 5.2: add `@tailwindcss/vite` manually per Tailwind docs.

## Preprocessors and PostCSS
- Use `<style lang="scss|sass|less|styl|stylus">` after installing the corresponding package.
- LightningCSS: set `vite.css.transformer = "lightningcss"` after installing `lightningcss`.
- Configure PostCSS with `postcss.config.cjs` and `require()` plugin imports.

## Production behavior
- Astro inlines small CSS chunks (default 4kB) and links larger ones.
- Adjust `vite.build.assetsInlineLimit` or `build.inlineStylesheets` if you need consistent inlining/linking.

## Exceptions (document why)
- `?raw` and `?url` CSS imports bypass Astro optimizations; use sparingly and document why.
- Use `?raw` or `?url` only when you need to bypass Astro’s CSS handling and take full control.
- If using `?url`, beware of data URL inlining; set `vite.build.assetsInlineLimit = 0` if needed.
- Add a one-line comment on the import explaining the exception.

## Common mistakes
- Importing global CSS in leaf components.
- Forgetting to pass `class` and `...rest` to a root element.
- Putting style imports after other frontmatter code.

## Quick checklist (agent)
- Scoped styles by default
- Global styles only when necessary
- Imports at top of frontmatter
- Layout owns global CSS
- Use `class:list`, `define:vars`, and explicit `class` props correctly
- Verify global CSS ordering if a layout changed
