# Pink Flag Website Build Prompt

**Domain**: pinkflag.us
**Purpose**: Marketing website to drive mobile app downloads for Pink Flag safety app
**Target Audience**: Women seeking personal safety tools and offender registry information
**Design Philosophy**: Sleek minimalism with feminine pink accents - think Apple-style clean design with strategic pink gradient touches

---

## Project Overview

Build a **minimalist, elegant** marketing website for Pink Flag - a women's safety app that provides easy access to public offender registry searches. The website should embody sleek simplicity with strategic feminine pink accents. Clean, uncluttered, sophisticated.

**Current Status**: App launching soon - implement pre-launch email capture with "Coming Soon" app store badges.

**Design Inspiration**: Apple.com minimalism + subtle pink gradients. Lots of whitespace, clean typography, strategic use of color.

---

## Design Philosophy: Minimalist Elegance

### Core Principles
1. **Whitespace is Your Friend**: Generous spacing between all elements. Never cram content.
2. **Less is More**: Show only what matters. Remove anything unnecessary.
3. **Pink as Accent, Not Dominant**: Use pink strategically for CTAs, highlights, and accents. Let white/soft backgrounds dominate.
4. **Clean Typography**: Large, readable text with plenty of breathing room.
5. **Simple Layouts**: One clear focus per section. No busy grids.
6. **Subtle Animations**: Smooth, understated. No excessive motion.
7. **Quality Over Quantity**: One great hero section beats five mediocre sections.

### Visual Balance
- **Backgrounds**: Mostly white or very subtle gradients (95% white, 5% pink)
- **Accents**: Pink used sparingly for buttons, underlines, icons
- **Content**: Short, punchy copy. No walls of text.
- **Spacing**: Double what you think you need.

---

## Technical Stack Requirements

**Recommended**: Next.js 14+ with TypeScript, Tailwind CSS, Framer Motion
**Why**: SEO optimization, performance, modern subtle animations, easy deployment to Vercel

**Required Features**:
- Server-side rendering for SEO
- Responsive design (mobile-first)
- Fast page load times (<1.5s)
- Smooth, subtle scroll animations
- Email capture integration (suggest Mailchimp or ConvertKit)
- Contact form with validation
- Google Analytics ready
- Open Graph meta tags for social sharing

---

## Design System (Match Mobile App, Applied Minimally)

### Color Palette
**Use sparingly** - these are accent colors, not dominant colors

**Primary Colors**:
- Primary Pink: `#EC4899` (rgb(236, 72, 153)) - CTAs, hover states
- Deep Pink: `#DB2777` (rgb(219, 39, 119)) - Gradients, emphasis
- Light Pink: `#FCE7F3` (rgb(252, 231, 243)) - Subtle backgrounds
- Soft Pink: `#FBCFE8` (rgb(251, 207, 232)) - Very subtle accents
- Soft White: `#FFFAF5` (rgb(255, 250, 245)) - Main background

**Text Colors**:
- Dark Text: `#374151` (rgb(55, 65, 81)) - Primary text
- Medium Text: `#6B7280` (rgb(107, 114, 128)) - Secondary text
- Light Text: `#9CA3AF` (rgb(156, 163, 175)) - Captions

**Background Strategy**:
- **90% of page**: White (`#FFFFFF`) or Soft White (`#FFFAF5`)
- **10% of page**: Subtle pink accents and gradients
- **CTAs only**: Bold pink gradients

### Gradients (Use ONLY for CTAs and Hero)
```css
/* Primary Pink Gradient - CTAs ONLY */
background: linear-gradient(135deg, #EC4899 0%, #DB2777 100%);

/* Subtle Hero Background - Very subtle, almost invisible */
background: linear-gradient(180deg, #FFFFFF 0%, #FFFAF5 50%, #FCE7F3 100%);

/* Accent Line - For subtle dividers or underlines */
background: linear-gradient(90deg, #EC4899 0%, #FDA4AF 100%);
```

### Typography
**Fonts**: Use Google Fonts
- **Headings**: Poppins (600, 700 weights only)
- **Body**: Inter (400, 500 weights only)

**Type Scale** (Generous line heights for minimalism):
- Display: 64px / 4rem (hero only), line-height: 1.1
- H1: 48px / 3rem, line-height: 1.2
- H2: 32px / 2rem, line-height: 1.3
- H3: 24px / 1.5rem, line-height: 1.4
- Body Large: 20px / 1.25rem, line-height: 1.6
- Body Medium: 18px / 1.125rem, line-height: 1.6
- Body Small: 16px / 1rem, line-height: 1.5

**Typography Rules**:
- Maximum 12 words per headline
- Maximum 20 words per description
- Generous letter spacing on headings (0.02em)
- Never use more than 3 lines of body text in a row without a break

### Spacing (Generous - Double the Standard 8pt Grid)
- sm: 16px (minimum spacing)
- md: 32px (between related elements)
- lg: 48px (between subsections)
- xl: 64px (between sections)
- 2xl: 96px (between major sections)
- 3xl: 128px (hero section padding)

**Key Spacing Rule**: When in doubt, add more space.

### Border Radius (Minimal, modern)
- sm: 8px (buttons, inputs)
- md: 12px (cards - use sparingly)
- lg: 16px (large cards - rare)

### Shadows (Ultra subtle)
```css
/* Barely-there shadow - use sparingly */
box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);

/* Button hover - subtle pink glow */
box-shadow: 0 4px 12px rgba(236, 72, 153, 0.15);
```

### Animations (Subtle, sophisticated)
- Page transitions: 400ms, ease-out
- Button hover: 200ms, ease
- Scroll reveals: Fade in only, no slides (600ms)
- NO pulse animations
- NO bouncing
- NO excessive motion

---

## Site Structure & Pages

### 1. Homepage (`/`) - MINIMALIST STRUCTURE

Keep it simple: Hero + 3 Features + App Preview + Email Capture + Final CTA

---

#### Hero Section (Above Fold) - FULL VIEWPORT
**Layout**: Full viewport height, centered content, maximum whitespace

**Content**:
- **Headline** (center, large): "Your Safety, Your Power"
- **Subheadline** (center, 1 line): "Search public registries. Stay informed. Feel safe."
- **Single CTA**: One large "Get Early Access" button (pink gradient)
- **Visual**: Single iPhone mockup (centered, large, showing splash or search screen)
- **Background**: Pure white with barely-visible gradient at bottom (white → soft white)

**What NOT to include**:
- ❌ No secondary button
- ❌ No "Learn More" button
- ❌ No floating shapes
- ❌ No busy backgrounds

**Animation**: Simple fade-in on load (800ms)

---

#### Features Section - MINIMAL (3 Features Only)
**Headline** (center): "Everything You Need"
**Subheadline**: "Nothing You Don't"

**Layout**: 3 columns on desktop (wide spacing), stack on mobile

**3 Features** (icon + title + 1 sentence):

1. **Search**
   - Icon: Simple magnifying glass (pink outline, white fill)
   - Title: "Instant Search"
   - Description: "Search registries by name or location in seconds"

2. **Privacy**
   - Icon: Simple lock (pink outline, white fill)
   - Title: "100% Private"
   - Description: "Your searches are never stored or shared"

3. **Resources**
   - Icon: Simple shield (pink outline, white fill)
   - Title: "24/7 Support"
   - Description: "Emergency contacts and safety resources always available"

**Styling**:
- Icons: Large (64px), outlined in pink, lots of whitespace around
- No cards, no backgrounds
- Just icon, title, description
- Tons of whitespace between features (96px minimum)

**Background**: Pure white

---

#### App Preview Section - CLEAN
**Layout**: Phone mockup (large, centered) + minimal text

**Content**:
- **Headline** (center): "Beautiful. Simple. Safe."
- **Phone Mockup**: Single large iPhone showing search screen
  - No carousel (too busy)
  - Static image, high quality
  - Subtle drop shadow
- **No description needed** - let the image speak

**Background**: Very subtle gradient (white → soft pink, almost invisible)

---

#### Email Capture Section - FOCUSED
**Layout**: Centered, minimal

**Content**:
- **Headline** (center): "Join the Waitlist"
- **Subheadline**: "Be first to download when we launch"
- **Email Form**:
  - Single email input (large, clean, white with thin pink border)
  - Large "Get Early Access" button (pink gradient, full width on mobile)
  - Small privacy note: "We respect your privacy. Unsubscribe anytime."

**NO incentives text** (like "30 days free") - keep it clean

**Background**: White with subtle pink gradient border around the section (optional, very subtle)

---

#### Final CTA Section - SIMPLE
**Layout**: Centered, short

**Content**:
- **Headline**: "Coming Soon"
- **App Store Badges**: Apple + Google Play (standard, official badges)
  - "Coming Soon" overlay
  - Clicking opens email capture modal

**Background**: Pure white

---

### 2. Features Page (`/features`) - SIMPLIFIED

**Structure**:
1. **Hero**: "Your Safety Companion" + 1 sentence
2. **3 Main Features** (expanded):
   - Each gets its own section with phone screenshot + description
   - Alternating layout (image left, text right / text left, image right)
   - Lots of whitespace between sections
3. **CTA**: Email capture

**No "Coming Soon" section** - keep focus on core features

---

### 3. Resources Page (`/resources`) - CLEAN LIST

**Structure**:
1. **Hero**: "Resources" + 1 sentence
2. **Emergency Contacts** - Simple list:
   - 911
   - Domestic Violence Hotline: 1-800-799-7233
   - RAINN Sexual Assault Hotline: 1-800-656-4673
   - National Suicide Prevention: 988
   - Crisis Text Line: Text HOME to 741741
3. **Safety Tips** - Numbered list (7 tips, concise)
4. **CTA**: Email capture

**Styling**: Clean list, no cards, no busy layouts. Just text with good typography.

---

### 4. Privacy Policy Page (`/privacy`)
**Styling**: Clean, readable, simple two-column layout (nav on left, content on right) on desktop

### 5. Terms of Service Page (`/terms`)
**Styling**: Same as Privacy - clean and simple

### 6. FAQ Page (`/faq`)
**8 Questions** (not 12 - keep it minimal):
1. What is Pink Flag?
2. How does Pink Flag get its data?
3. Is my search history saved?
4. When will the app launch?
5. What platforms is Pink Flag available on?
6. Is my data secure?
7. How accurate is the data?
8. How do I contact support?

**Styling**: Simple accordion, clean typography, no search bar (unnecessary for 8 questions)

---

### 7. Contact Page (`/contact`)

**Content** (centered, minimal):
- **Headline**: "Get in Touch"
- **Form** (clean, simple):
  - Name
  - Email
  - Message (no subject dropdown - keep it simple)
  - Submit button (pink gradient)
- **Email**: hello@pinkflag.us
- Response time: "We typically respond within 24 hours"

**NO social media links** (unless you have them) - keep it focused

---

## Shared Components

### Navigation Header - MINIMAL
**Desktop**:
- Logo (left): "Pink Flag" text only (no icon needed in nav)
- Nav links (right): Features · Resources · FAQ · Contact
  - Use · (middle dot) as separator for cleaner look
  - Simple hover: pink underline
- NO CTA button in nav (too busy)

**Mobile**:
- Logo (left)
- Hamburger (right, simple three-line icon)
- Full-screen overlay menu (not slide-out) with large text

**Behavior**:
- Transparent initially
- Becomes white with subtle shadow on scroll
- Sticky

**Styling**: Clean, simple, lots of whitespace in header

---

### Footer - MINIMAL (2 Columns)
**Layout**: 2 columns on desktop, stacked on mobile

**Column 1 - Links**:
- Features
- Resources
- FAQ
- Contact
- Privacy Policy
- Terms of Service

**Column 2 - Brand**:
- Pink Flag logo (simple)
- Tagline: "Your Safety, Your Power"
- Copyright: "© 2025 Pink Flag"

**Styling**:
- White background
- Thin pink line at top (1px)
- Minimal padding
- Small text (14px)

**NO**:
- ❌ Social media icons (unless you have them)
- ❌ "Made with 💗" text (too cutesy for minimalist design)
- ❌ Gradient backgrounds (keep it clean)

---

### Email Capture Modal - CLEAN
**Trigger**: Clicking any "Get Early Access" or app store badges

**Content** (centered):
- **Headline**: "Join the Waitlist"
- **Email input** (large, clean)
- **Submit button**: "Continue"
- **Close button**: Simple X (top right)

**Success State**:
- Simple checkmark icon (pink)
- "You're on the list!"
- "Check your email to confirm"
- NO confetti (too busy)

**Styling**: White modal, centered, subtle shadow, clean close X

---

### App Store Badges
**Design**: Standard official badges only
- Apple App Store badge
- Google Play badge
- Clean "Coming Soon" text overlay (not badge)

---

## Copy & Messaging Guidelines

### Voice & Tone - MINIMALIST
- **Concise**: Maximum 12 words per headline
- **Clear**: No flowery language
- **Direct**: Get to the point
- **Confident**: No excessive reassurance
- **Simple**: 8th-grade reading level

### Example Headlines (Good vs Bad)

**Good** (Minimalist):
- "Your Safety, Your Power"
- "Search. Stay Safe."
- "Everything You Need"
- "Join the Waitlist"

**Bad** (Too wordy):
- "Empowering Women Everywhere to Take Control of Their Personal Safety"
- "The Most Comprehensive Safety Companion App Designed Specifically for Women"
- "Be the First to Know When Pink Flag Launches and Get Exclusive Early Access"

### Key Messages (Keep Short)
1. "Your searches are never stored"
2. "Search registries nationwide"
3. "Designed for women"

---

## SEO Requirements

### Meta Tags (Every Page)
```html
<title>Pink Flag - Women's Safety App</title>
<meta name="description" content="Search public offender registries, access safety resources, and stay informed. Coming soon to iOS and Android.">

<!-- Open Graph -->
<meta property="og:title" content="Pink Flag - Your Safety, Your Power">
<meta property="og:description" content="Women's safety app. Coming soon.">
<meta property="og:image" content="https://pinkflag.us/og-image.png">
<meta property="og:url" content="https://pinkflag.us">
```

### Target Keywords
- Women's safety app
- Offender registry search
- Personal safety app
- Dating safety

---

## Performance Requirements

### Speed Targets (Critical for Minimalist Feel)
- Lighthouse Score: 95+ for all categories
- First Contentful Paint: <1s
- Time to Interactive: <2s
- Total page size: <500KB

### Optimization
- Minimal JavaScript
- WebP images only
- Lazy load below fold
- No heavy animations
- Single font weights only (400, 600 for each family)

---

## Responsive Design Breakpoints

```css
/* Mobile First */
- mobile: 0-768px
- desktop: 769px+
```

**Keep it simple** - just two breakpoints

### Mobile Considerations
- Even MORE whitespace on mobile
- Larger tap targets (min 48px)
- Single column layouts only
- Large, readable text (18px minimum)

---

## Animation & Interaction Details - MINIMAL

### Scroll Animations
- **Fade in only** as elements enter viewport (no sliding)
- Duration: 600ms
- Ease: ease-out
- NO stagger delays (too busy)

### Button Interactions
- Subtle scale to 0.98 on press (200ms)
- Gentle glow on hover (pink shadow, 200ms)
- NO ripple effects
- NO loading spinners (use simple text: "Sending...")

### Page Transitions
- Simple fade (300ms)
- Smooth scroll to anchors
- NO complex transitions

---

## Accessibility Requirements

- WCAG 2.1 Level AA compliance
- Semantic HTML5
- Proper ARIA labels
- Keyboard navigation
- Pink focus indicators (simple outline)
- Alt text for all images
- 4.5:1 contrast ratio minimum

---

## Integration Requirements

### Email Capture
**Recommended**: ConvertKit (clean, simple)

**Fields**: Email only (no name - keep it simple)

**Follow-up**:
- Welcome email
- Launch announcement

### Analytics
**Required**: Google Analytics 4

**Track**:
- Page views
- Email signups
- Button clicks

### Contact Form
**Recommended**: Formspree (simple integration)

---

## Assets Needed - MINIMAL

### Images (Quality Over Quantity)
1. **App Mockups**:
   - 1-2 high-quality iPhone mockups (transparent background)
   - Professional, clean, high-res

2. **Icons**:
   - 3 simple icons (search, lock, shield)
   - Outlined style, pink stroke
   - SVG format
   - Favicon (simple pink flag)

3. **Graphics**:
   - OG image (1200x630px) - simple, clean
   - NO background shapes
   - NO decorative elements

### Branding
1. Logo:
   - SVG wordmark (simple, clean typography)
   - Pink or black versions only
   - NO complex logo needed

2. App Store badges:
   - Official Apple badge
   - Official Google Play badge

---

## Launch Checklist - ESSENTIALS ONLY

### Pre-Launch
- [ ] Domain connected (pinkflag.us)
- [ ] SSL active
- [ ] Email capture working
- [ ] Mobile responsive
- [ ] Google Analytics installed
- [ ] Page load under 1.5s

### Content
- [ ] All copy proofread
- [ ] Legal pages reviewed
- [ ] Images optimized
- [ ] Alt text added

---

## Deployment

**Platform**: Vercel (recommended for Next.js)

**Setup**:
1. Connect GitHub repo
2. Configure domain (pinkflag.us)
3. Enable auto-deploy
4. Done

---

## What NOT to Include (Critical for Minimalism)

### ❌ Remove These Elements:
- Testimonials section (you don't have them yet)
- Social media icons (unless you have active accounts)
- "Made with 💗" footer text
- Floating background shapes
- Parallax effects
- Carousels (use single static image)
- Feature icons with backgrounds/cards
- Multiple CTA buttons per section
- Excessive animations
- Decorative elements
- "Coming Soon Features" section
- Blog/articles section
- Stats/numbers section
- Video backgrounds
- Complex gradients everywhere

### ✅ Keep Only:
- Essential navigation
- One hero section
- Three features (maximum)
- One app preview
- One email capture
- Simple footer
- Legal pages (required)

---

## Example Homepage Structure (HTML) - MINIMAL

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Pink Flag - Women's Safety App</title>
  <!-- Minimal head tags -->
</head>
<body>
  <!-- Minimal Navigation -->
  <header>
    <nav>
      <div>Pink Flag</div>
      <div>Features · Resources · FAQ · Contact</div>
    </nav>
  </header>

  <!-- Hero Section -->
  <section id="hero">
    <h1>Your Safety, Your Power</h1>
    <p>Search public registries. Stay informed. Feel safe.</p>
    <button>Get Early Access</button>
    <img src="iphone-mockup.png" alt="Pink Flag App">
  </section>

  <!-- Features Section -->
  <section id="features">
    <h2>Everything You Need</h2>
    <p>Nothing You Don't</p>
    <div class="features-grid">
      <!-- 3 simple features -->
    </div>
  </section>

  <!-- App Preview Section -->
  <section id="preview">
    <h2>Beautiful. Simple. Safe.</h2>
    <img src="app-screenshot.png" alt="App Preview">
  </section>

  <!-- Email Capture Section -->
  <section id="waitlist">
    <h2>Join the Waitlist</h2>
    <p>Be first to download when we launch</p>
    <form>
      <input type="email" placeholder="Enter your email">
      <button>Get Early Access</button>
    </form>
    <p class="privacy">We respect your privacy. Unsubscribe anytime.</p>
  </section>

  <!-- Final CTA Section -->
  <section id="cta">
    <h2>Coming Soon</h2>
    <div class="badges">
      <!-- App store badges -->
    </div>
  </section>

  <!-- Minimal Footer -->
  <footer>
    <div>
      <a href="/features">Features</a>
      <a href="/resources">Resources</a>
      <a href="/faq">FAQ</a>
      <a href="/contact">Contact</a>
      <a href="/privacy">Privacy Policy</a>
      <a href="/terms">Terms of Service</a>
    </div>
    <div>
      <p>Pink Flag</p>
      <p>Your Safety, Your Power</p>
      <p>© 2025 Pink Flag</p>
    </div>
  </footer>

  <!-- Email Capture Modal (hidden) -->
  <div id="modal">
    <h3>Join the Waitlist</h3>
    <input type="email" placeholder="Enter your email">
    <button>Continue</button>
  </div>
</body>
</html>
```

---

## Success Metrics to Track

**Pre-Launch**:
- Email signups
- Bounce rate
- Time on site

**Post-Launch**:
- Download conversions
- Waitlist → Download rate

---

## Final Notes - MINIMALISM CHECKLIST

### Before You Build, Ask:
1. Can I remove this element? (If yes, remove it)
2. Can I reduce this text? (If yes, cut it in half)
3. Can I add more whitespace? (Always yes)
4. Is this animation necessary? (Usually no)
5. Does this element serve the core goal? (If no, delete it)

### Design Mantras:
- **"When in doubt, leave it out"**
- **"Whitespace is not wasted space"**
- **"One thing per section"**
- **"Pink is an accent, not a theme"**
- **"Less elements, more impact"**

### The Final Test:
If the website feels busy, cluttered, or overwhelming → **remove 50% of elements**

---

## Inspiration References

Look at these for minimalist inspiration:
- Apple.com (product pages)
- Stripe.com (homepage)
- Linear.app (clean SaaS design)
- Cash.app (simple, effective)

Take their minimalist approach, add subtle pink accents.

---

**Build with restraint. Every element should earn its place. 🎯**

*P.S. Resist the urge to add "just one more thing." The power of this design is in what we DON'T show.*
