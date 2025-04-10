-- Utility Functions for Cash Management Entitlement System

-- 1. Get User Hierarchy Path
-- Returns the complete hierarchy path for a user
CREATE OR REPLACE FUNCTION get_user_hierarchy_path(p_user_id UUID)
RETURNS TABLE (
    level_name VARCHAR,
    entity_id UUID,
    entity_name VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH user_hierarchy AS (
        SELECT 
            u.user_id,
            u.username,
            u.first_name,
            u.last_name,
            ce.client_entity_id,
            ce.name AS client_entity_name,
            cg.client_group_id,
            cg.name AS client_group_name,
            r.region_id,
            r.name AS region_name,
            b.bank_id,
            b.name AS bank_name
        FROM 
            users u
            JOIN client_entities ce ON u.client_entity_id = ce.client_entity_id
            JOIN client_groups cg ON ce.client_group_id = cg.client_group_id
            LEFT JOIN regions r ON ce.region_id = r.region_id
            JOIN banks b ON cg.bank_id = b.bank_id
        WHERE 
            u.user_id = p_user_id
    )
    SELECT 'Bank', bank_id, bank_name FROM user_hierarchy
    UNION ALL
    SELECT 'Region', region_id, region_name FROM user_hierarchy WHERE region_id IS NOT NULL
    UNION ALL
    SELECT 'Client Group', client_group_id, client_group_name FROM user_hierarchy
    UNION ALL
    SELECT 'Client Entity', client_entity_id, client_entity_name FROM user_hierarchy
    UNION ALL
    SELECT 'User', user_id, username || ' (' || first_name || ' ' || last_name || ')' FROM user_hierarchy
    ORDER BY level_name;
END;
$$;

-- 2. Get Approval Requirements
-- Determines approval requirements for a transaction
CREATE OR REPLACE FUNCTION get_approval_requirements(
    p_client_entity_id UUID,
    p_product_id UUID,
    p_service_id UUID,
    p_amount DECIMAL(20, 2),
    p_currency CHAR(3)
) RETURNS TABLE (
    workflow_id UUID,
    workflow_description TEXT,
    min_approvers INTEGER,
    threshold_amount DECIMAL(20, 2),
    approval_group_id UUID,
    approval_group_name VARCHAR,
    approval_level INTEGER
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        aw.workflow_id,
        aw.description AS workflow_description,
        aw.min_approvers,
        aw.threshold_amount,
        ag.approval_group_id,
        ag.name AS approval_group_name,
        wag.approval_level
    FROM 
        approval_workflows aw
        JOIN workflow_approval_groups wag ON wag.workflow_id = aw.workflow_id
        JOIN approval_groups ag ON wag.approval_group_id = ag.approval_group_id
    WHERE 
        aw.client_entity_id = p_client_entity_id
        AND (aw.product_id = p_product_id OR aw.product_id IS NULL)
        AND (aw.service_id = p_service_id OR aw.service_id IS NULL)
        AND aw.currency = p_currency
        AND (aw.threshold_amount IS NULL OR p_amount >= aw.threshold_amount)
    ORDER BY 
        -- More specific workflows first (with product and service)
        CASE WHEN aw.product_id IS NOT NULL AND aw.service_id IS NOT NULL THEN 1
             WHEN aw.product_id IS NOT NULL AND aw.service_id IS NULL THEN 2
             WHEN aw.product_id IS NULL AND aw.service_id IS NULL THEN 3
             ELSE 4
        END,
        -- Higher threshold amounts first
        aw.threshold_amount DESC NULLS LAST,
        -- Higher approval levels first
        wag.approval_level;
END;
$$;

-- 3. Check Account Access
-- Checks if a user has specific access to an account
CREATE OR REPLACE FUNCTION check_account_access(
    p_user_id UUID,
    p_account_id UUID,
    p_permission_code VARCHAR
) RETURNS BOOLEAN LANGUAGE plpgsql AS $$
DECLARE
    v_has_access BOOLEAN;
BEGIN
    SELECT 
        EXISTS (
            SELECT 1
            FROM effective_user_permissions eup
            WHERE eup.user_id = p_user_id
              AND eup.permission_code = p_permission_code
              AND eup.is_granted = TRUE
              AND (
                  -- Global permission
                  (eup.scope_type = 'GLOBAL')
                  -- Account-specific permission
                  OR (eup.scope_type = 'ACCOUNT' AND eup.scope_id = p_account_id)
              )
        ) INTO v_has_access;
    
    RETURN v_has_access;
END;
$$;

-- 4. Get Delegated Permissions
-- Gets permissions delegated to a user
CREATE OR REPLACE FUNCTION get_delegated_permissions(p_user_id UUID)
RETURNS TABLE (
    delegation_id UUID,
    delegator_user_id UUID,
    delegator_username VARCHAR,
    delegator_name VARCHAR,
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    permission_id UUID,
    permission_code VARCHAR,
    permission_name VARCHAR,
    scope_type scope_type,
    scope_id UUID,
    scope_name VARCHAR,
    is_granted BOOLEAN
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.delegation_id,
        d.delegator_user_id,
        u_delegator.username AS delegator_username,
        u_delegator.first_name || ' ' || u_delegator.last_name AS delegator_name,
        d.start_date,
        d.end_date,
        eup.permission_id,
        eup.permission_code,
        eup.permission_name,
        eup.scope_type,
        eup.scope_id,
        CASE 
            WHEN eup.scope_type = 'GLOBAL' THEN 'Global'
            WHEN eup.scope_type = 'PRODUCT_CATEGORY' THEN pc.name
            WHEN eup.scope_type = 'PRODUCT' THEN pr.name
            WHEN eup.scope_type = 'SERVICE' THEN s.name
            WHEN eup.scope_type = 'ACCOUNT' THEN a.account_name
            ELSE 'Unknown'
        END AS scope_name,
        eup.is_granted
    FROM 
        delegations d
        JOIN users u_delegator ON d.delegator_user_id = u_delegator.user_id
        JOIN effective_user_permissions eup ON eup.user_id = d.delegator_user_id
        LEFT JOIN product_categories pc ON eup.scope_type = 'PRODUCT_CATEGORY' AND eup.scope_id = pc.product_category_id
        LEFT JOIN products pr ON eup.scope_type = 'PRODUCT' AND eup.scope_id = pr.product_id
        LEFT JOIN services s ON eup.scope_type = 'SERVICE' AND eup.scope_id = s.service_id
        LEFT JOIN accounts a ON eup.scope_type = 'ACCOUNT' AND eup.scope_id = a.account_id
    WHERE 
        d.delegate_user_id = p_user_id
        AND d.status = 'APPROVED'
        AND d.start_date <= CURRENT_TIMESTAMP
        AND d.end_date >= CURRENT_TIMESTAMP
        AND eup.is_granted = TRUE;
END;
$$;

-- 5. Calculate Effective Approval Limit
-- Calculates the effective approval limit for a user
CREATE OR REPLACE FUNCTION calculate_effective_approval_limit(
    p_user_id UUID,
    p_product_id UUID,
    p_service_id UUID,
    p_account_id UUID,
    p_currency CHAR(3)
) RETURNS DECIMAL(20, 2) LANGUAGE plpgsql AS $$
DECLARE
    v_max_amount DECIMAL(20, 2);
BEGIN
    -- Get the highest applicable limit
    SELECT 
        MAX(al.max_amount) INTO v_max_amount
    FROM 
        approval_limits al
    WHERE 
        al.user_id = p_user_id
        AND al.currency = p_currency
        AND (
            -- Most specific match: product, service, and account
            (al.product_id = p_product_id AND al.service_id = p_service_id AND al.account_id = p_account_id)
            -- Product and service match
            OR (al.product_id = p_product_id AND al.service_id = p_service_id AND al.account_id IS NULL)
            -- Product match only
            OR (al.product_id = p_product_id AND al.service_id IS NULL AND al.account_id IS NULL)
            -- Account match only
            OR (al.product_id IS NULL AND al.service_id IS NULL AND al.account_id = p_account_id)
            -- Global limit
            OR (al.product_id IS NULL AND al.service_id IS NULL AND al.account_id IS NULL)
        );
    
    -- Check for delegated limits
    WITH delegated_limits AS (
        SELECT 
            al.max_amount
        FROM 
            delegations d
            JOIN approval_limits al ON al.user_id = d.delegator_user_id
        WHERE 
            d.delegate_user_id = p_user_id
            AND d.status = 'APPROVED'
            AND d.start_date <= CURRENT_TIMESTAMP
            AND d.end_date >= CURRENT_TIMESTAMP
            AND al.currency = p_currency
            AND (
                -- Most specific match: product, service, and account
                (al.product_id = p_product_id AND al.service_id = p_service_id AND al.account_id = p_account_id)
                -- Product and service match
                OR (al.product_id = p_product_id AND al.service_id = p_service_id AND al.account_id IS NULL)
                -- Product match only
                OR (al.product_id = p_product_id AND al.service_id IS NULL AND al.account_id IS NULL)
                -- Account match only
                OR (al.product_id IS NULL AND al.service_id IS NULL AND al.account_id = p_account_id)
                -- Global limit
                OR (al.product_id IS NULL AND al.service_id IS NULL AND al.account_id IS NULL)
            )
    )
    SELECT 
        GREATEST(COALESCE(v_max_amount, 0), COALESCE(MAX(max_amount), 0)) INTO v_max_amount
    FROM 
        delegated_limits;
    
    RETURN COALESCE(v_max_amount, 0);
END;
$$;

-- 6. Is In Approval Group
-- Checks if a user is in a specific approval group
CREATE OR REPLACE FUNCTION is_in_approval_group(
    p_user_id UUID,
    p_approval_group_id UUID
) RETURNS BOOLEAN LANGUAGE plpgsql AS $$
DECLARE
    v_is_member BOOLEAN;
BEGIN
    SELECT 
        EXISTS (
            SELECT 1
            FROM approval_group_members agm
            WHERE agm.user_id = p_user_id
              AND agm.approval_group_id = p_approval_group_id
        ) INTO v_is_member;
    
    -- Check for delegations if not a direct member
    IF NOT v_is_member THEN
        SELECT 
            EXISTS (
                SELECT 1
                FROM delegations d
                JOIN approval_group_members agm ON agm.user_id = d.delegator_user_id
                WHERE d.delegate_user_id = p_user_id
                  AND d.status = 'APPROVED'
                  AND d.start_date <= CURRENT_TIMESTAMP
                  AND d.end_date >= CURRENT_TIMESTAMP
                  AND agm.approval_group_id = p_approval_group_id
            ) INTO v_is_member;
    END IF;
    
    RETURN v_is_member;
END;
$$;

-- 7. Get Permission Source
-- Identifies the source of a user's permission
CREATE OR REPLACE FUNCTION get_permission_source(
    p_user_id UUID,
    p_permission_code VARCHAR,
    p_scope_type scope_type DEFAULT 'GLOBAL',
    p_scope_id UUID DEFAULT NULL
) RETURNS TABLE (
    source_type VARCHAR,
    source_id UUID,
    source_name VARCHAR,
    is_denied BOOLEAN,
    is_delegated BOOLEAN,
    delegator_user_id UUID,
    delegator_name VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    -- Check direct permissions
    RETURN QUERY
    SELECT 
        psv.source_type,
        psv.source_id,
        psv.source_name,
        psv.is_denied,
        FALSE AS is_delegated,
        NULL::UUID AS delegator_user_id,
        NULL::VARCHAR AS delegator_name
    FROM 
        permission_source_view psv
    WHERE 
        psv.user_id = p_user_id
        AND psv.permission_code = p_permission_code
        AND psv.scope_type = p_scope_type
        AND (p_scope_id IS NULL OR psv.scope_id = p_scope_id);
    
    -- Check delegated permissions if no direct permissions found
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT 
            'DELEGATION' AS source_type,
            d.delegation_id AS source_id,
            'Delegated from ' || u_delegator.first_name || ' ' || u_delegator.last_name AS source_name,
            FALSE AS is_denied,
            TRUE AS is_delegated,
            d.delegator_user_id,
            u_delegator.first_name || ' ' || u_delegator.last_name AS delegator_name
        FROM 
            delegations d
            JOIN users u_delegator ON d.delegator_user_id = u_delegator.user_id
            JOIN permission_source_view psv ON psv.user_id = d.delegator_user_id
        WHERE 
            d.delegate_user_id = p_user_id
            AND d.status = 'APPROVED'
            AND d.start_date <= CURRENT_TIMESTAMP
            AND d.end_date >= CURRENT_TIMESTAMP
            AND psv.permission_code = p_permission_code
            AND psv.scope_type = p_scope_type
            AND (p_scope_id IS NULL OR psv.scope_id = p_scope_id)
            AND NOT psv.is_denied;
    END IF;
END;
$$;

-- 8. Can Approve Transaction
-- Determines if a user can approve a specific transaction
CREATE OR REPLACE FUNCTION can_approve_transaction(
    p_user_id UUID,
    p_client_entity_id UUID,
    p_product_id UUID,
    p_service_id UUID,
    p_amount DECIMAL(20, 2),
    p_currency CHAR(3)
) RETURNS BOOLEAN LANGUAGE plpgsql AS $$
DECLARE
    v_can_approve BOOLEAN := FALSE;
    v_approval_limit DECIMAL(20, 2);
    v_has_permission BOOLEAN;
BEGIN
    -- Check if user has approval permission
    SELECT has_permission(p_user_id, 'APPROVE_PAYMENT', 'PRODUCT', p_product_id) INTO v_has_permission;
    
    IF NOT v_has_permission THEN
        RETURN FALSE;
    END IF;
    
    -- Check approval limit
    SELECT calculate_effective_approval_limit(
        p_user_id, p_product_id, p_service_id, NULL, p_currency
    ) INTO v_approval_limit;
    
    IF v_approval_limit >= p_amount THEN
        v_can_approve := TRUE;
    END IF;
    
    -- Check if user is in appropriate approval group
    IF NOT v_can_approve THEN
        SELECT 
            EXISTS (
                SELECT 1
                FROM approval_workflows aw
                JOIN workflow_approval_groups wag ON wag.workflow_id = aw.workflow_id
                WHERE aw.client_entity_id = p_client_entity_id
                  AND (aw.product_id = p_product_id OR aw.product_id IS NULL)
                  AND (aw.service_id = p_service_id OR aw.service_id IS NULL)
                  AND aw.currency = p_currency
                  AND (aw.threshold_amount IS NULL OR p_amount >= aw.threshold_amount)
                  AND is_in_approval_group(p_user_id, wag.approval_group_id)
            ) INTO v_can_approve;
    END IF;
    
    RETURN v_can_approve;
END;
$$;
