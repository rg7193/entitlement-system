# Permission Hierarchy Implementation

## Overview
This document details the implementation of the hierarchical permission system for the Cash Management Entitlement System. The system allows permissions to be defined at multiple levels of the organizational hierarchy, with lower levels able to override permissions from higher levels.

## Permission Inheritance Flow

The permission hierarchy follows these principles:

1. **Top-Down Inheritance**: Permissions flow from higher organizational levels to lower levels
2. **Override Capability**: Lower levels can override permissions from higher levels
3. **Explicit Denial**: Explicit denials take precedence over grants at any level
4. **Scope-Based Permissions**: Permissions can be scoped to specific products, services, or accounts

## Hierarchy Levels (from highest to lowest)

1. **Bank Level** - Affects all entities in the system
2. **Region/Branch Level** - Affects all clients in a specific region
3. **Product Level** - Affects all users of a specific product
4. **Client Group Level** - Affects all entities in a client group
5. **Client Entity Level** - Affects all users in a client entity
6. **Account Level** - Affects operations on specific accounts
7. **User Group Level** - Affects all users in a group
8. **User Level** - Affects specific individual users

## Implementation Details

### Database Structure

The permission hierarchy is implemented through the following key tables:

1. **`permissions`** - Defines individual permissions
2. **`entitlements`** - Links permissions to entities at various levels with scoping
3. **`effective_user_permissions`** - View that resolves the effective permissions for each user

### Entity and Scope Types

The system uses enumerated types to represent different entity and scope levels:

```sql
-- Entity types for entitlement
CREATE TYPE entity_type AS ENUM (
    'BANK', 
    'REGION', 
    'CLIENT_GROUP', 
    'CLIENT_ENTITY', 
    'USER_GROUP', 
    'USER'
);

-- Scope types for entitlement
CREATE TYPE scope_type AS ENUM (
    'GLOBAL', 
    'PRODUCT_CATEGORY', 
    'PRODUCT', 
    'SERVICE', 
    'ACCOUNT'
);
```

### Entitlement Structure

Each entitlement record contains:

1. The entity type and ID to which the permission is assigned
2. The permission being granted or denied
3. The scope type and ID to which the permission applies
4. Whether the permission is explicitly denied
5. Optional date range for temporary permissions

```sql
CREATE TABLE entitlements (
    entitlement_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_type entity_type NOT NULL,
    entity_id UUID NOT NULL,
    permission_id UUID NOT NULL REFERENCES permissions(permission_id),
    scope_type scope_type NOT NULL,
    scope_id UUID,
    is_denied BOOLEAN DEFAULT FALSE,
    start_date DATE,
    end_date DATE,
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_date_range CHECK (end_date IS NULL OR end_date >= start_date)
);
```

### Permission Resolution

The system resolves effective permissions through a view that:

1. Collects all permissions from all levels of the hierarchy
2. Applies override rules based on the hierarchy
3. Resolves conflicts with explicit denials taking precedence

```sql
CREATE OR REPLACE VIEW effective_user_permissions AS
WITH permission_hierarchy AS (
    -- Bank level permissions
    SELECT 
        e.permission_id,
        u.user_id,
        'BANK' AS source_type,
        b.bank_id AS source_id,
        e.scope_type,
        e.scope_id,
        e.is_denied
    FROM 
        entitlements e
        JOIN banks b ON e.entity_type = 'BANK' AND e.entity_id = b.bank_id
        JOIN client_groups cg ON cg.bank_id = b.bank_id
        JOIN client_entities ce ON ce.client_group_id = cg.client_group_id
        JOIN users u ON u.client_entity_id = ce.client_entity_id
    
    -- Additional levels omitted for brevity...
)
SELECT 
    ph.user_id,
    p.permission_id,
    p.code AS permission_code,
    p.name AS permission_name,
    ph.scope_type,
    ph.scope_id,
    CASE 
        WHEN bool_or(ph.is_denied) THEN FALSE
        ELSE TRUE
    END AS is_granted
FROM 
    permission_hierarchy ph
    JOIN permissions p ON ph.permission_id = p.permission_id
GROUP BY 
    ph.user_id, p.permission_id, p.code, p.name, ph.scope_type, ph.scope_id;
```

### Permission Check Function

A utility function is provided to check if a user has a specific permission:

```sql
CREATE OR REPLACE FUNCTION has_permission(
    p_user_id UUID,
    p_permission_code VARCHAR,
    p_scope_type scope_type DEFAULT 'GLOBAL',
    p_scope_id UUID DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_has_permission BOOLEAN;
BEGIN
    SELECT 
        is_granted INTO v_has_permission
    FROM 
        effective_user_permissions
    WHERE 
        user_id = p_user_id
        AND permission_code = p_permission_code
        AND scope_type = p_scope_type
        AND (p_scope_id IS NULL OR scope_id = p_scope_id)
    LIMIT 1;
    
    RETURN COALESCE(v_has_permission, FALSE);
END;
$$ LANGUAGE plpgsql;
```

## Permission Override Examples

### Example 1: Bank-level permission overridden at Client Entity level

1. Bank grants "VIEW_ACCOUNT_BALANCE" permission to all users
2. A specific Client Entity explicitly denies "VIEW_ACCOUNT_BALANCE" for its users
3. Result: Users in that Client Entity cannot view account balances, while all other users can

### Example 2: Product-level permission overridden at User level

1. A "PAYMENT" product has "INITIATE_PAYMENT" permission granted at the product level
2. A specific user is explicitly denied the "INITIATE_PAYMENT" permission
3. Result: That user cannot initiate payments, while other users with access to the product can

### Example 3: Hierarchical approval limits

1. Client Entity sets a maximum payment approval limit of $10,000 for all users
2. A User Group of "Senior Managers" has an override limit of $50,000
3. A specific user in the "Executive" group has an override limit of $100,000
4. Result: Regular users can approve up to $10,000, Senior Managers up to $50,000, and the Executive up to $100,000

## Special Permission Features

### Temporary Permissions

Permissions can be time-bound using the `start_date` and `end_date` fields in the entitlements table:

```sql
-- Grant temporary access to a specific service
INSERT INTO entitlements (
    entity_type, entity_id, permission_id, scope_type, scope_id, 
    start_date, end_date, created_by
) VALUES (
    'USER', '123e4567-e89b-12d3-a456-426614174000', 
    '123e4567-e89b-12d3-a456-426614174001', 
    'SERVICE', '123e4567-e89b-12d3-a456-426614174002',
    '2025-04-01', '2025-04-30', 
    '123e4567-e89b-12d3-a456-426614174003'
);
```

### Delegation

Users can temporarily delegate their permissions to other users:

```sql
-- Delegate permissions from one user to another
INSERT INTO delegations (
    delegator_user_id, delegate_user_id, 
    start_date, end_date, reason, status
) VALUES (
    '123e4567-e89b-12d3-a456-426614174000', 
    '123e4567-e89b-12d3-a456-426614174001',
    '2025-04-01 09:00:00', '2025-04-05 17:00:00', 
    'Vacation coverage', 'APPROVED'
);
```

### Four-Eyes Principle

The approval workflow system implements the four-eyes principle by requiring multiple approvers:

```sql
-- Create a workflow requiring two approvers for payments over $10,000
INSERT INTO approval_workflows (
    client_entity_id, product_id, service_id, 
    min_approvers, threshold_amount, currency
) VALUES (
    '123e4567-e89b-12d3-a456-426614174000', 
    '123e4567-e89b-12d3-a456-426614174001', 
    '123e4567-e89b-12d3-a456-426614174002',
    2, 10000.00, 'USD'
);
```

## Audit Trail

All permission changes and access attempts are tracked in the audit_logs table:

```sql
-- Log a permission change
INSERT INTO audit_logs (
    user_id, action, entity_type, entity_id, details
) VALUES (
    '123e4567-e89b-12d3-a456-426614174000', 
    'PERMISSION_GRANT', 
    'USER', 
    '123e4567-e89b-12d3-a456-426614174001',
    '{"permission": "INITIATE_PAYMENT", "scope": "PRODUCT", "scope_id": "123e4567-e89b-12d3-a456-426614174002"}'
);
```
