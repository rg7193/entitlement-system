-- Example Queries for Cash Management Entitlement System

-- 1. User Permission Queries

-- 1.1 Find all permissions for a specific user
SELECT * FROM user_entitlements_view
WHERE username = 'jsmith'
ORDER BY permission_name;

-- 1.2 Find all users who have a specific permission
SELECT u.username, u.first_name, u.last_name, ce.name AS client_entity_name
FROM effective_user_permissions eup
JOIN users u ON eup.user_id = u.user_id
JOIN client_entities ce ON u.client_entity_id = ce.client_entity_id
WHERE eup.permission_code = 'INITIATE_PAYMENT'
AND eup.is_granted = TRUE
ORDER BY ce.name, u.username;

-- 1.3 Find users with permission to a specific account
SELECT u.username, u.first_name, u.last_name, p.name AS permission_name
FROM account_access_view aav
JOIN users u ON aav.user_id = u.user_id
JOIN permissions p ON aav.permission_id = p.permission_id
WHERE aav.account_number = '1001001001'
AND aav.is_granted = TRUE
ORDER BY u.username, p.name;

-- 2. Approval Workflow Queries

-- 2.1 Find approval workflows for specific amounts
SELECT 
    aw.description, 
    aw.min_approvers, 
    aw.threshold_amount, 
    aw.currency,
    ce.name AS client_entity_name,
    p.name AS product_name,
    s.name AS service_name
FROM approval_workflows aw
JOIN client_entities ce ON aw.client_entity_id = ce.client_entity_id
LEFT JOIN products p ON aw.product_id = p.product_id
LEFT JOIN services s ON aw.service_id = s.service_id
WHERE aw.currency = 'USD'
AND (aw.threshold_amount IS NULL OR aw.threshold_amount <= 50000)
ORDER BY aw.threshold_amount DESC NULLS LAST;

-- 2.2 Find approvers for a specific workflow
SELECT 
    u.username, 
    u.first_name, 
    u.last_name, 
    ag.name AS approval_group_name,
    wag.approval_level
FROM workflow_approval_groups wag
JOIN approval_groups ag ON wag.approval_group_id = ag.approval_group_id
JOIN approval_group_members agm ON agm.approval_group_id = ag.approval_group_id
JOIN users u ON agm.user_id = u.user_id
WHERE wag.workflow_id = 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeea'
ORDER BY wag.approval_level, u.username;

-- 2.3 Check if a transaction requires approval
SELECT * FROM get_approval_requirements(
    '44444444-4444-4444-4444-444444444441', -- Toyota North America client entity
    '88888888-8888-8888-8888-888888888881', -- Wire Transfers product
    '99999999-9999-9999-9999-999999999991', -- Initiate Wire Transfer service
    75000.00, -- Amount
    'USD' -- Currency
);

-- 3. Client Hierarchy Queries

-- 3.1 Show complete client hierarchy
SELECT * FROM client_hierarchy_view
WHERE bank_name = 'ABC Bank'
ORDER BY region_name, client_group_name, client_entity_name, username;

-- 3.2 Find all users in a specific client entity
SELECT u.username, u.first_name, u.last_name, u.email
FROM users u
JOIN client_entities ce ON u.client_entity_id = ce.client_entity_id
WHERE ce.name = 'Toyota North America'
AND u.status = 'ACTIVE'
ORDER BY u.username;

-- 3.3 Find all client entities in a specific region
SELECT ce.name AS client_entity_name, ce.location, cg.name AS client_group_name
FROM client_entities ce
JOIN client_groups cg ON ce.client_group_id = cg.client_group_id
JOIN regions r ON ce.region_id = r.region_id
WHERE r.name = 'Americas'
AND r.bank_id = '11111111-1111-1111-1111-111111111111' -- ABC Bank
ORDER BY cg.name, ce.name;

-- 4. Product Access Queries

-- 4.1 Find all users with access to a specific product
SELECT 
    u.username, 
    u.first_name, 
    u.last_name, 
    ce.name AS client_entity_name,
    p.code AS permission_code
FROM effective_user_permissions eup
JOIN users u ON eup.user_id = u.user_id
JOIN client_entities ce ON u.client_entity_id = ce.client_entity_id
JOIN permissions p ON eup.permission_id = p.permission_id
WHERE eup.scope_type = 'PRODUCT'
AND eup.scope_id = '88888888-8888-8888-8888-888888888881' -- Wire Transfers product
AND eup.is_granted = TRUE
ORDER BY ce.name, u.username;

-- 4.2 Find all products a user has access to
SELECT 
    pr.name AS product_name, 
    pc.name AS category_name,
    p.name AS permission_name
FROM user_entitlements_view uev
JOIN products pr ON uev.scope_id = pr.product_id
JOIN product_categories pc ON pr.product_category_id = pc.product_category_id
JOIN permissions p ON uev.permission_id = p.permission_id
WHERE uev.username = 'jsmith'
AND uev.scope_type = 'PRODUCT'
AND uev.is_granted = TRUE
ORDER BY pc.name, pr.name;

-- 4.3 Find all services a user has access to
SELECT 
    s.name AS service_name, 
    pr.name AS product_name,
    p.name AS permission_name
FROM user_entitlements_view uev
JOIN services s ON uev.scope_id = s.service_id
JOIN products pr ON s.product_id = pr.product_id
JOIN permissions p ON uev.permission_id = p.permission_id
WHERE uev.username = 'jsmith'
AND uev.scope_type = 'SERVICE'
AND uev.is_granted = TRUE
ORDER BY pr.name, s.name;

-- 5. Account Access Queries

-- 5.1 Find all accounts a user has access to
SELECT 
    a.account_number, 
    a.account_name, 
    a.currency,
    ce.name AS client_entity_name,
    p.name AS permission_name
FROM account_access_view aav
JOIN accounts a ON aav.account_id = a.account_id
JOIN client_entities ce ON a.client_entity_id = ce.client_entity_id
JOIN permissions p ON aav.permission_id = p.permission_id
WHERE aav.username = 'jsmith'
AND aav.is_granted = TRUE
ORDER BY ce.name, a.account_name;

-- 5.2 Find users who can initiate payments from a specific account
SELECT 
    u.username, 
    u.first_name, 
    u.last_name, 
    ce.name AS client_entity_name
FROM account_access_view aav
JOIN users u ON aav.user_id = u.user_id
JOIN client_entities ce ON u.client_entity_id = ce.client_entity_id
WHERE aav.account_number = '1001001001'
AND aav.permission_code = 'INITIATE_PAYMENT'
AND aav.is_granted = TRUE
ORDER BY ce.name, u.username;

-- 5.3 Check if a specific user has access to a specific account
SELECT check_account_access(
    '66666666-6666-6666-6666-666666666661', -- John Smith user ID
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', -- Toyota NA Operating Account
    'VIEW_BALANCE'
);

-- 6. Delegation Queries

-- 6.1 Find all active delegations
SELECT * FROM active_delegations_view
WHERE is_active = TRUE
ORDER BY delegator_username;

-- 6.2 Find all permissions delegated to a specific user
SELECT * FROM get_delegated_permissions(
    '66666666-6666-6666-6666-666666666662' -- Emily Johnson user ID
);

-- 6.3 Find users who have delegated their permissions
SELECT 
    u_delegator.username AS delegator_username, 
    u_delegator.first_name || ' ' || u_delegator.last_name AS delegator_name,
    u_delegate.username AS delegate_username,
    u_delegate.first_name || ' ' || u_delegate.last_name AS delegate_name,
    d.start_date,
    d.end_date,
    d.reason
FROM delegations d
JOIN users u_delegator ON d.delegator_user_id = u_delegator.user_id
JOIN users u_delegate ON d.delegate_user_id = u_delegate.user_id
WHERE d.status = 'APPROVED'
AND d.start_date <= CURRENT_TIMESTAMP
AND d.end_date >= CURRENT_TIMESTAMP
ORDER BY u_delegator.username;

-- 7. Audit Trail Queries

-- 7.1 Find all permission changes for a specific user
SELECT 
    al.created_at,
    al.action,
    al.details,
    u_actor.username AS actor_username
FROM audit_logs al
LEFT JOIN users u_actor ON al.user_id = u_actor.user_id
WHERE al.entity_type = 'USER'
AND al.entity_id = '66666666-6666-6666-6666-666666666661' -- John Smith user ID
AND al.action LIKE 'PERMISSION%'
ORDER BY al.created_at DESC;

-- 7.2 Find all login attempts
SELECT 
    al.created_at,
    u.username,
    u.first_name,
    u.last_name,
    al.details->>'ip' AS ip_address,
    al.details->>'success' AS success
FROM audit_logs al
JOIN users u ON al.user_id = u.user_id
WHERE al.action = 'LOGIN'
ORDER BY al.created_at DESC;

-- 7.3 Find all payment approvals
SELECT 
    al.created_at,
    u.username,
    u.first_name,
    u.last_name,
    al.details->>'payment_id' AS payment_id,
    al.details->>'amount' AS amount,
    al.details->>'currency' AS currency
FROM audit_logs al
JOIN users u ON al.user_id = u.user_id
WHERE al.action = 'PAYMENT_APPROVE'
ORDER BY al.created_at DESC;

-- 8. Approval Limit Queries

-- 8.1 Find users who can approve transactions of specific amounts
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
AND al.max_amount >= 50000
ORDER BY al.max_amount DESC, u.username;

-- 8.2 Find the effective approval limit for a user
SELECT calculate_effective_approval_limit(
    '66666666-6666-6666-6666-666666666661', -- John Smith user ID
    '88888888-8888-8888-8888-888888888881', -- Wire Transfers product
    '99999999-9999-9999-9999-999999999992', -- Approve Wire Transfer service
    NULL, -- No specific account
    'USD'
);

-- 8.3 Check if a user can approve a specific transaction
SELECT can_approve_transaction(
    '66666666-6666-6666-6666-666666666663', -- Michael Brown user ID
    '44444444-4444-4444-4444-444444444441', -- Toyota North America client entity
    '88888888-8888-8888-8888-888888888881', -- Wire Transfers product
    '99999999-9999-9999-9999-999999999992', -- Approve Wire Transfer service
    30000.00, -- Amount
    'USD' -- Currency
);

-- 9. Permission Override Queries

-- 9.1 Find permissions that are explicitly denied
SELECT 
    u.username,
    u.first_name,
    u.last_name,
    ce.name AS client_entity_name,
    p.name AS permission_name,
    p.code AS permission_code,
    psv.source_type,
    psv.source_name
FROM permission_source_view psv
JOIN users u ON psv.user_id = u.user_id
JOIN client_entities ce ON u.client_entity_id = ce.client_entity_id
JOIN permissions p ON psv.permission_id = p.permission_id
WHERE psv.is_denied = TRUE
ORDER BY ce.name, u.username, p.name;

-- 9.2 Find permissions that are overridden at lower levels
WITH permission_levels AS (
    SELECT 
        psv.user_id,
        psv.permission_code,
        psv.scope_type,
        psv.scope_id,
        CASE 
            WHEN psv.source_type = 'BANK' THEN 1
            WHEN psv.source_type = 'REGION' THEN 2
            WHEN psv.source_type = 'CLIENT_GROUP' THEN 3
            WHEN psv.source_type = 'CLIENT_ENTITY' THEN 4
            WHEN psv.source_type = 'USER_GROUP' THEN 5
            WHEN psv.source_type = 'USER' THEN 6
            ELSE 0
        END AS level_order,
        psv.source_type,
        psv.source_name,
        psv.is_denied
    FROM permission_source_view psv
)
SELECT 
    u.username,
    u.first_name,
    u.last_name,
    pl.permission_code,
    pl.scope_type,
    pl.scope_id,
    pl.source_type,
    pl.source_name,
    pl.is_denied
FROM permission_levels pl
JOIN users u ON pl.user_id = u.user_id
WHERE EXISTS (
    SELECT 1
    FROM permission_levels pl2
    WHERE pl2.user_id = pl.user_id
    AND pl2.permission_code = pl.permission_code
    AND pl2.scope_type = pl.scope_type
    AND COALESCE(pl2.scope_id, '00000000-0000-0000-0000-000000000000') = COALESCE(pl.scope_id, '00000000-0000-0000-0000-000000000000')
    AND pl2.level_order < pl.level_order
)
ORDER BY u.username, pl.permission_code, pl.level_order;

-- 9.3 Find the source of a specific permission for a user
SELECT * FROM get_permission_source(
    '66666666-6666-6666-6666-666666666661', -- John Smith user ID
    'VIEW_BALANCE',
    'ACCOUNT',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' -- Toyota NA Operating Account
);

-- 10. User Group Membership Queries

-- 10.1 Find all groups a user belongs to
SELECT 
    ug.name AS user_group_name,
    ug.description,
    ce.name AS client_entity_name
FROM user_group_members ugm
JOIN user_groups ug ON ugm.user_group_id = ug.user_group_id
JOIN client_entities ce ON ug.client_entity_id = ce.client_entity_id
WHERE ugm.user_id = '66666666-6666-6666-6666-666666666661' -- John Smith user ID
ORDER BY ug.name;

-- 10.2 Find all members of a specific group
SELECT 
    u.username,
    u.first_name,
    u.last_name,
    u.email
FROM user_group_members ugm
JOIN users u ON ugm.user_id = u.user_id
WHERE ugm.user_group_id = '55555555-5555-5555-5555-555555555551' -- Finance Administrators group
ORDER BY u.username;

-- 10.3 Find permissions granted through group membership
SELECT 
    u.username,
    u.first_name,
    u.last_name,
    ug.name AS user_group_name,
    p.name AS permission_name,
    p.code AS permission_code,
    psv.scope_type,
    psv.scope_name
FROM permission_source_view psv
JOIN users u ON psv.user_id = u.user_id
JOIN user_groups ug ON psv.source_id = ug.user_group_id
JOIN permissions p ON psv.permission_id = p.permission_id
WHERE psv.source_type = 'USER_GROUP'
AND psv.is_denied = FALSE
ORDER BY ug.name, u.username, p.name;
