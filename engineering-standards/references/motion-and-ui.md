# Referência — Motion & UI/UX

> Pilar 2. Origem: `prompts.txt` #2 + `design-motion-principles` + Web Interface Guidelines (Vercel).

## Cinco estados obrigatórios (toda UI async/dinâmica)
1. **Skeleton/placeholder** enquanto carrega (sem tela branca / layout shift).
2. **Lazy loading**: `loading="lazy"` abaixo da dobra; `React.lazy`+`Suspense` p/ rotas/componentes
   pesados; listas grandes virtualizadas.
3. **Enter** — aparecimento suave.
4. **Exit** — desmontagem suave (`AnimatePresence` ou equiv.), nunca sumir abrupto.
5. **Carregamento & progresso** — spinners em ações; barras/indicadores em operações longas; botão
   de submit mostra estado de envio.

## Princípios de Motion (design-motion-principles)
**Frequency Gate** — decida *se* animar antes de *como*:
| Frequência | Recomendação |
|---|---|
| Raro (mensal) | Motion expressivo OK |
| Ocasional (diário) | Sutil e rápido |
| Frequente (100s/dia) | Sem animação / instantâneo |
| Iniciado por teclado | **Nunca animar** |

**Durações** (por contexto): produtividade **< 300ms (180ms ideal)**; polish de produção
**200–500ms**; criativo/lúdico: a duração serve ao efeito.

**Regras:**
- "A melhor animação é a que passa despercebida" (exceção: apps lúdicos/infantis).
- **`prefers-reduced-motion` sempre** — sem exceções.
- Animar **só `transform`/`opacity`**; **nunca `transition: all`**; `transform-origin` correto.
- Animações **interrompíveis**. **Motion Gap Analysis:** cace renders condicionais sem
  `AnimatePresence` e estilos dinâmicos sem `transition`.

**Lente por projeto:** produtividade/SaaS → Emil(velocidade)+Jakub(polish); infantil/criativo →
Jakub+Jhey; landing → Jakub+Jhey; mobile/e-commerce → Jakub+Emil.

## Web Interface Guidelines (checklist de review)
**A11y:** `aria-label` em botões só-ícone; `<label>` em inputs; `<button>` p/ ação, `<a>`/`<Link>` p/
nav (nunca `<div onClick>`); `alt` em imagens (`alt=""` decorativa); `aria-hidden` em ícones deco;
`aria-live="polite"` em updates async; headings hierárquicos + skip link.
**Foco:** foco visível (`focus-visible:ring-*`), nunca `outline-none` sem substituto; `:focus-visible`
e `:focus-within`; sticky não obscurece o focado.
**Forms:** `autocomplete`+`name`; `type`/`inputmode` corretos; não bloquear paste; labels clicáveis;
`spellCheck={false}` em email/código/user; erros inline + focar 1º erro; submit habilitado até o
request; placeholders com `…` e exemplo; avisar sobre mudanças não salvas.
**Tipografia:** `…` (não `...`); aspas curvas; `&nbsp;` em unidades/atalhos/marcas; loading termina em
`…`; `tabular-nums` em colunas numéricas; `text-wrap: balance` em headings.
**Conteúdo/layout:** `truncate`/`line-clamp`/`break-words`; filhos flex com `min-w-0`; tratar estados
vazios; antecipar inputs curtos/longos.
**Imagens/perf:** `width`/`height` explícitos (evita CLS); `loading="lazy"` abaixo da dobra;
`priority`/`fetchpriority="high"` acima; virtualizar listas > 50; `preconnect`/`preload` de fontes
(`font-display: swap`); preferir `<video muted loop playsinline>` a GIF.
**Nav/estado:** URL reflete filtros/tabs/paginação (deep-link, ex.: nuqs); ações destrutivas com
confirmação ou undo.
**Touch/dark/i18n/hidratação:** `touch-action: manipulation`; `overscroll-behavior: contain` em
modais; `color-scheme`+`theme-color`; `Intl.DateTimeFormat`/`Intl.NumberFormat`; guardar datas contra
mismatch de hidratação.
**Copy:** voz ativa; Title Case; numerais p/ contagens; labels específicos; erro inclui próximo passo.

## Ferramentas de apoio (ver arsenal)
`design-motion-principles` (build/audit de motion), `web-design-guidelines` (auditar UI),
`shadcn-ui-mcp`/`21st.dev Magic` (componentes), `chrome-devtools-mcp` (perf/erros no browser real).
