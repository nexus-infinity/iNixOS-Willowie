# Meta-Prompt Examples
## Observer-Architect-Weaver Triad

This document provides concrete examples of meta-prompts using the Observer-Architect-Weaver Triad framework for various development scenarios.

---

## 🔍 1. Code Review & Analysis

### Observer Meta-Prompt: Initial Code Audit

```yaml
role: Observer
mode: internal
perspective_priority: [geometric, semantic, temporal]

task: |
  Analyze the authentication module in the codebase.
  
  Geometric Analysis:
  - Map all authentication-related components and their relationships
  - Identify circular dependencies or asymmetric structures
  - Detect flow bottlenecks or distortions
  
  Semantic Analysis:
  - Verify naming consistency across authentication concepts
  - Check for semantic leaks (auth concerns in business logic)
  - Identify abstraction level mismatches
  
  Temporal Analysis:
  - Track how authentication logic evolved over time
  - Identify accumulated technical debt
  - Note patterns indicating rapid vs. intentional development
  
  Output: Structured report with findings in each category
  Validation: Cross-reference with external observer (security best practices)
```

### External Observer Meta-Prompt: Security Validation

```yaml
role: Observer
mode: external
validation_focus: [security, compliance, best_practices]

task: |
  Validate the authentication system against external standards.
  
  Field Resonance Check:
  - Does implementation align with OWASP guidelines?
  - Is it consistent with industry authentication patterns?
  - Does it integrate naturally with the broader security landscape?
  
  Environmental Context:
  - Consider regulatory requirements (GDPR, etc.)
  - Evaluate against common attack vectors
  - Assess real-world usage patterns
  
  Output: Resonance validation report with compliance gaps
```

---

## 🏗️ 2. System Design & Architecture

### Architect Meta-Prompt: API Design

```yaml
role: Architect
intent: Design RESTful API maintaining semantic coherence
geometry_alignment: Resource-oriented with clear boundaries
semantic_focus: Meaningful URIs and consistent response structures
temporal_awareness: Versioning strategy for backward compatibility

task: |
  Design API for user management system.
  
  Geometric Design:
  - Define resource hierarchy and relationships
  - Establish clear boundaries between domains
  - Design symmetric CRUD operations where appropriate
  
  Semantic Blueprint:
  - Create meaningful, self-documenting URI patterns
  - Design consistent request/response schemas
  - Define clear error semantics
  
  Temporal Planning:
  - Embed API versioning from the start (v1, v2, etc.)
  - Plan deprecation pathways
  - Design for graceful evolution
  
  External Validation: REST maturity model compliance
  
  Output: OpenAPI/Swagger specification with design rationale
```

### Architect Meta-Prompt: Database Schema Design

```yaml
role: Architect
intent: Design normalized database schema with semantic integrity
geometry_alignment: Relational model with clear foreign key symmetry
semantic_focus: Table and column names reflect domain meaning
temporal_awareness: Migration-friendly structure with audit trails

task: |
  Design database schema for e-commerce platform.
  
  Geometric Structure:
  - Define entity relationships with proper normalization
  - Establish referential integrity constraints
  - Design for balanced query performance
  
  Semantic Integrity:
  - Name tables and columns using domain language
  - Ensure naming consistency across related entities
  - Document relationships with meaningful constraint names
  
  Temporal Design:
  - Include created_at, updated_at on all entities
  - Plan for audit trails where needed
  - Design schema migration strategy (up/down migrations)
  
  Output: SQL DDL scripts with comprehensive documentation
```

---

## ⚡ 3. Implementation & Integration

### Weaver Meta-Prompt: Feature Implementation

```yaml
role: Weaver
intent: Implement user authentication preserving system flow
geometry_alignment: Integrate auth layer without disrupting existing circuits
semantic_focus: Embed security meaning in user experience
temporal_awareness: Maintain app rhythm, don't slow down user flows

task: |
  Implement JWT-based authentication from Architect's design.
  
  Geometric Integration:
  - Connect auth middleware into existing Express pipeline
  - Preserve request/response flow patterns
  - Integrate with existing error handling circuits
  
  Semantic Embodiment:
  - Use clear, meaningful error messages for auth failures
  - Create intuitive login/logout user experience
  - Make authentication state obvious in UI
  
  Temporal Sustainability:
  - Implement token refresh without disrupting user sessions
  - Handle auth failures gracefully (auto-retry logic)
  - Maintain system responsiveness during auth checks
  
  External Validation: Test with real users, monitor performance
  
  Output: Working code with integration tests and UX validation
```

### Weaver Meta-Prompt: Refactoring Legacy Code

```yaml
role: Weaver
intent: Refactor monolithic function while preserving behavior
geometry_alignment: Extract components without breaking existing flows
semantic_focus: Improve naming while maintaining meaning
temporal_awareness: Incremental refactoring with feature flags

task: |
  Refactor 500-line processOrder() function based on Architect's plan.
  
  Geometric Preservation:
  - Extract smaller functions without changing data flow
  - Maintain existing function signature initially
  - Preserve all error handling paths
  
  Semantic Improvement:
  - Rename extracted functions to reflect actual purpose
  - Add clear comments at integration points
  - Make implicit dependencies explicit
  
  Temporal Strategy:
  - Use feature flags to switch between old/new implementations
  - Refactor incrementally over multiple commits
  - Run extensive regression tests at each step
  
  Output: Refactored code with 100% test coverage maintained
```

---

## 🔄 4. Complete Development Cycles

### Full Cycle: New Feature Development

```yaml
# Phase 1: Observer
role: Observer
task: |
  Analyze existing shopping cart implementation.
  Identify: current structure, pain points, evolution patterns.
  Output: Observations document for Architect.

# Phase 2: Architect  
role: Architect
input: Observer's findings
task: |
  Design improved shopping cart with:
  - Better separation of cart logic and persistence
  - Clearer semantic boundaries
  - Evolution path for future payment integrations
  Output: Technical design document.

# Phase 3: Weaver
role: Weaver
input: Architect's design
task: |
  Implement new cart system:
  - Integrate smoothly with existing checkout flow
  - Preserve user experience patterns
  - Maintain system performance characteristics
  Output: Implemented feature with tests.

# Phase 4: External Observer
role: Observer
mode: external
task: |
  Validate integration:
  - Test with real users
  - Monitor performance metrics
  - Verify natural fit with overall UX
  Output: Validation report and recommendations.
```

### Full Cycle: Technical Debt Resolution

```yaml
# Phase 1: Observer (Internal)
role: Observer
mode: internal
task: |
  Survey codebase for technical debt.
  Map: circular dependencies, god objects, code smells.
  Track: how debt accumulated over time.
  Prioritize: high-impact refactoring opportunities.

# Phase 2: Observer (External)
role: Observer
mode: external  
task: |
  Validate debt assessment against industry standards.
  Compare: with best practices and modern patterns.
  Assess: business impact of debt vs. refactoring cost.

# Phase 3: Architect
role: Architect
task: |
  Design refactoring roadmap:
  - Phase 1: Critical structural issues
  - Phase 2: Semantic improvements
  - Phase 3: Long-term evolution planning
  Create migration strategy with minimal disruption.

# Phase 4: Weaver
role: Weaver
task: |
  Execute refactoring plan incrementally:
  - Implement Phase 1 behind feature flags
  - Validate each change with comprehensive tests
  - Roll out gradually monitoring system health
  Maintain backward compatibility throughout.
```

---

## 🎯 5. Specialized Scenarios

### Documentation Writing

```yaml
role: Observer → Architect → Weaver

observer_phase:
  task: Understand user documentation needs
  analyze:
    - Current documentation gaps
    - User questions and confusion points
    - Learning curve analysis

architect_phase:
  task: Structure documentation hierarchy
  design:
    - Information architecture
    - Navigation and cross-linking
    - Progressive disclosure strategy

weaver_phase:
  task: Write clear, actionable content
  implement:
    - Tutorial-style guides
    - Code examples that actually work
    - Contextual help and tooltips
```

### Performance Optimization

```yaml
role: Observer → Architect → Weaver

observer_phase:
  task: Profile and measure performance
  analyze:
    - Identify bottlenecks
    - Map execution flow
    - Measure resource usage

architect_phase:
  task: Design optimization strategy
  design:
    - Caching architecture
    - Query optimization plan
    - Algorithmic improvements

weaver_phase:
  task: Implement optimizations
  implement:
    - Add caching layers
    - Optimize database queries
    - Refactor hot paths
  validate: Measure improvement vs. baseline
```

### Security Hardening

```yaml
role: Observer → Architect → Weaver

observer_phase:
  task: Security audit
  analyze:
    - Vulnerability scan results
    - Attack surface mapping
    - Access pattern analysis

architect_phase:
  task: Design security improvements
  design:
    - Defense in depth strategy
    - Zero-trust architecture
    - Encryption and key management

weaver_phase:
  task: Implement security measures
  implement:
    - Input validation layers
    - Authentication strengthening
    - Audit logging
  validate: Penetration testing and compliance check
```

---

## 🌐 6. Multi-Agent Collaboration

### Example: Three Agents Working Together

```yaml
# Agent 1: Observer Specialist
agent_id: observer_01
specialization: Code quality and patterns
task: |
  Continuously monitor codebase for:
  - Anti-patterns emergence
  - Complexity accumulation
  - Semantic drift
  Report findings to Architect agents.

# Agent 2: Architect Specialist  
agent_id: architect_01
specialization: System design
task: |
  Receive Observer reports.
  Design refactoring plans maintaining:
  - Structural integrity
  - Semantic coherence
  - Evolution pathways
  Hand blueprints to Weaver agents.

# Agent 3: Weaver Specialist
agent_id: weaver_01
specialization: Implementation
task: |
  Implement Architect designs:
  - Preserve system flow
  - Maintain user experience
  - Ensure adaptability
  Return metrics to Observer for validation.

# Coordination Flow
flow: |
  Observer → Architect: Insights and patterns
  Architect → Weaver: Designs and blueprints
  Weaver → Observer: Implementation metrics
  External Observer → All: Field validation
```

---

## 🧪 7. Testing & Validation

### Testing with Triad Awareness

```yaml
# Observer Tests
role: Observer
test_type: Detection and Analysis Tests
tests:
  - name: "Detect circular dependencies"
    validate: Geometric relationship mapping
  
  - name: "Identify semantic inconsistencies"
    validate: Naming and abstraction analysis
  
  - name: "Track technical debt trends"
    validate: Temporal evolution tracking

# Architect Tests
role: Architect
test_type: Design Validation Tests
tests:
  - name: "Verify API design coherence"
    validate: RESTful principles adherence
  
  - name: "Check schema normalization"
    validate: Database design integrity
  
  - name: "Validate migration safety"
    validate: Temporal evolution planning

# Weaver Tests
role: Weaver
test_type: Integration and Experience Tests
tests:
  - name: "Verify flow preservation"
    validate: No regression in user paths
  
  - name: "Check performance impact"
    validate: System rhythm maintained
  
  - name: "Validate UX coherence"
    validate: Semantic clarity in interface
```

---

## 📝 8. Practical Templates

### Daily Development Template

```
Today's Development Session
Date: [DATE]

Current Triad Role: [Observer/Architect/Weaver]

Geometric Focus:
- [What structural aspects am I working on?]

Semantic Focus:
- [What meaning/coherence am I ensuring?]

Temporal Focus:
- [How does this fit in the evolution timeline?]

External Validation Needed:
- [What requires outside perspective?]

Tasks:
1. [Task with triad context]
2. [Task with triad context]

Reflection:
- Did I maintain field resonance?
- Is the work coherent with system geometry?
- Will this age well temporally?
```

---

*These meta-prompts demonstrate how the Observer-Architect-Weaver Triad brings structure, meaning, and temporal awareness to AI-assisted development workflows.*
