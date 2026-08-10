Add this as a **hard architectural constraint** near the top of the Codex goal prompt:

> **Product Separation / Repository Architecture Constraint**
>
> The Consulting OS is a separate product surface from the existing Lead Emergence ministry platform. They may share selected infrastructure and intentionally reusable primitives, but the Consulting OS must not be implemented as an inseparable extension of the ministry application.
>
> Design for the following scaling requirement:
>
> **I must be able to hand another developer or organization the current Lead Emergence ministry product without also handing them the Consulting OS implementation, consulting-specific architecture, consulting worktrees/branches, or consulting product documentation.**
>
> Therefore:
>
> * Keep Consulting OS architecture, feature code, migrations, documentation, tests, worktrees, and development branches clearly separated from the existing ministry product.
> * Do not place consulting-specific canonical documents into general ministry architecture folders where they would become part of a ministry-only handoff.
> * Do not create unnecessary hard dependencies from the ministry product into Consulting OS code.
> * Shared components, authentication primitives, Meridian infrastructure, database utilities, design-system elements, or other common services may be reused only when they are genuinely product-agnostic.
> * If a shared primitive must evolve to support both products, keep the primitive generic and place consulting-specific behavior behind a Consulting OS boundary.
> * Prefer explicit interfaces between products over direct imports across product domains.
> * Consulting-specific database tables, migrations, routes, API handlers, AI workflows, permissions, tests, and documentation should be identifiable and separable.
> * Before modifying existing ministry-domain code to support Consulting OS, classify the change as:
>
>   1. genuinely shared platform infrastructure,
>   2. ministry-specific,
>   3. consulting-specific, or
>   4. an interface between the two.
> * Do not move consulting-specific concepts into shared infrastructure merely for implementation convenience.
> * Do not duplicate genuinely shared primitives simply to maintain separation; share infrastructure where appropriate, but preserve independent product boundaries.
>
> **Development Isolation**
>
> Use dedicated Consulting OS branches and worktrees for Consulting OS development. Keep consulting architecture documentation and implementation planning under a dedicated path such as:
>
> `/docs/consulting-os/`
>
> and keep consulting-specific source code under an intentionally bounded product/module structure determined during Phase 0.
>
> Phase 0 must explicitly recommend the appropriate code/repository boundary for long-term product separation before significant implementation begins.
>
> The architecture should support the possibility that Lead Emergence Ministry and Lead Emergence Consulting OS could later:
>
> * remain in one monorepo,
> * be split into separate repositories,
> * share a common platform package,
> * be licensed/distributed independently,
> * or be developed by separate teams.
>
> Avoid architectural choices that unnecessarily prevent those future options.

Then add a second constraint for the **entry experience**:

> **Unified Lead Emergence Entry / Landing Page**
>
> The public Lead Emergence entry experience must be redesigned to support three clearly distinct product entry paths:
>
> **Consultant Login**
> For Lead Emergence consultants managing consulting engagements and multiple client organizations.
>
> **Consulting Client Login**
> For leaders, employees, coaching participants, and other users participating in a Consulting OS client organization.
>
> **Ministry Login**
> For users of the existing Lead Emergence ministry platform.
>
> Build a new public landing/login-selection experience that clearly communicates these as related but distinct Lead Emergence products.
>
> The landing page should route users into the appropriate authentication and application context without merging the underlying portal architectures.
>
> Authentication may share infrastructure where appropriate, but successful login must resolve the user's permitted product context and route them only into authorized product surfaces.
>
> A user who legitimately has access to more than one Lead Emergence product may later be offered an authenticated product switcher, but access to one product must never imply access to another.

I would also add one **Phase 0 deliverable** to your existing prompt:

> **Phase 0 must produce a Product Boundary Architecture ADR** documenting:
>
> * ministry-only code
> * consulting-only code
> * genuinely shared platform code
> * shared database/auth infrastructure
> * product-specific migrations
> * route boundaries
> * documentation boundaries
> * branch/worktree strategy
> * how a ministry-only distribution could be produced without Consulting OS intellectual property or implementation
> * how the future landing page and authentication routing connect the products without coupling them

That last requirement is particularly important. You do not just want **UI separation**. You want **commercial and developmental separability**.

I would frame the desired architecture conceptually as:

```text
                     LEAD EMERGENCE
                    Public Landing Page
                           │
           ┌───────────────┼───────────────┐
           │               │               │
     Consultant       Consulting         Ministry
       Login           Client Login       Login
           │               │               │
           └───────┐       │       ┌───────┘
                   │       │       │
             Shared Platform Layer
             Auth • Design System
             Generic Meridian Core
             Common Infrastructure
                   │       │
        ┌──────────┘       └──────────┐
        │                             │
CONSULTING OS                    MINISTRY PRODUCT
Consultant Portal                Existing Ministry App
Client Portal                    Ministry-specific Meridian
Consulting Domain                Ministry workflows
Consulting AI                    Ministry AI
Consulting Docs                  Ministry docs
Consulting Schema                Ministry schema
```

The key is that **the shared platform layer stays deliberately thin**.

If you let every useful Consulting OS capability migrate downward into “shared,” the separation becomes fictional. Shared should mean something that genuinely belongs to Lead Emergence **regardless of product domain**, not merely something both apps happen to use today.

Your handoff test should become:

> **Can we produce a ministry-only distribution that builds, runs, and is understandable without shipping Consulting OS source, canonical consulting documents, consulting database migrations, consulting AI prompts, or consulting business logic?**

If the answer becomes no, Codex has violated the product-boundary architecture.

I would add that as an explicit acceptance criterion too.
