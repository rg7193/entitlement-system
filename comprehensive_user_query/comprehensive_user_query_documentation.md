# Comprehensive User Information Query Documentation

## Overview

This document explains the comprehensive user information query that returns all data related to a specific user in the Cash Management Entitlement System. The query takes a single user ID parameter and returns a complete JSON object containing all user-related information, including personal details, organizational hierarchy, entitlements, products, services, accounts, approval limits, and more.

## Query Structure

The query uses Common Table Expressions (CTEs) to gather information from various parts of the system:

1. **user_info**: Basic user information and organizational hierarchy
2. **user_groups**: User group memberships
3. **user_entitlements**: User entitlements with scope information
4. **user_products**: Products the user has access to
5. **user_services**: Services the user has access to
6. **user_accounts**: Accounts the user has access to
7. **user_approval_limits**: User's approval limits
8. **user_approval_groups**: User's approval group memberships
9. **user_approval_workflows**: Approval workflows the user is part of
10. **user_delegations_from**: Delegations from this user to others
11. **user_delegations_to**: Delegations to this user from others

The final result combines all this information into a JSON object for easy consumption.

## Usage

To use this query, simply replace the `:user_id` parameter with the actual UUID of the user you want to query:

```sql
-- For PostgreSQL with parameter binding
SELECT * FROM comprehensive_user_query('66666666-6666-6666-6666-666666666661');

-- Or with direct substitution
WITH user_info AS (
    -- ... (query body)
    WHERE u.user_id = '66666666-6666-6666-6666-666666666661'
),
-- ... (rest of query)
```

## Output Format

The query returns a single JSON object with the following structure:

```json
{
  "user_info": {
    "user_id": "66666666-6666-6666-6666-666666666661",
    "username": "jsmith",
    "first_name": "John",
    "last_name": "Smith",
    "email": "john.smith@toyota.com",
    "user_status": "ACTIVE",
    "client_entity_id": "44444444-4444-4444-4444-444444444441",
    "client_entity_name": "Toyota North America",
    "client_entity_location": "New York",
    "client_group_id": "33333333-3333-3333-3333-333333333331",
    "client_group_name": "Toyota Corporation",
    "region_id": "11111111-1111-1111-1111-111111111112",
    "region_name": "Americas",
    "bank_id": "11111111-1111-1111-1111-111111111111",
    "bank_name": "ABC Bank"
  },
  "user_groups": [
    {
      "user_group_id": "55555555-5555-5555-5555-555555555551",
      "user_group_name": "Finance Administrators",
      "user_group_description": "Users who manage financial operations"
    }
  ],
  "entitlements": [
    {
      "permission_id": "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbba",
      "permission_code": "VIEW_ACCOUNT",
      "permission_name": "View Account",
      "scope_type": "GLOBAL",
      "scope_id": null,
      "scope_name": "Global",
      "is_granted": true,
      "source_type": "BANK",
      "permission_source": "ABC Bank"
    },
    // Additional entitlements...
  ],
  "products": [
    {
      "product_id": "88888888-8888-8888-8888-888888888881",
      "product_name": "Wire Transfers",
      "product_description": "Electronic funds transfers",
      "product_category_id": "77777777-7777-7777-7777-777777777771",
      "product_category_name": "Payments"
    },
    // Additional products...
  ],
  "services": [
    {
      "service_id": "99999999-9999-9999-9999-999999999991",
      "service_name": "Initiate Wire Transfer",
      "service_description": "Create a new wire transfer",
      "product_id": "88888888-8888-8888-8888-888888888881",
      "product_name": "Wire Transfers"
    },
    // Additional services...
  ],
  "accounts": [
    {
      "account_id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
      "account_number": "1001001001",
      "account_name": "Toyota NA Operating Account",
      "currency": "USD",
      "account_type": "CURRENT",
      "client_entity_name": "Toyota North America",
      "permissions": "View Account, View Balance, Initiate Payment"
    },
    // Additional accounts...
  ],
  "approval_limits": [
    {
      "limit_id": "ffffffff-ffff-ffff-ffff-fffffffffff1",
      "product_id": "88888888-8888-8888-8888-888888888881",
      "product_name": "Wire Transfers",
      "service_id": "99999999-9999-9999-9999-999999999992",
      "service_name": "Approve Wire Transfer",
      "account_id": null,
      "account_name": null,
      "currency": "USD",
      "min_amount": 0.00,
      "max_amount": 100000.00
    },
    // Additional approval limits...
  ],
  "approval_groups": [
    {
      "approval_group_id": "dddddddd-dddd-dddd-dddd-ddddddddddda",
      "approval_group_name": "Toyota NA Payment Approvers",
      "approval_group_description": "Group for Toyota North America payment approvers",
      "client_entity_name": "Toyota North America"
    },
    // Additional approval groups...
  ],
  "approval_workflows": [
    {
      "workflow_id": "eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeea",
      "workflow_description": "Toyota NA Wire Transfer Approval",
      "min_approvers": 2,
      "threshold_amount": 50000.00,
      "currency": "USD",
      "product_name": "Wire Transfers",
      "service_name": "Approve Wire Transfer",
      "client_entity_name": "Toyota North America",
      "approval_group_name": "Toyota NA Payment Approvers",
      "approval_level": 1
    },
    // Additional approval workflows...
  ],
  "delegations_from": [
    {
      "delegation_id": "11111111-dddd-dddd-dddd-dddddddddddd",
      "delegate_username": "ejohnson",
      "delegate_name": "Emily Johnson",
      "start_date": "2025-04-15T09:00:00Z",
      "end_date": "2025-04-20T17:00:00Z",
      "reason": "Vacation coverage",
      "status": "APPROVED",
      "is_active": true
    },
    // Additional delegations from this user...
  ],
  "delegations_to": [
    // Delegations to this user from others...
  ]
}
```

## Key Benefits

1. **Comprehensive Information**: Returns all user-related data in a single query
2. **Hierarchical Structure**: Organizes data in a logical, hierarchical structure
3. **JSON Format**: Easy to parse and use in applications
4. **Single Parameter**: Only requires a user ID to retrieve all information
5. **Optimized Performance**: Uses CTEs for efficient data retrieval

## Performance Considerations

This query retrieves a significant amount of data and may be resource-intensive for users with many entitlements, accounts, or approval workflows. Consider the following optimizations if performance is a concern:

1. Create indexes on frequently queried columns, especially foreign keys
2. Consider materializing frequently accessed views
3. For very large systems, consider retrieving specific sections of data separately

## Example Usage Scenarios

1. **User Profile Page**: Display complete user information on a profile page
2. **Access Audit**: Review all permissions and entitlements for a specific user
3. **User Migration**: Export complete user data when migrating to a new system
4. **Troubleshooting**: Diagnose permission issues by examining the complete user context

## Implementation Notes

1. The query uses PostgreSQL-specific JSON functions (`json_build_object`, `json_agg`, `row_to_json`)
2. The `STRING_AGG` function is used to concatenate permissions for accounts
3. For other database systems, equivalent JSON functions would need to be used
4. The query can be wrapped in a stored function for easier reuse
