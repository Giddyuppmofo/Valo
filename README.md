# Vaylo Peptides site: backend handoff

This folder is the finished front end for the Vaylo Peptides brand site. It needs
hosting, a Supabase project, and the inquiry form wired up.

## What is here

| File | What it is |
|---|---|
| `index.html` | The whole site in one file: HTML, CSS, JS and images (inlined as data URIs). Open it in a browser to see it. |
| `products.json` | The 60 catalog items as data, ready to import into Supabase. |
| `schema.sql` | Starter Supabase tables and row level security policies. |
| `assets/` | The logo, the header mark, and the vial photo with a blank label, as separate image files. |

## How the site works today

- Six views in one page (`home`, `catalog`, `quality`, `about`, `faq`, `contact`), switched by `go(name)` and the URL hash.
- The catalog is a hard-coded array `C` in the `<script>` at the bottom of `index.html`. `renderList()` draws it; `CATS` defines the filter chips.
- Product names are printed on the vial photo with CSS (`.vial b`), so one image serves every product.
- "Add to inquiry" keeps selected product ids in `picked`, saved to `localStorage` under `vayloInquiry`.
- The inquiry form (`#form`) validates, then only shows the text on screen. **Nothing is sent or stored.**
- The DNA helix is a `<canvas id="dna">` drawn by the small function near the end of the script.
- Fonts load from Google Fonts. No other external requests.

## What needs building

1. **Supabase project.** Run `schema.sql`, then import `products.json` into `products`
   (the keys match the column names).
2. **Load products from Supabase.** Replace the hard-coded `C` array with a fetch, then call
   `renderList()`. Mapping from DB rows to what the page expects:
   `slug -> id`, `residues -> t`, `contents -> parts`, `formula -> f`, `mol_weight -> mw`,
   and `category` (`peptide/other/blend/stack/supply`) `-> cat` (`pep/oth/bl/st/sup`).
3. **Save inquiries.** In the `#form` submit handler, after validation passes, insert a row:

   ```js
   // <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
   const sb = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
   const { error } = await sb.from('inquiries').insert({
     name, organization, email, message,
     product_slugs: picked,
     research_use_confirmed: true
   });
   ```

   Show a success message only when `error` is null. Remove the line that says the form
   is not connected.
4. **Notify the team.** Add a database webhook or edge function on `inquiries` inserts that
   emails the sales inbox. Add spam protection (captcha or rate limit) since inserts are public.
5. **Hosting and domain.** Any static host works (Vercel, Netlify, Cloudflare Pages).
   For production, consider moving the inlined images to files in `assets/` and splitting
   the views into real pages for SEO.

## Still open with the business

- **Prices and vial sizes** are not in the data (`size` and `price_usd` are null).
- **Checkout** is not designed. The site takes inquiries only. Many card processors
  restrict research peptide sales, so confirm the payment route before building a cart.
- **Chemistry data** (sequences, formulas, weights, CAS numbers) was written from general
  knowledge and must be checked against supplier certificates of analysis.
- **Product list and stack names** mirror sbbpeptides.com. Stack names such as
  "Fat Burner Stack" imply human use, which conflicts with the research-use-only notice.
- **Copy claims** about HPLC and mass spec testing and certificates on every lot need to
  match actual practice.
- **Legal review** of the catalog (especially semaglutide, tirzepatide, retatrutide and
  tesamorelin), the disclaimers, terms, privacy policy and any age or researcher gate.
- **Contact details** (email, address) are not on the site yet.
