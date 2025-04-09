# Cash Management Entitlement System - Entity Analysis

## Core Entities Identified

### Organizational Hierarchy
1. **Bank** - The root entity (e.g., ABC Bank)
   - Attributes: bank_id, name, description, status
   - Role: Root administrator of the entire system

2. **Region/Branch** - Geographic divisions of the bank
   - Attributes: region_id, bank_id, name, location, status
   - Role: Regional administrators managing clients in specific geographic areas

3. **Client Group** - Organization using the cash management system
   - Attributes: client_group_id, name, description, status
   - Role: Parent organization that may have multiple entities (e.g., Toyota Corporation)

4. **Client Entity** - Specific business unit of a client group
   - Attributes: client_entity_id, client_group_id, name, location, status
   - Role: Specific business unit (e.g., Toyota New York, Toyota Japan)

5. **User Group** - Collection of users with similar roles
   - Attributes: user_group_id, client_entity_id, name, description, status
   - Role: Groups users by function (e.g., Payment Approvers, Finance Team)

6. **User** - Individual system users
   - Attributes: user_id, client_entity_id, user_group_id, username, status
   - Role: End users who perform operations in the system

### Product & Service Hierarchy
7. **Product Category** - High-level product grouping
   - Attributes: product_category_id, name, description, status
   - Role: Groups related products (e.g., Payments, Deposits, Loans)

8. **Product** - Specific financial product
   - Attributes: product_id, product_category_id, name, description, status
   - Role: Specific product offered (e.g., Wire Transfer, Term Deposit)

9. **Service** - Specific service within a product
   - Attributes: service_id, product_id, name, description, status
   - Role: Specific service or function (e.g., Initiate Payment, Approve Payment)

10. **Account** - Financial accounts
    - Attributes: account_id, client_entity_id, account_number, currency, status
    - Role: Accounts that users can operate on

### Permission Structure
11. **Permission** - Granular system capabilities
    - Attributes: permission_id, name, description, code
    - Role: Defines specific actions that can be performed

12. **Role** - Collection of permissions
    - Attributes: role_id, name, description
    - Role: Defines job functions with associated permissions

13. **Entitlement** - Assignment of permissions to entities
    - Attributes: entitlement_id, entity_type, entity_id, permission_id, scope_type, scope_id
    - Role: Links permissions to entities at various levels

14. **Approval Limit** - Transaction amount limits
    - Attributes: limit_id, user_id, product_id, service_id, currency, max_amount
    - Role: Defines maximum transaction amounts for users

15. **Approval Workflow** - Multi-level approval requirements
    - Attributes: workflow_id, product_id, service_id, min_approvers, threshold_amount
    - Role: Defines approval requirements based on transaction amounts

## Hierarchical Permission Inheritance

The system will implement a hierarchical permission model where permissions can be defined at multiple levels:

1. **Bank Level** - Permissions that apply to all entities in the system
2. **Region/Branch Level** - Permissions that apply to all clients in a region
3. **Product Level** - Permissions that apply to all users of a specific product
4. **Client Group Level** - Permissions that apply to all entities in a client group
5. **Client Entity Level** - Permissions that apply to all users in a client entity
6. **Account Level** - Permissions that apply to specific accounts
7. **User Group Level** - Permissions that apply to all users in a group
8. **User Level** - Permissions specific to individual users

## Permission Override Rules

Permissions defined at a higher level can be overridden at lower levels:

1. Bank level permissions are the default
2. Region/Branch can override Bank permissions
3. Product can override Region/Branch permissions
4. Client Group can override Product permissions
5. Client Entity can override Client Group permissions
6. Account can override Client Entity permissions
7. User Group can override Account permissions
8. User can override User Group permissions

## Special Considerations

1. **Negative Permissions** - Ability to explicitly deny permissions at any level
2. **Temporary Permissions** - Time-bound permissions for special circumstances
3. **Delegation** - Ability for users to temporarily delegate their permissions to others
4. **Four-Eyes Principle** - Requiring multiple users for sensitive operations
5. **Audit Trail** - Tracking all permission changes and access attempts
6. **Emergency Access** - Break-glass procedures for emergency situations
