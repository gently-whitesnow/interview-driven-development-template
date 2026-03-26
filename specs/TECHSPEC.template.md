<!-- Template for TECHSPEC.md content — the structure BELOW the Document Boundary section.
     TECHSPEC.md already has the boundary section. This shows the recommended content structure.
     TECHSPEC answers HOW the system is built: architecture, data model, contracts, lifecycle. -->

## 1. Overview

### 1.1 Goal

<!-- Technical goal in 2-3 sentences. -->

### 1.2 Boundaries

<!-- Runtime, deployment model, language, infrastructure constraints. -->

### 1.3 Terms

<!-- Glossary of domain-specific terms used in this document. -->

## 2. Architecture

### 2.1 Bounded Contexts / Modules

<!-- Each module: responsibility, layer structure. -->

### 2.2 Module Dependencies

<!-- Dependency graph. Direction of allowed references. -->

## 3. Data Model

### 3.1 Entities

<!-- Fields, types, constraints, relationships. -->

### 3.2 Value Objects / Enums

<!-- Shared VOs, enum definitions with wire-format values. -->

## 4. API Contracts

### 4.1 REST Endpoints

<!-- Method, path, request/response shape. Group by resource. -->

### 4.2 WebSocket / Real-time Events

<!-- Event names, payload shapes, delivery semantics. Omit if N/A. -->

## 5. Lifecycle & State Machines

<!-- For entities with non-trivial lifecycle: states, transitions, guards. -->

## 6. Integration Specs

<!-- External services: protocols, auth, contracts, error handling. -->

## 7. Testing Strategy

<!-- Test categories (unit, integration, system, architecture), tooling, coverage goals. -->

## 8. NFR & Operational

<!-- Performance targets, security invariants, observability, deployment. -->
