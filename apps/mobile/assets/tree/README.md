# Dopa zelkova fallback assets

These two sprite sheets are the production fallback for the tree companion
renderer while the commissioned Rive source is unavailable or disabled.

## Runtime contract

- Canvas: `1536 x 1024`
- Grid: four columns by two rows
- Cell: `384 x 512`
- Order, row-major: `seed`, `sprout`, `sapling`, `smallTree`,
  `youngZelkova`, `spreadingBranches`, `broadCanopy`, `mature`
- Thresholds: `0`, `1`, `3`, `7`, `14`, `30`, `60`, `90` growth days
- Every stage is fully contained inside its own cell. Artwork must not cross
  `x=384`, `x=768`, `x=1152`, or `y=512`; this prevents adjacent-stage bleed
  when Flutter clips the selected frame.
- Backgrounds are intentionally opaque and matched to the Dopa light and dark
  surfaces. Do not color-key or attempt runtime alpha extraction.

## Generation record

Built-in OpenAI image generation was used on 2026-08-27. The final prompt was:

> Create a production-ready opaque RGB 1536x1024 sprite sheet with eight
> independent 384x512 cells. Center one healthy Korean zelkova growth stage in
> each cell in row-major order, keep every visible leaf, branch, root, soil
> mound, highlight, and shadow inside that cell, and use a premium calm 2.5D
> hand-painted botanical diorama style. Use a uniform Dopa cream background,
> muted sage foliage, restrained warm new-leaf tips, consistent camera and
> lighting, and no text, guides, rewards, dead vegetation, transparency, or
> watermark.

A theme edit replaced the cream backdrop with the Dopa charcoal-green surface
and regraded the same geometry for low-contrast moonlit sage foliage. The final
Light and Dark sheets were visually checked for cell-boundary bleed before
being copied into the app.

These files are fallback raster art, not the editable Rive deliverable. The
Rive contract and art handoff requirements live in the tree companion feature
documentation.
