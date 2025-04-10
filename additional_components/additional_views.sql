-- Additional Views for Cash Management Entitlement System

-- 1. Client Hierarchy View
-- Shows the complete organizational hierarchy from bank to users
CREATE OR REPLACE VIEW client_hierarchy_view AS
SELECT 
    b.bank_id,
    b.name AS bank_name,
    r.region_id,
    r.name AS region_name,
    cg.client_group_id,
    cg.name AS client_group_name,
    ce.client_entity_id,
    ce.name AS client_entity_name,
    ce.location AS client_entity_location,
    u.user_id,
    u.username,
    u.first_name,
    u.last_name,
    u.email
FROM 
    banks b
    LEFT JOIN regions r ON r.bank_id = b.bank_id
    LEFT JOIN client_groups cg ON cg.bank_id = b.bank_id
    LEFT JOIN client_entities ce ON ce.client_group_id = cg.client_group_id AND (ce.region_id = r.region_id OR ce.region_id IS NULL)
    LEFT JOIN users u ON u.client_entity_id = ce.client_entity_id
WHERE
    b.status = 'ACTIVE'
    AND (r.status = 'ACTIVE' OR r.status IS NULL)
    AND (cg.status = 'ACTIVE' OR cg.status IS NULL)
    AND (ce.status = 'ACTIVE' OR ce.status IS NULL)
    AND (u.status = 'ACTIVE' OR u.status IS NULL);

-- 2. User Entitlements View
-- Shows all entitlements for each user with readable names
CREATE OR REPLACE VIEW user_entitlements_view AS
SELECT 
    u.user_id,
    u.username,
    u.first_name,
    u.last_name,
    p.permission_id,
    p.name AS permission_name,
    p.code AS permission_code,
    eup.scope_type,
    CASE 
        WHEN eup.scope_type = 'GLOBAL' THEN 'Global'
        WHEN eup.scope_type = 'PRODUCT_CATEGORY' THEN pc.name
        WHEN eup.scope_type = 'PRODUCT' THEN pr.name
        WHEN eup.scope_type = 'SERVICE' THEN s.name
        WHEN eup.scope_type = 'ACCOUNT' THEN a.account_name
        ELSE 'Unknown'
    END AS scope_name,
    eup.scope_id,
    eup.is_granted
FROM 
    effective_user_permissions eup
    JOIN users u ON eup.user_id = u.user_id
    JOIN permissions p ON eup.permission_id = p.permission_id
    LEFT JOIN product_categories pc ON eup.scope_type = 'PRODUCT_CATEGORY' AND eup.scope_id = pc.product_category_id
    LEFT JOIN products pr ON eup.scope_type = 'PRODUCT' AND eup.scope_id = pr.product_id
    LEFT JOIN services s ON eup.scope_type = 'SERVICE' AND eup.scope_id = s.service_id
    LEFT JOIN accounts a ON eup.scope_type = 'ACCOUNT' AND eup.scope_id = a.account_id
WHERE
    u.status = 'ACTIVE';

-- 3. Account Access View
-- Shows which users have access to which accounts and what operations they can perform
CREATE OR REPLACE VIEW account_access_view AS
SELECT 
    a.account_id,
    a.account_number,
    a.account_name,
    a.currency,
    a.account_type,
    ce.client_entity_id,
    ce.name AS client_entity_name,
    cg.client_group_id,
    cg.name AS client_group_name,
    u.user_id,
    u.username,
    u.first_name,
    u.last_name,
    p.permission_id,
    p.name AS permission_name,
    p.code AS permission_code,
    eup.is_granted
FROM 
    accounts a
    JOIN client_entities ce ON a.client_entity_id = ce.client_entity_id
    JOIN client_groups cg ON ce.client_group_id = cg.client_group_id
    JOIN users u ON u.client_entity_id = ce.client_entity_id OR EXISTS (
        -- Include users from other entities who have explicit account access
        SELECT 1 FROM effective_user_permissions 
        WHERE user_id = u.user_id 
        AND scope_type = 'ACCOUNT' 
        AND scope_id = a.account_id
    )
    JOIN effective_user_permissions eup ON eup.user_id = u.user_id
    JOIN permissions p ON eup.permission_id = p.permission_id
WHERE
    (
        -- Global permissions
        eup.scope_type = 'GLOBAL'
        -- Account-specific permissions
        OR (eup.scope_type = 'ACCOUNT' AND eup.scope_id = a.account_id)
    )
    AND a.status = 'ACTIVE'
    AND u.status = 'ACTIVE'
    AND ce.status = 'ACTIVE'
    AND cg.status = 'ACTIVE';

-- 4. Approval Workflow Details View
-- Shows complete approval workflow information with related entities
CREATE OR REPLACE VIEW approval_workflow_details_view AS
SELECT 
    aw.workflow_id,
    aw.description AS workflow_description,
    aw.min_approvers,
    aw.threshold_amount,
    aw.currency,
    ce.client_entity_id,
    ce.name AS client_entity_name,
    p.product_id,
    p.name AS product_name,
    s.service_id,
    s.name AS service_name,
    ag.approval_group_id,
    ag.name AS approval_group_name,
    wag.approval_level,
    u.user_id,
    u.username,
    u.first_name,
    u.last_name,
    al.max_amount AS user_approval_limit
FROM 
    approval_workflows aw
    JOIN client_entities ce ON aw.client_entity_id = ce.client_entity_id
    LEFT JOIN products p ON aw.product_id = p.product_id
    LEFT JOIN services s ON aw.service_id = s.service_id
    JOIN workflow_approval_groups wag ON wag.workflow_id = aw.workflow_id
    JOIN approval_groups ag ON wag.approval_group_id = ag.approval_group_id
    JOIN approval_group_members agm ON agm.approval_group_id = ag.approval_group_id
    JOIN users u ON agm.user_id = u.user_id
    LEFT JOIN approval_limits al ON al.user_id = u.user_id 
        AND (al.product_id = p.product_id OR al.product_id IS NULL)
        AND (al.service_id = s.service_id OR al.service_id IS NULL)
WHERE
    ce.status = 'ACTIVE'
    AND (p.status = 'ACTIVE' OR p.status IS NULL)
    AND (s.status = 'ACTIVE' OR s.status IS NULL)
    AND ag.status = 'ACTIVE'
    AND u.status = 'ACTIVE';

-- 5. Product Service Hierarchy View
-- Shows the complete product hierarchy with categories, products, and services
CREATE OR REPLACE VIEW product_service_hierarchy_view AS
SELECT 
    pc.product_category_id,
    pc.name AS category_name,
    pc.description AS category_description,
    p.product_id,
    p.name AS product_name,
    p.description AS product_description,
    s.service_id,
    s.name AS service_name,
    s.description AS service_description
FROM 
    product_categories pc
    LEFT JOIN products p ON p.product_category_id = pc.product_category_id
    LEFT JOIN services s ON s.product_id = p.product_id
WHERE
    pc.status = 'ACTIVE'
    AND (p.status = 'ACTIVE' OR p.status IS NULL)
    AND (s.status = 'ACTIVE' OR s.status IS NULL);

-- 6. User Approval Limits View
-- Shows approval limits for users with product and service details
CREATE OR REPLACE VIEW user_approval_limits_view AS
SELECT 
    u.user_id,
    u.username,
    u.first_name,
    u.last_name,
    ce.client_entity_id,
    ce.name AS client_entity_name,
    p.product_id,
    p.name AS product_name,
    s.service_id,
    s.name AS service_name,
    a.account_id,
    a.account_name,
    a.account_number,
    al.currency,
    al.min_amount,
    al.max_amount
FROM 
    approval_limits al
    JOIN users u ON al.user_id = u.user_id
    JOIN client_entities ce ON u.client_entity_id = ce.client_entity_id
    LEFT JOIN products p ON al.product_id = p.product_id
    LEFT JOIN services s ON al.service_id = s.service_id
    LEFT JOIN accounts a ON al.account_id = a.account_id
WHERE
    u.status = 'ACTIVE'
    AND ce.status = 'ACTIVE'
    AND (p.status = 'ACTIVE' OR p.status IS NULL)
    AND (s.status = 'ACTIVE' OR s.status IS NULL)
    AND (a.status = 'ACTIVE' OR a.status IS NULL);

-- 7. Active Delegations View
-- Shows currently active permission delegations
CREATE OR REPLACE VIEW active_delegations_view AS
SELECT 
    d.delegation_id,
    d.start_date,
    d.end_date,
    d.reason,
    d.status AS delegation_status,
    u_delegator.user_id AS delegator_user_id,
    u_delegator.username AS delegator_username,
    u_delegator.first_name AS delegator_first_name,
    u_delegator.last_name AS delegator_last_name,
    ce_delegator.client_entity_id AS delegator_client_entity_id,
    ce_delegator.name AS delegator_client_entity_name,
    u_delegate.user_id AS delegate_user_id,
    u_delegate.username AS delegate_username,
    u_delegate.first_name AS delegate_first_name,
    u_delegate.last_name AS delegate_last_name,
    ce_delegate.client_entity_id AS delegate_client_entity_id,
    ce_delegate.name AS delegate_client_entity_name,
    -- Check if delegation is currently active
    CASE 
        WHEN d.start_date <= CURRENT_TIMESTAMP 
        AND d.end_date >= CURRENT_TIMESTAMP 
        AND d.status = 'APPROVED' 
        THEN TRUE 
        ELSE FALSE 
    END AS is_active
FROM 
    delegations d
    JOIN users u_delegator ON d.delegator_user_id = u_delegator.user_id
    JOIN client_entities ce_delegator ON u_delegator.client_entity_id = ce_delegator.client_entity_id
    JOIN users u_delegate ON d.delegate_user_id = u_delegate.user_id
    JOIN client_entities ce_delegate ON u_delegate.client_entity_id = ce_delegate.client_entity_id
WHERE
    u_delegator.status = 'ACTIVE'
    AND u_delegate.status = 'ACTIVE'
    AND ce_delegator.status = 'ACTIVE'
    AND ce_delegate.status = 'ACTIVE';

-- 8. User Group Membership View
-- Shows user group memberships with details
CREATE OR REPLACE VIEW user_group_membership_view AS
SELECT 
    u.user_id,
    u.username,
    u.first_name,
    u.last_name,
    ug.user_group_id,
    ug.name AS user_group_name,
    ug.description AS user_group_description,
    ce.client_entity_id,
    ce.name AS client_entity_name,
    cg.client_group_id,
    cg.name AS client_group_name,
    b.bank_id,
    b.name AS bank_name
FROM 
    users u
    JOIN user_group_members ugm ON u.user_id = ugm.user_id
    JOIN user_groups ug ON ugm.user_group_id = ug.user_group_id
    JOIN client_entities ce ON u.client_entity_id = ce.client_entity_id
    JOIN client_groups cg ON ce.client_group_id = cg.client_group_id
    JOIN banks b ON cg.bank_id = b.bank_id
WHERE
    u.status = 'ACTIVE'
    AND ug.status = 'ACTIVE'
    AND ce.status = 'ACTIVE'
    AND cg.status = 'ACTIVE'
    AND b.status = 'ACTIVE';

-- 9. Permission Source View
-- Shows the source of each permission for users
CREATE OR REPLACE VIEW permission_source_view AS
WITH permission_hierarchy AS (
    -- Bank level permissions
    SELECT 
        e.permission_id,
        u.user_id,
        'BANK' AS source_type,
        b.bank_id AS source_id,
        b.name AS source_name,
        e.scope_type,
        e.scope_id,
        e.is_denied
    FROM 
        entitlements e
        JOIN banks b ON e.entity_type = 'BANK' AND e.entity_id = b.bank_id
        JOIN client_groups cg ON cg.bank_id = b.bank_id
        JOIN client_entities ce ON ce.client_group_id = cg.client_group_id
        JOIN users u ON u.client_entity_id = ce.client_entity_id
    
    UNION ALL
    
    -- Region level permissions
    SELECT 
        e.permission_id,
        u.user_id,
        'REGION' AS source_type,
        r.region_id AS source_id,
        r.name AS source_name,
        e.scope_type,
        e.scope_id,
        e.is_denied
    FROM 
        entitlements e
        JOIN regions r ON e.entity_type = 'REGION' AND e.entity_id = r.region_id
        JOIN client_entities ce ON ce.region_id = r.region_id
        JOIN users u ON u.client_entity_id = ce.client_entity_id
    
    UNION ALL
    
    -- Client Group level permissions
    SELECT 
        e.permission_id,
        u.user_id,
        'CLIENT_GROUP' AS source_type,
        cg.client_group_id AS source_id,
        cg.name AS source_name,
        e.scope_type,
        e.scope_id,
        e.is_denied
    FROM 
        entitlements e
        JOIN client_groups cg ON e.entity_type = 'CLIENT_GROUP' AND e.entity_id = cg.client_group_id
        JOIN client_entities ce ON ce.client_group_id = cg.client_group_id
        JOIN users u ON u.client_entity_id = ce.client_entity_id
    
    UNION ALL
    
    -- Client Entity level permissions
    SELECT 
        e.permission_id,
        u.user_id,
        'CLIENT_ENTITY' AS source_type,
        ce.client_entity_id AS source_id,
        ce.name AS source_name,
        e.scope_type,
        e.scope_id,
        e.is_denied
    FROM 
        entitlements e
        JOIN client_entities ce ON e.entity_type = 'CLIENT_ENTITY' AND e.entity_id = ce.client_entity_id
        JOIN users u ON u.client_entity_id = ce.client_entity_id
    
    UNION ALL
    
    -- User Group level permissions
    SELECT 
        e.permission_id,
        ugm.user_id,
        'USER_GROUP' AS source_type,
        ug.user_group_id AS source_id,
        ug.name AS source_name,
        e.scope_type,
        e.scope_id,
        e.is_denied
    FROM 
        entitlements e
        JOIN user_groups ug ON e.entity_type = 'USER_GROUP' AND e.entity_id = ug.user_group_id
        JOIN user_group_members ugm ON ugm.user_group_id = ug.user_group_id
    
    UNION ALL
    
    -- User level permissions
    SELECT 
        e.permission_id,
        u.user_id,
        'USER' AS source_type,
        u.user_id AS source_id,
        CONCAT(u.first_name, ' ', u.last_name) AS source_name,
        e.scope_type,
        e.scope_id,
        e.is_denied
    FROM 
        entitlements e
        JOIN users u ON e.entity_type = 'USER' AND e.entity_id = u.user_id
)
SELECT 
    ph.user_id,
    u.username,
    u.first_name,
    u.last_name,
    p.permission_id,
    p.code AS permission_code,
    p.name AS permission_name,
    ph.source_type,
    ph.source_id,
    ph.source_name,
    ph.scope_type,
    CASE 
        WHEN ph.scope_type = 'GLOBAL' THEN 'Global'
        WHEN ph.scope_type = 'PRODUCT_CATEGORY' THEN pc.name
        WHEN ph.scope_type = 'PRODUCT' THEN pr.name
        WHEN ph.scope_type = 'SERVICE' THEN s.name
        WHEN ph.scope_type = 'ACCOUNT' THEN a.account_name
        ELSE 'Unknown'
    END AS scope_name,
    ph.scope_id,
    ph.is_denied
FROM 
    permission_hierarchy ph
    JOIN users u ON ph.user_id = u.user_id
    JOIN permissions p ON ph.permission_id = p.permission_id
    LEFT JOIN product_categories pc ON ph.scope_type = 'PRODUCT_CATEGORY' AND ph.scope_id = pc.product_category_id
    LEFT JOIN products pr ON ph.scope_type = 'PRODUCT' AND ph.scope_id = pr.product_id
    LEFT JOIN services s ON ph.scope_type = 'SERVICE' AND ph.scope_id = s.service_id
    LEFT JOIN accounts a ON ph.scope_type = 'ACCOUNT' AND ph.scope_id = a.account_id
WHERE
    u.status = 'ACTIVE';
