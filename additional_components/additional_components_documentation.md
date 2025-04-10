# Cash Management Entitlement System - Additional Database Components

This document provides a comprehensive overview of the additional database components created for the Cash Management Entitlement System, including views, stored procedures, utility functions, and example queries.

## Overview

The Cash Management Entitlement System has been enhanced with the following additional components:

1. **Database Views**: 9 views that provide different perspectives on the data
2. **Stored Procedures**: 7 procedures for common operations
3. **Utility Functions**: 8 functions for permission checks and related operations
4. **Example Queries**: 30+ example queries for various scenarios

These components build upon the existing database schema to provide a more complete and user-friendly system for managing entitlements in a banking cash management application.

## Database Views

### 1. client_hierarchy_view
Shows the complete organizational hierarchy from bank to users.
```sql
SELECT * FROM client_hierarchy_view
WHERE bank_name = 'ABC Bank'
ORDER BY region_name, client_group_name, client_entity_name, username;
```

### 2. user_entitlements_view
Shows all entitlements for each user with readable names.
```sql
SELECT * FROM user_entitlements_view
WHERE username = 'jsmith'
ORDER BY permission_name;
```

### 3. account_access_view
Shows which users have access to which accounts and what operations they can perform.
```sql
SELECT * FROM account_access_view
WHERE account_number = '1001001001'
AND permission_code = 'VIEW_BALANCE';
```

### 4. approval_workflow_details_view
Shows complete approval workflow information with related entities.
```sql
SELECT * FROM approval_workflow_details_view
WHERE client_entity_name = 'Toyota North America'
AND currency = 'USD';
```

### 5. product_service_hierarchy_view
Shows the complete product hierarchy with categories, products, and services.
```sql
SELECT * FROM product_service_hierarchy_view
WHERE category_name = 'Payments';
```

### 6. user_approval_limits_view
Shows approval limits for users with product and service details.
```sql
SELECT * FROM user_approval_limits_view
WHERE username = 'jsmith'
AND currency = 'USD';
```

### 7. active_delegations_view
Shows currently active permission delegations.
```sql
SELECT * FROM active_delegations_view
WHERE is_active = TRUE;
```

### 8. user_group_membership_view
Shows user group memberships with details.
```sql
SELECT * FROM user_group_membership_view
WHERE username = 'jsmith';
```

### 9. permission_source_view
Shows the source of each permission for users.
```sql
SELECT * FROM permission_source_view
WHERE username = 'jsmith'
AND permission_code = 'INITIATE_PAYMENT';
```

## Stored Procedures

### 1. create_client_hierarchy_proc
Creates a complete client hierarchy (client group, entity, user groups, users).
```sql
CALL create_client_hierarchy_proc(
    '11111111-1111-1111-1111-111111111111', -- Bank ID
    'New Client Corp', -- Client group name
    'New corporate client', -- Client group description
    'New Client US', -- Client entity name
    'New York', -- Client entity location
    '11111111-1111-1111-1111-111111111112', -- Region ID
    NULL, -- OUT parameter for client_group_id
    NULL  -- OUT parameter for client_entity_id
);
```

### 2. grant_permission_proc
Grants a permission to an entity at a specific level.
```sql
CALL grant_permission_proc(
    'USER', -- Entity type
    '66666666-6666-6666-6666-666666666661', -- Entity ID (John Smith)
    'INITIATE_PAYMENT', -- Permission code
    'ACCOUNT', -- Scope type
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', -- Scope ID (Toyota NA Operating Account)
    '66666666-6666-6666-6666-666666666661', -- Created by
    NULL, -- Start date (optional)
    NULL  -- End date (optional)
);
```

### 3. revoke_permission_proc
Revokes a permission from an entity.
```sql
CALL revoke_permission_proc(
    'USER', -- Entity type
    '66666666-6666-6666-6666-666666666661', -- Entity ID (John Smith)
    'INITIATE_PAYMENT', -- Permission code
    'ACCOUNT', -- Scope type
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', -- Scope ID (Toyota NA Operating Account)
    '66666666-6666-6666-6666-666666666661', -- Created by
    TRUE -- Is denied (default is TRUE)
);
```

### 4. setup_approval_workflow_proc
Sets up a complete approval workflow with approval groups.
```sql
CALL setup_approval_workflow_proc(
    '44444444-4444-4444-4444-444444444441', -- Client entity ID (Toyota North America)
    '88888888-8888-8888-8888-888888888881', -- Product ID (Wire Transfers)
    '99999999-9999-9999-9999-999999999992', -- Service ID (Approve Wire Transfer)
    2, -- Min approvers
    100000.00, -- Threshold amount
    'USD', -- Currency
    'Toyota NA High-Value Wire Transfer Approval', -- Description
    'Toyota NA Senior Approvers', -- Approval group name
    ARRAY['66666666-6666-6666-6666-666666666661', '66666666-6666-6666-6666-666666666663'], -- Approver user IDs
    NULL, -- OUT parameter for workflow_id
    NULL  -- OUT parameter for approval_group_id
);
```

### 5. delegate_permissions_proc
Delegates permissions from one user to another.
```sql
CALL delegate_permissions_proc(
    '66666666-6666-6666-6666-666666666661', -- Delegator user ID (John Smith)
    '66666666-6666-6666-6666-666666666662', -- Delegate user ID (Emily Johnson)
    CURRENT_TIMESTAMP, -- Start date
    CURRENT_TIMESTAMP + INTERVAL '7 days', -- End date
    'Vacation coverage', -- Reason
    '66666666-6666-6666-6666-666666666661', -- Created by
    NULL -- OUT parameter for delegation_id
);
```

### 6. add_user_to_groups_proc
Adds a user to multiple groups in one operation.
```sql
CALL add_user_to_groups_proc(
    '66666666-6666-6666-6666-666666666661', -- User ID (John Smith)
    ARRAY['55555555-5555-5555-5555-555555555552', '55555555-5555-5555-5555-555555555553'], -- User group IDs
    '66666666-6666-6666-6666-666666666661' -- Created by
);
```

### 7. audit_permission_changes_proc
Records permission changes in the audit log.
```sql
CALL audit_permission_changes_proc(
    '66666666-6666-6666-6666-666666666661', -- User ID
    'PERMISSION_GRANT', -- Action
    'USER', -- Entity type
    '66666666-6666-6666-6666-666666666662', -- Entity ID
    '{"permission": "INITIATE_PAYMENT", "scope": "ACCOUNT", "scope_id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"}' -- Details
);
```

## Utility Functions

### 1. get_user_hierarchy_path
Returns the complete hierarchy path for a user.
```sql
SELECT * FROM get_user_hierarchy_path('66666666-6666-6666-6666-666666666661');
```

### 2. get_approval_requirements
Determines approval requirements for a transaction.
```sql
SELECT * FROM get_approval_requirements(
    '44444444-4444-4444-4444-444444444441', -- Toyota North America client entity
    '88888888-8888-8888-8888-888888888881', -- Wire Transfers product
    '99999999-9999-9999-9999-999999999991', -- Initiate Wire Transfer service
    75000.00, -- Amount
    'USD' -- Currency
);
```

### 3. check_account_access
Checks if a user has specific access to an account.
```sql
SELECT check_account_access(
    '66666666-6666-6666-6666-666666666661', -- John Smith user ID
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', -- Toyota NA Operating Account
    'VIEW_BALANCE'
);
```

### 4. get_delegated_permissions
Gets permissions delegated to a user.
```sql
SELECT * FROM get_delegated_permissions('66666666-6666-6666-6666-666666666662');
```

### 5. calculate_effective_approval_limit
Calculates the effective approval limit for a user.
```sql
SELECT calculate_effective_approval_limit(
    '66666666-6666-6666-6666-666666666661', -- John Smith user ID
    '88888888-8888-8888-8888-888888888881', -- Wire Transfers product
    '99999999-9999-9999-9999-999999999992', -- Approve Wire Transfer service
    NULL, -- No specific account
    'USD'
);
```

### 6. is_in_approval_group
Checks if a user is in a specific approval group.
```sql
SELECT is_in_approval_group(
    '66666666-6666-6666-6666-666666666663', -- Michael Brown user ID
    'dddddddd-dddd-dddd-dddd-ddddddddddda' -- Toyota NA Payment Approvers group
);
```

### 7. get_permission_source
Identifies the source of a user's permission.
```sql
SELECT * FROM get_permission_source(
    '66666666-6666-6666-6666-666666666661', -- John Smith user ID
    'VIEW_BALANCE',
    'ACCOUNT',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' -- Toyota NA Operating Account
);
```

### 8. can_approve_transaction
Determines if a user can approve a specific transaction.
```sql
SELECT can_approve_transaction(
    '66666666-6666-6666-6666-666666666663', -- Michael Brown user ID
    '44444444-4444-4444-4444-444444444441', -- Toyota North America client entity
    '88888888-8888-8888-8888-888888888881', -- Wire Transfers product
    '99999999-9999-9999-9999-999999999992', -- Approve Wire Transfer service
    30000.00, -- Amount
    'USD' -- Currency
);
```

## Example Queries

The system includes over 30 example queries organized into 10 categories:

### 1. User Permission Queries
Queries to find permissions for users and users with specific permissions.

### 2. Approval Workflow Queries
Queries to find approval workflows, approvers, and check approval requirements.

### 3. Client Hierarchy Queries
Queries to show client hierarchies and find users in specific entities.

### 4. Product Access Queries
Queries to find users with access to products and products a user can access.

### 5. Account Access Queries
Queries to find accounts a user can access and users who can access specific accounts.

### 6. Delegation Queries
Queries to find active delegations and delegated permissions.

### 7. Audit Trail Queries
Queries to find permission changes, login attempts, and payment approvals.

### 8. Approval Limit Queries
Queries to find users who can approve transactions and check approval limits.

### 9. Permission Override Queries
Queries to find denied permissions and permission overrides.

### 10. User Group Membership Queries
Queries to find group memberships and permissions granted through groups.

## Usage Examples

### Example 1: Finding Users Who Can Approve High-Value Payments

To find all users who can approve wire transfers over $50,000:

```sql
SELECT 
    u.username,
    u.first_name,
    u.last_name,
    ce.name AS client_entity_name,
    al.currency,
    al.max_amount
FROM approval_limits al
JOIN users u ON al.user_id = u.user_id
JOIN client_entities ce ON u.client_entity_id = ce.client_entity_id
WHERE al.currency = 'USD'
AND al.product_id = '88888888-8888-8888-8888-888888888881' -- Wire Transfers product
AND al.max_amount >= 50000
ORDER BY al.max_amount DESC, u.username;
```

### Example 2: Setting Up a New Client with Permissions

To set up a new client with basic permissions:

```sql
-- Step 1: Create client hierarchy
DO $$
DECLARE
    v_client_group_id UUID;
    v_client_entity_id UUID;
BEGIN
    CALL create_client_hierarchy_proc(
        '11111111-1111-1111-1111-111111111111', -- ABC Bank
        'New Client Corp',
        'New corporate client',
        'New Client US',
        'New York',
        '11111111-1111-1111-1111-111111111112', -- Americas region
        v_client_group_id,
        v_client_entity_id
    );
    
    -- Step 2: Create a user
    INSERT INTO users (
        user_id,
        client_entity_id,
        username,
        email,
        first_name,
        last_name,
        status
    ) VALUES (
        uuid_generate_v4(),
        v_client_entity_id,
        'newuser',
        'newuser@newclient.com',
        'New',
        'User',
        'ACTIVE'
    );
    
    -- Step 3: Grant basic permissions at client entity level
    CALL grant_permission_proc(
        'CLIENT_ENTITY',
        v_client_entity_id,
        'VIEW_ACCOUNT',
        'GLOBAL',
        NULL,
        NULL
    );
    
    CALL grant_permission_proc(
        'CLIENT_ENTITY',
        v_client_entity_id,
        'VIEW_BALANCE',
        'GLOBAL',
        NULL,
        NULL
    );
END $$;
```

### Example 3: Checking Effective Permissions

To check if a user has effective permission to perform an operation:

```sql
-- Check if John Smith can initiate a wire transfer from Toyota NA Operating Account
SELECT has_permission(
    '66666666-6666-6666-6666-666666666661', -- John Smith user ID
    'INITIATE_PAYMENT',
    'ACCOUNT',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' -- Toyota NA Operating Account
);

-- If you want to know where this permission comes from
SELECT * FROM get_permission_source(
    '66666666-6666-6666-6666-666666666661', -- John Smith user ID
    'INITIATE_PAYMENT',
    'ACCOUNT',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' -- Toyota NA Operating Account
);
```

### Example 4: Setting Up Approval Workflow

To set up a new approval workflow for high-value payments:

```sql
DO $$
DECLARE
    v_workflow_id UUID;
    v_approval_group_id UUID;
BEGIN
    CALL setup_approval_workflow_proc(
        '44444444-4444-4444-4444-444444444441', -- Toyota North America
        '88888888-8888-8888-8888-888888888881', -- Wire Transfers
        '99999999-9999-9999-9999-999999999992', -- Approve Wire Transfer
        2, -- Require 2 approvers
        100000.00, -- For amounts over $100,000
        'USD',
        'Toyota NA Very High-Value Wire Transfer Approval',
        'Toyota NA Executive Approvers',
        ARRAY['66666666-6666-6666-6666-666666666661', '66666666-6666-6666-6666-666666666663'],
        v_workflow_id,
        v_approval_group_id
    );
END $$;
```

### Example 5: Delegating Permissions During Vacation

To delegate permissions when a user goes on vacation:

```sql
DO $$
DECLARE
    v_delegation_id UUID;
BEGIN
    CALL delegate_permissions_proc(
        '66666666-6666-6666-6666-666666666661', -- John Smith (going on vacation)
        '66666666-6666-6666-6666-666666666662', -- Emily Johnson (covering)
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP + INTERVAL '14 days',
        'Annual leave coverage',
        '66666666-6666-6666-6666-666666666661',
        v_delegation_id
    );
END $$;
```

## Conclusion

These additional database components provide a comprehensive set of tools for managing the Cash Management Entitlement System. The views make it easy to query complex relationships, the stored procedures simplify common operations, the utility functions provide essential permission checks, and the example queries demonstrate how to use all these components effectively.

By implementing these components, the system becomes more maintainable, easier to use, and more powerful in its ability to manage complex entitlements in a banking environment.
