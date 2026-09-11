# Sunlit garden artwork
Generated for Dopa on 2026-09-11 with the built-in image generation tool.
16 independent 3:2 WebP images, 1152×768. Combined encoded size: 1,659,642 bytes.
Files: light_0.webp…light_7.webp / dark_0.webp…dark_7.webp.
Thresholds: 0, 1, 3, 7, 14, 30, 60, 90 accumulated growth days.

Art direction: soft gouache, quiet garden, shade tree on left, open sunlit center, small growth plant on right, rounded stones and low grass. No text, buttons, faces, shiny 3D, detailed leaf veins or soil mound.
Stage progression: seed bed, two-leaf sprout, four leaves, young plant, small branches, leafy plant, buds, small flowers.
Night: same garden composition, teal foliage and moonlight; separately generated from the corresponding daylight reference.
Workflow: generate baseline → reference-edit each stage → reference-edit each night variant → inspect 16-image contact sheet → convert with official libwebp 1.6.0 cwebp (-q 85 -resize 1152 768).
Sources are generated illustrations; no prior zelkova sprite is reused.
The source PNGs and working contact sheet are development artifacts in .tooling/garden-originals and .tooling/garden-contact.png. Runtime uses only these WebPs.
Fallback is a semantic plant icon on a solid themed surface; UI text and actions remain outside the artwork.
Verification: tooling/validate_tree_assets.ps1 and Flutter tree_static_asset_contract_test.dart. Garden goldens validate final Flutter rendering.

