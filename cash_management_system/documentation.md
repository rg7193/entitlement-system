# Cash Management Entitlement System - Documentation

## System Overview

The Cash Management Entitlement System is a comprehensive solution designed for banking institutions to manage access control and permissions for their cash management services. The system implements a hierarchical permission model that allows banks to define permissions at various organizational levels and supports complex approval workflows for financial transactions.

## Key Features

1. **Multi-level Organizational Hierarchy**
   - Bank → Region → Client Group → Client Entity → User Group → User
   - Permissions can be defined at any level and inherited downward

2. **Product and Service Categorization**
   - Product Categories → Products → Services
   - Granular permission control at each level

3. **Flexible Permission Model**
   - Global permissions
   - Product/service-specific permissions
   - Account-specific permissions
   - Permission inheritance with override capability
   - Explicit permission denial

4. **Approval Workflows**
   - Multi-level approval processes
   - Amount-based approval thresholds
   - Approval groups with designated approvers
   - Four-eyes principle implementation

5. **User Management**
   - User grouping for simplified permission assignment
   - Temporary permission delegation
   - Comprehensive audit logging

## Database Schema

The system is implemented using PostgreSQL and consists of the following key components:

### Organizational Structure Tables
- `banks` - Root entities in the system
- `regions` - Geographic divisions of banks
- `client_groups` - Parent organizations using the system
- `client_entities` - Specific business units of client groups
- `user_groups` - Collections of users with similar roles
- `users` - Individual system users

### Product Structure Tables
- `product_categories` - High-level product groupings
- `products` - Specific financial products
- `services` - Specific services within products
- `accounts` - Financial accounts

### Permission Structure Tables
- `permissions` - Granular system capabilities
- `roles` - Collections of permissions
- `entitlements` - Assignment of permissions to entities
- `approval_limits` - Transaction amount limits
- `approval_workflows` - Multi-level approval requirements
- `approval_groups` - Groups of users who can approve transactions

### Support Tables
- `delegations` - Temporary delegation of permissions
- `audit_logs` - Tracking of all system activities

## Permission Hierarchy Implementation

The system implements a hierarchical permission model where permissions flow from higher organizational levels to lower levels, with the ability for lower levels to override permissions from higher levels.

### Permission Inheritance Flow

1. **Bank Level** - Affects all entities in the system
2. **Region Level** - Affects all clients in a specific region
3. **Product Level** - Affects all users of a specific product
4. **Client Group Level** - Affects all entities in a client group
5. **Client Entity Level** - Affects all users in a client entity
6. **Account Level** - Affects operations on specific accounts
7. **User Group Level** - Affects all users in a group
8. **User Level** - Affects specific individual users

### Permission Resolution

The system resolves effective permissions through a database view that:
1. Collects all permissions from all levels of the hierarchy
2. Applies override rules based on the hierarchy
3. Resolves conflicts with explicit denials taking precedence

## Usage Examples

### Example 1: Setting Up a New Client

To set up a new client in the system:

1. Create a client group record
```sql
INSERT INTO client_groups (client_group_id, bank_id, name, description, status)
VALUES (uuid_generate_v4(), '11111111-1111-1111-1111-111111111111', 'New Client Corp', 'New corporate client', 'ACTIVE');
```

2. Create client entity records
```sql
INSERT INTO client_entities (client_entity_id, client_group_id, region_id, name, location, status)
VALUES (uuid_generate_v4(), 'newly_created_client_group_id', '11111111-1111-1111-1111-111111111112', 'New Client US', 'New York', 'ACTIVE');
```

3. Create user groups
```sql
INSERT INTO user_groups (user_group_id, client_entity_id, name, description, status)
VALUES (uuid_generate_v4(), 'newly_created_client_entity_id', 'Finance Administrators', 'Users who manage financial operations', 'ACTIVE');
```

4. Create users
```sql
INSERT INTO users (user_id, client_entity_id, username, email, first_name, last_name, status)
VALUES (uuid_generate_v4(), 'newly_created_client_entity_id', 'jdoe', 'john.doe@newclient.com', 'John', 'Doe', 'ACTIVE');
```

5. Assign users to groups
```sql
INSERT INTO user_group_members (user_id, user_group_id)
VALUES ('newly_created_user_id', 'newly_created_user_group_id');
```

### Example 2: Granting Permissions

To grant permissions at different levels:

1. Bank-level permission (affects all users)
```sql
INSERT INTO entitlements (entity_type, entity_id, permission_id, scope_type, scope_id, is_denied, created_by)
VALUES ('BANK', 'bank_id', 'view_account_permission_id', 'GLOBAL', NULL, FALSE, 'admin_user_id');
```

2. Client Group-level permission
```sql
INSERT INTO entitlements (entity_type, entity_id, permission_id, scope_type, scope_id, is_denied, created_by)
VALUES ('CLIENT_GROUP', 'client_group_id', 'initiate_payment_permission_id', 'PRODUCT', 'wire_transfer_product_id', FALSE, 'admin_user_id');
```

3. User-level permission
```sql
INSERT INTO entitlements (entity_type, entity_id, permission_id, scope_type, scope_id, is_denied, created_by)
VALUES ('USER', 'user_id', 'approve_payment_permission_id', 'ACCOUNT', 'specific_account_id', FALSE, 'admin_user_id');
```

### Example 3: Setting Up Approval Workflows

To set up an approval workflow:

1. Create an approval group
```sql
INSERT INTO approval_groups (approval_group_id, client_entity_id, name, description, status)
VALUES (uuid_generate_v4(), 'client_entity_id', 'Payment Approvers', 'Group for payment approvers', 'ACTIVE');
```

2. Add users to the approval group
```sql
INSERT INTO approval_group_members (approval_group_id, user_id)
VALUES ('approval_group_id', 'approver_user_id');
```

3. Create an approval workflow
```sql
INSERT INTO approval_workflows (workflow_id, client_entity_id, product_id, service_id, min_approvers, threshold_amount, currency, description)
VALUES (uuid_generate_v4(), 'client_entity_id', 'wire_transfer_product_id', 'approve_wire_service_id', 2, 50000.00, 'USD', 'Wire Transfer Approval');
```

4. Link the approval group to the workflow
```sql
INSERT INTO workflow_approval_groups (workflow_id, approval_group_id, approval_level)
VALUES ('workflow_id', 'approval_group_id', 1);
```

### Example 4: Setting Approval Limits

To set approval limits for users:

```sql
INSERT INTO approval_limits (limit_id, user_id, product_id, service_id, account_id, currency, min_amount, max_amount)
VALUES (uuid_generate_v4(), 'user_id', 'wire_transfer_product_id', 'approve_wire_service_id', NULL, 'USD', 0.00, 25000.00);
```

### Example 5: Temporary Permission Delegation

To delegate permissions temporarily:

```sql
INSERT INTO delegations (delegation_id, delegator_user_id, delegate_user_id, start_date, end_date, reason, status)
VALUES (uuid_generate_v4(), 'delegator_user_id', 'delegate_user_id', '2025-04-15 09:00:00', '2025-04-20 17:00:00', 'Vacation coverage', 'APPROVED');
```

## Permission Override Examples

### Example 1: Bank-level permission overridden at Client Entity level

1. Bank grants "VIEW_ACCOUNT_BALANCE" permission to all users
```sql
INSERT INTO entitlements (entity_type, entity_id, permission_id, scope_type, scope_id, is_denied, created_by)
VALUES ('BANK', 'bank_id', 'view_balance_permission_id', 'GLOBAL', NULL, FALSE, 'admin_user_id');
```

2. A specific Client Entity explicitly denies "VIEW_ACCOUNT_BALANCE" for its users
```sql
INSERT INTO entitlements (entity_type, entity_id, permission_id, scope_type, scope_id, is_denied, created_by)
VALUES ('CLIENT_ENTITY', 'client_entity_id', 'view_balance_permission_id', 'GLOBAL', NULL, TRUE, 'admin_user_id');
```

Result: Users in that Client Entity cannot view account balances, while all other users can.

### Example 2: Product-level permission overridden at User level

1. A "PAYMENT" product has "INITIATE_PAYMENT" permission granted at the product level
```sql
INSERT INTO entitlements (entity_type, entity_id, permission_id, scope_type, scope_id, is_denied, created_by)
VALUES ('BANK', 'bank_id', 'initiate_payment_permission_id', 'PRODUCT', 'payment_product_id', FALSE, 'admin_user_id');
```

2. A specific user is explicitly denied the "INITIATE_PAYMENT" permission
```sql
INSERT INTO entitlements (entity_type, entity_id, permission_id, scope_type, scope_id, is_denied, created_by)
VALUES ('USER', 'user_id', 'initiate_payment_permission_id', 'PRODUCT', 'payment_product_id', TRUE, 'admin_user_id');
```

Result: That user cannot initiate payments, while other users with access to the product can.

## Best Practices

1. **Permission Assignment**
   - Assign permissions at the highest appropriate level to minimize maintenance
   - Use explicit denials sparingly and only when necessary
   - Document all permission assignments, especially overrides

2. **Approval Workflows**
   - Set appropriate approval thresholds based on risk assessment
   - Ensure sufficient approvers are available for each workflow
   - Consider time zones when setting up approval groups

3. **Audit and Compliance**
   - Regularly review audit logs for suspicious activities
   - Conduct periodic permission reviews to ensure least privilege
   - Document all permission changes for compliance purposes

4. **User Management**
   - Implement a formal user onboarding and offboarding process
   - Regularly review user access and remove unnecessary permissions
   - Use delegation for temporary access needs rather than permanent permission changes

## Troubleshooting

### Common Issues

1. **Permission Inheritance Issues**
   - Check for explicit denials at any level in the hierarchy
   - Verify that the entity relationships are correctly set up
   - Use the `has_permission` function to check effective permissions

2. **Approval Workflow Problems**
   - Ensure sufficient approvers are assigned to approval groups
   - Verify that approval thresholds are correctly set
   - Check that workflow_approval_groups mappings are complete

3. **Performance Considerations**
   - The permission resolution view may become slow with large numbers of entitlements
   - Consider materializing the view or implementing caching for production environments
   - Use appropriate indexing on the entitlements table

## Conclusion

The Cash Management Entitlement System provides a flexible and powerful framework for managing permissions in a banking environment. By leveraging the hierarchical permission model and comprehensive approval workflows, banks can ensure secure and controlled access to their cash management services while maintaining the flexibility to adapt to changing business needs.
