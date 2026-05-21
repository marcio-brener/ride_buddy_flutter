# Feature Specification — Registro Rápido (Quick Registration with Templates)

**Project:** ride_buddy_flutter
**Author:** Spec drafted for William Spada
**Date:** 2026-05-21
**Status:** Proposal / Design (no code changes yet)

---

## 1. Goal

Allow drivers to register any record in the system (income, expense, goal, journey confirmation) in **less than 5 seconds** by selecting a previously saved template that auto-fills every field. The user only confirms — or makes a quick tweak — and saves.

This applies to **every form** currently in the application, replacing the current 100% manual data entry as the default path while keeping manual entry available as a fallback.

---

## 2. Forms in scope

The codebase currently exposes four input surfaces. Each one must support Registro Rápido:

| # | Form / Modal                         | File (current)                                | Fields collected today                                                                                       |
| - | ------------------------------------ | --------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| 1 | Add / Edit Receita (income)          | `lib/widgets/receita_modal.dart`              | `app`, `value`, `distancia`, `localSaida`, `localEntrada`, `dataHora`                                        |
| 2 | Add / Edit Despesa (expense)         | `lib/widgets/despesas_modal.dart`             | `categoria`, `valor`, `data`, `formaPagamento`, `observacoes`                                                |
| 3 | Definir Meta (goal)                  | `lib/widgets/meta_modal.dart`                 | `meta` (R$)                                                                                                  |
| 4 | Finalizar Jornada (journey confirm)  | `lib/screens/jornada_screen.dart` (`_buildFinalizeDialog`) | `finalKm`                                                                                       |

> Login (`lib/widgets/login_form.dart`) is intentionally **out of scope** — credentials must not be templated.

---

## 3. UX principles

1. **Templates first.** When a form opens, the first thing the user sees is a horizontal row of "template chips" at the top of the modal. The keyboard does NOT open automatically — tapping any chip applies the template and the modal becomes ready to save with a single additional tap.
2. **Defaults are pre-applied.** Each form supports an optional *default template*. If the user has marked one as default, the form opens already filled in (date/time = now). The save button is enabled immediately.
3. **Always editable.** Applying a template never locks the form. The user can adjust any field before saving.
4. **Save as template.** Every form's save button gains a secondary action ("Save & create template") via a long-press or a small bookmark icon next to "Salvar/Adicionar".
5. **Manual entry remains available** — a "Manual" / "Em branco" chip at the start of the chip row clears the form.

### 3.1. Visual layout (chip row)

```
┌─────────────────────────────────────────────────────────┐
│ [ x ]                                                   │
│            Adicionar Receita                            │
│                                                         │
│ Modelos:  [ + Em branco ] [ ⭐ ML padrão ] [ Amazon… ]  │
│                                                         │
│ Aplicativo: Mercado Libre        ▼                      │
│ Valor:      35,00                                       │
│ Distância:  6,2 km                                      │
│ Saída:      CD Cajamar                                  │
│ Chegada:    (deixar em branco para preencher na hora)   │
│ Data/Hora:  21/05/2026 14:32   (auto = agora)           │
│                                                         │
│ [ Cancelar ]               [ Adicionar  ▾ ]             │
│                                  └─ Salvar como modelo  │
└─────────────────────────────────────────────────────────┘
```

### 3.2. The "5-second" interaction budget

Target path:

```
Tap (+) on screen ............. 0.5 s
Modal slides in ............... 0.5 s
Tap template chip ............. 1.0 s
Quick scan + tap "Adicionar" .. 2.5 s
Confirmation snackbar ......... 0.5 s
                                ──────
                       Total: ≈ 5.0 s
```

For the same form repeated daily (e.g., "Combustível R$ 100 Pix"), the *default template* + auto-now date can compress the path to ~2 s (tap +, tap Adicionar).

---

## 4. Data model — `Template`

A single unified collection per user, distinguished by `formType`. This avoids creating one Firestore collection per form and keeps the UI list manageable.

```text
Template
├── id: String                  // Firestore doc id
├── userId: String              // owner (matches existing scoping in *_service.dart)
├── formType: enum              // 'receita' | 'despesa' | 'meta' | 'jornadaFinal'
├── name: String                // display label on the chip, e.g., "Mercado Libre padrão"
├── isDefault: bool             // at most one default per (userId, formType)
├── usageCount: int             // bump on apply, used for sort order
├── lastUsedAt: Timestamp       // for "Recents" sort
├── createdAt: Timestamp
└── payload: Map<String, dynamic>   // see §4.1
```

### 4.1. `payload` per `formType`

The payload mirrors the existing `onSave` callback maps so that the modals can apply a template by just calling their existing save path with overrides.

**`formType = 'receita'`** (mirrors `ReceitaModal.onSave`)
```
{
  "app":          String?,         // null → user must pick
  "value":        double?,         // null → user must type
  "distancia":    double?,
  "localSaida":   String?,
  "localEntrada": String?,
  "dataHora":     "now" | ISO8601   // "now" → fill with DateTime.now() at apply time
}
```

**`formType = 'despesa'`** (mirrors `DespesasModal.onSave`)
```
{
  "categoria":      String?,
  "valor":          double?,
  "data":           "today" | ISO8601,
  "formaPagamento": String?,
  "observacoes":    String?
}
```

**`formType = 'meta'`** (mirrors `MetaModal.onSave`)
```
{
  "meta": double
}
```

**`formType = 'jornadaFinal'`** (mirrors `_buildFinalizeDialog`)
```
{
  "kmOffset":    double?,        // additive correction to detected km
  "kmOverride":  double?         // hard override (mutually exclusive with kmOffset)
}
```

> **Rule:** any field set to `null` in the payload remains empty in the form. The user fills it manually. This is what makes a "semi-template" possible (e.g., `localEntrada` blank because each Mercado Libre delivery is different).

---

## 5. Persistence strategy

The app already uses Cloud Firestore (`cloud_firestore` is imported in `despesa.dart` and `receita.dart`). Recommendation:

* **Primary store:** Firestore collection `users/{uid}/templates`. Same security-rule pattern as existing `despesas` / `receitas` collections.
* **Local cache:** `shared_preferences` (already commonly used in Flutter projects) or `hive` for offline-first access. Templates are tiny (< 1 KB) so a cached JSON list refreshed on app start is sufficient.
* **Sync rule:** apply optimistic UI — chip row reads from cache; writes go to Firestore and update cache on success.

### 5.1. Suggested service layer

A new `TemplateService` class would expose:

```text
Future<List<Template>> getTemplates(String formType)
Future<Template>       saveTemplate(Template t)
Future<void>           deleteTemplate(String id)
Future<void>           setDefault(String formType, String? id)
Future<void>           incrementUsage(String id)
```

It would sit alongside the existing `DespesaService`, `ReceitaService`, `JornadaService`, etc., following the same constructor + Firestore pattern.

---

## 6. Behavioural rules

1. **At most one default per `formType` per user.** Setting a new default unsets the previous one (transaction).
2. **Sort order in the chip row:**
   1. Default template (if any) — pinned first with a ⭐ icon
   2. Top 3 most-used (by `usageCount`)
   3. Most recently used
   4. Remaining templates → opened via a "Ver todos" chip that shows a bottom-sheet picker
3. **"Em branco" chip** is always present, always first when no default exists.
4. **Long-press a chip** → context menu: *Editar*, *Definir como padrão*, *Excluir*.
5. **Telemetry-friendly:** when a template is applied, log `{templateId, formType, appliedAt}` so future iterations can prove the 5-second target.

---

## 7. Validation & edge cases

| Case                                                              | Expected behaviour                                                                          |
| ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| Template references a category/app that was later removed         | Field is cleared and shown with a warning border; user must pick before saving              |
| Template payload has a numeric field stored as string             | `TemplateService` normalises types on read (`double.tryParse` etc.)                         |
| User has no templates yet                                         | Only "Em branco" chip is shown + a small "Crie um modelo após salvar" hint                  |
| User saves the same template twice with the same name             | Names are not unique; disambiguated internally by `id`. Optional: dedupe by `name+payload`. |
| Offline                                                           | Cached templates work normally; new templates queue in cache and sync on reconnect          |
| Default template + user changes a field then taps "Adicionar"     | Manual edit wins; the template itself is **not** modified                                   |
| Editing an existing record (not creating)                         | Chip row is hidden — templates only apply to new records                                    |

---

## 8. Acceptance criteria

A. **AC-1 — Chip row present.** Every in-scope form displays a horizontal, scrollable list of saved templates above the first input.

B. **AC-2 — One-tap apply.** Tapping a chip fills every non-null field in the payload and resolves `"now"`/`"today"` to current time.

C. **AC-3 — Save flow ≤ 5 s.** From tapping the floating "+" button to seeing the success snackbar, a user with a default template can complete a record in ≤ 5 s on a mid-range Android device (measured with the existing app on Wi-Fi).

D. **AC-4 — Default template.** Marking a template as default opens its form pre-filled and the primary action button enabled.

E. **AC-5 — Save current as template.** From any in-scope form, the user can persist the currently entered values as a new template with a chosen name.

F. **AC-6 — Manual fallback.** "Em branco" chip clears any applied template and restores the existing manual-entry experience byte-for-byte.

G. **AC-7 — Editing safety.** Opening a record in edit mode hides the chip row to prevent accidental overwrites.

H. **AC-8 — Per-user isolation.** Templates created by user A are not visible to user B (verified by Firestore security rules).

---

## 9. Out of scope (for v1)

* Sharing templates between users / "marketplace" of templates.
* Auto-suggesting templates from past records (ML-based).
* Per-day-of-week or geofenced templates (e.g., "near CD Cajamar → ML template").
* Template usage analytics dashboard inside the app (counts are stored but not surfaced).
* Bulk import/export of templates.

These can be considered in a v2 once the 5-second target is validated in production.

---

## 10. Suggested rollout order

1. **Receita** (highest volume, biggest UX win).
2. **Despesa**.
3. **Meta**.
4. **Jornada — finalize dialog**.

Behind a feature flag (e.g., `enableQuickRegistration`) so it can be turned on per-user or for a beta cohort.

---

## 11. Open questions for William

1. Should templates also store **partial values** for date fields (e.g., "always last Friday") or is `"now"` / `"today"` enough?
2. How many templates per form is the soft cap? (Suggestion: 12 in the chip row, rest in "Ver todos".)
3. Should the system **suggest** an initial set of templates on first login (e.g., one per app from the `apps` list passed to `ReceitaModal`)?
4. Any branding constraints for the chip row colour? Current accent is `Color.fromARGB(255, 248, 151, 33)`.
