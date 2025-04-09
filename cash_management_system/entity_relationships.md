# Entity Relationship Diagram (ERD) - Cash Management Entitlement System

## Organizational Hierarchy
- Banks (1) → Regions (Many)
- Banks (1) → Client Groups (Many)
- Client Groups (1) → Client Entities (Many)
- Regions (1) → Client Entities (Many)
- Client Entities (1) → User Groups (Many)
- Client Entities (1) → Users (Many)
- User Groups (Many) ↔ Users (Many) [via user_group_members]

## Product & Service Hierarchy
- Product Categories (1) → Products (Many)
- Products (1) → Services (Many)
- Client Entities (1) → Accounts (Many)

## Permission Structure
- Permissions (Many) ↔ Roles (Many) [via role_permissions]
- Entitlements link Permissions to various entity types (Banks, Regions, Client Groups, Client Entities, User Groups, Users)
- Entitlements can be scoped to different levels (Global, Product Category, Product, Service, Account)

## Approval System
- Users (1) → Approval Limits (Many)
- Client Entities (1) → Approval Workflows (Many)
- Client Entities (1) → Approval Groups (Many)
- Approval Groups (Many) ↔ Users (Many) [via approval_group_members]
- Approval Workflows (Many) ↔ Approval Groups (Many) [via workflow_approval_groups]

## Delegation & Audit
- Users (1) → Delegations (Many) [as delegator]
- Users (1) → Delegations (Many) [as delegate]
- Users (1) → Audit Logs (Many)

## Key Relationships for Permission Inheritance
1. Bank → Region → Client Entity → User: Permissions flow down this hierarchy
2. Product Category → Product → Service: Permissions can be scoped at any of these levels
3. Client Group → Client Entity → User Group → User: Another permission inheritance path
4. Account-specific permissions apply to operations on specific accounts

## Permission Resolution Logic
The effective_user_permissions view resolves permissions by:
1. Collecting all permissions from all levels (Bank, Region, Client Group, Client Entity, User Group, User)
2. For each permission + scope combination, determining if it's granted based on explicit denials
3. Providing a function (has_permission) to check if a user has a specific permission in a specific scope
