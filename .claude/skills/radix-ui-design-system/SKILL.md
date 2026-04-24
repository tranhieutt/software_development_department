---
name: radix-ui-design-system
type: reference
description: "Provides Radix UI patterns for building accessible design systems with headless components, theming, and compound component architecture. Use when building UI with Radix UI primitives or when the user mentions Radix UI, headless components, or accessible component libraries."
paths: ["**/*.tsx", "**/*.jsx", "**/components.json"]
when_to_use: "When building accessible component libraries with Radix UI primitives, headless components, or design system theming"
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
user-invocable: true
effort: 3
---

# Radix UI Design System

## Critical rules (non-obvious)

- **Always use `asChild`** on Trigger/Close â€” prevents nested `<button>` inside `<button>` DOM errors
- **Always include `<Dialog.Title>` and `<Dialog.Description>`** â€” screen readers require them; omitting causes a11y violations
- **Never mix controlled + uncontrolled** â€” don't use both `defaultValue` and `value` on same component
- **Animations need `forceMount`** â€” without it Portal unmounts instantly, killing Framer Motion exit animations
- **Dropdown positioning off?** â€” parent has `overflow: hidden` or CSS transform; always wrap in `<Portal>`

## Core pattern: Dialog

```tsx
<Dialog.Root open={open} onOpenChange={setOpen}>
  <Dialog.Trigger asChild><button>Open</button></Dialog.Trigger>
  <Dialog.Portal>
    <Dialog.Overlay className="overlay" />
    <Dialog.Content className="content">
      <Dialog.Title>Title</Dialog.Title>       {/* required */}
      <Dialog.Description>Desc</Dialog.Description> {/* required */}
      <Dialog.Close asChild><button>Close</button></Dialog.Close>
    </Dialog.Content>
  </Dialog.Portal>
</Dialog.Root>
```

## Theming: CSS variables (recommended)

```css
:root { --color-primary: 220 90% 56%; --radius: 0.5rem; }
[data-theme="dark"] { --color-primary: 220 90% 66%; }
```
```tsx
<Dialog.Content className="bg-[hsl(var(--color-primary))] rounded-[var(--radius)]" />
```

## Theming: CVA for variants

```tsx
import { cva } from 'class-variance-authority';
const button = cva("base-styles", {
  variants: {
    variant: { default: "bg-primary", destructive: "bg-red-500" },
    size: { sm: "h-9 px-3", md: "h-10 px-4" },
  },
  defaultVariants: { variant: "default", size: "md" },
});
```

## Animation with Framer Motion

```tsx
<Dialog.Portal forceMount>           {/* forceMount: critical */}
  <AnimatePresence>
    {open && (
      <Dialog.Overlay asChild>
        <motion.div initial={{opacity:0}} animate={{opacity:1}} exit={{opacity:0}} />
      </Dialog.Overlay>
    )}
  </AnimatePresence>
</Dialog.Portal>
```

## Hook form integration (Select)

```tsx
<Controller name="country" control={control} render={({ field }) => (
  <Select.Root onValueChange={field.onChange} value={field.value}>
    <Select.Trigger><Select.Value placeholder="Select..." /><Select.Icon /></Select.Trigger>
    <Select.Portal>
      <Select.Content><Select.Viewport>
        <Select.Item value="us"><Select.ItemText>US</Select.ItemText></Select.Item>
      </Select.Viewport></Select.Content>
    </Select.Portal>
  </Select.Root>
)} />
```

## Primitives quick reference

| Component    | Key parts |
|---|---|
| Dialog       | Root Â· Trigger Â· Portal Â· Overlay Â· Content Â· Title Â· Description Â· Close |
| DropdownMenu | Root Â· Trigger Â· Portal Â· Content Â· Item Â· Separator Â· CheckboxItem Â· RadioGroup Â· Sub |
| Tabs         | Root Â· List Â· Trigger Â· Content |
| Tooltip      | Provider Â· Root Â· Trigger Â· Portal Â· Content Â· Arrow |
| Select       | Root Â· Trigger Â· Value Â· Icon Â· Portal Â· Content Â· Viewport Â· Item Â· ItemText Â· ItemIndicator |

## shadcn vs raw Radix

- **shadcn**: quick prototyping, standard designs; run `npx shadcn@latest add dialog`
- **Raw Radix**: full customization, unique designs, zero-dependency component library
