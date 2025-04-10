-- Example usage of the comprehensive user query with John Smith's user ID
-- Replace the parameter with the actual user ID when using

-- For PostgreSQL, you would use this syntax:
SELECT * FROM (
    -- Comprehensive User Information Query
    WITH user_info AS (
        -- Basic user information and organizational hierarchy
        SELECT 
            u.user_id,
            u.username,
            u.first_name,
            u.last_name,
            u.email,
            u.status AS user_status,
            ce.client_entity_id,
            ce.name AS client_entity_name,
            ce.location AS client_entity_location,
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
            u.user_id = '66666666-6666-6666-6666-666666666661' -- John Smith's user ID
    ),
    user_groups AS (
        -- User group memberships
        SELECT 
            ug.user_group_id,
            ug.name AS user_group_name,
            ug.description AS user_group_description
        FROM 
            user_group_members ugm
            JOIN user_groups ug ON ugm.user_group_id = ug.user_group_id
        WHERE 
            ugm.user_id = '66666666-6666-6666-6666-666666666661'
    ),
    user_entitlements AS (
        -- User entitlements with scope information
        SELECT 
            p.permission_id,
            p.code AS permission_code,
            p.name AS permission_name,
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
            eup.is_granted,
            psv.source_type,
            psv.source_name AS permission_source
        FROM 
            effective_user_permissions eup
            JOIN permissions p ON eup.permission_id = p.permission_id
            LEFT JOIN product_categories pc ON eup.scope_type = 'PRODUCT_CATEGORY' AND eup.scope_id = pc.product_category_id
            LEFT JOIN products pr ON eup.scope_type = 'PRODUCT' AND eup.scope_id = pr.product_id
            LEFT JOIN services s ON eup.scope_type = 'SERVICE' AND eup.scope_id = s.service_id
            LEFT JOIN accounts a ON eup.scope_type = 'ACCOUNT' AND eup.scope_id = a.account_id
            LEFT JOIN permission_source_view psv ON psv.user_id = eup.user_id 
                                               AND psv.permission_id = eup.permission_id 
                                               AND psv.scope_type = eup.scope_type 
                                               AND COALESCE(psv.scope_id, '00000000-0000-0000-0000-000000000000') = COALESCE(eup.scope_id, '00000000-0000-0000-0000-000000000000')
        WHERE 
            eup.user_id = '66666666-6666-6666-6666-666666666661'
    ),
    user_products AS (
        -- Products the user has access to
        SELECT DISTINCT
            pr.product_id,
            pr.name AS product_name,
            pr.description AS product_description,
            pc.product_category_id,
            pc.name AS product_category_name
        FROM 
            user_entitlements ue
            JOIN products pr ON ue.scope_type = 'PRODUCT' AND ue.scope_id = pr.product_id
            JOIN product_categories pc ON pr.product_category_id = pc.product_category_id
        WHERE 
            ue.is_granted = TRUE
        
        UNION
        
        SELECT DISTINCT
            pr.product_id,
            pr.name AS product_name,
            pr.description AS product_description,
            pc.product_category_id,
            pc.name AS product_category_name
        FROM 
            user_entitlements ue
            JOIN services s ON ue.scope_type = 'SERVICE' AND ue.scope_id = s.service_id
            JOIN products pr ON s.product_id = pr.product_id
            JOIN product_categories pc ON pr.product_category_id = pc.product_category_id
        WHERE 
            ue.is_granted = TRUE
    ),
    user_services AS (
        -- Services the user has access to
        SELECT DISTINCT
            s.service_id,
            s.name AS service_name,
            s.description AS service_description,
            pr.product_id,
            pr.name AS product_name
        FROM 
            user_entitlements ue
            JOIN services s ON ue.scope_type = 'SERVICE' AND ue.scope_id = s.service_id
            JOIN products pr ON s.product_id = pr.product_id
        WHERE 
            ue.is_granted = TRUE
    ),
    user_accounts AS (
        -- Accounts the user has access to
        SELECT DISTINCT
            a.account_id,
            a.account_number,
            a.account_name,
            a.currency,
            a.account_type,
            ce.name AS client_entity_name,
            STRING_AGG(p.name, ', ') AS permissions
        FROM 
            user_entitlements ue
            JOIN accounts a ON ue.scope_type = 'ACCOUNT' AND ue.scope_id = a.account_id
            JOIN client_entities ce ON a.client_entity_id = ce.client_entity_id
            JOIN permissions p ON ue.permission_id = p.permission_id
        WHERE 
            ue.is_granted = TRUE
        GROUP BY
            a.account_id, a.account_number, a.account_name, a.currency, a.account_type, ce.name
        
        UNION
        
        SELECT DISTINCT
            a.account_id,
            a.account_number,
            a.account_name,
            a.currency,
            a.account_type,
            ce.name AS client_entity_name,
            'Global or inherited permissions' AS permissions
        FROM 
            accounts a
            JOIN client_entities ce ON a.client_entity_id = ce.client_entity_id
            JOIN user_info ui ON (
                -- User's own client entity accounts
                (a.client_entity_id = ui.client_entity_id) OR
                -- Accounts from other entities where user has global permissions
                EXISTS (
                    SELECT 1 FROM user_entitlements ue
                    WHERE ue.scope_type = 'GLOBAL'
                    AND ue.is_granted = TRUE
                    AND ue.permission_code IN ('VIEW_ACCOUNT', 'VIEW_BALANCE', 'VIEW_TRANSACTIONS')
                )
            )
        WHERE 
            NOT EXISTS (
                SELECT 1 FROM user_entitlements ue
                WHERE ue.scope_type = 'ACCOUNT' 
                AND ue.scope_id = a.account_id
            )
    ),
    user_approval_limits AS (
        -- User's approval limits
        SELECT 
            al.limit_id,
            al.product_id,
            p.name AS product_name,
            al.service_id,
            s.name AS service_name,
            al.account_id,
            a.account_name,
            al.currency,
            al.min_amount,
            al.max_amount
        FROM 
            approval_limits al
            LEFT JOIN products p ON al.product_id = p.product_id
            LEFT JOIN services s ON al.service_id = s.service_id
            LEFT JOIN accounts a ON al.account_id = a.account_id
        WHERE 
            al.user_id = '66666666-6666-6666-6666-666666666661'
    ),
    user_approval_groups AS (
        -- User's approval group memberships
        SELECT 
            ag.approval_group_id,
            ag.name AS approval_group_name,
            ag.description AS approval_group_description,
            ce.name AS client_entity_name
        FROM 
            approval_group_members agm
            JOIN approval_groups ag ON agm.approval_group_id = ag.approval_group_id
            JOIN client_entities ce ON ag.client_entity_id = ce.client_entity_id
        WHERE 
            agm.user_id = '66666666-6666-6666-6666-666666666661'
    ),
    user_approval_workflows AS (
        -- Approval workflows the user is part of
        SELECT 
            aw.workflow_id,
            aw.description AS workflow_description,
            aw.min_approvers,
            aw.threshold_amount,
            aw.currency,
            p.name AS product_name,
            s.name AS service_name,
            ce.name AS client_entity_name,
            ag.name AS approval_group_name,
            wag.approval_level
        FROM 
            approval_workflows aw
            JOIN workflow_approval_groups wag ON wag.workflow_id = aw.workflow_id
            JOIN approval_groups ag ON wag.approval_group_id = ag.approval_group_id
            JOIN approval_group_members agm ON agm.approval_group_id = ag.approval_group_id
            JOIN client_entities ce ON aw.client_entity_id = ce.client_entity_id
            LEFT JOIN products p ON aw.product_id = p.product_id
            LEFT JOIN services s ON aw.service_id = s.service_id
        WHERE 
            agm.user_id = '66666666-6666-6666-6666-666666666661'
    ),
    user_delegations_from AS (
        -- Delegations from this user to others
        SELECT 
            d.delegation_id,
            u.username AS delegate_username,
            u.first_name || ' ' || u.last_name AS delegate_name,
            d.start_date,
            d.end_date,
            d.reason,
            d.status,
            CASE 
                WHEN d.start_date <= CURRENT_TIMESTAMP AND d.end_date >= CURRENT_TIMESTAMP AND d.status = 'APPROVED' 
                THEN TRUE 
                ELSE FALSE 
            END AS is_active
        FROM 
            delegations d
            JOIN users u ON d.delegate_user_id = u.user_id
        WHERE 
            d.delegator_user_id = '66666666-6666-6666-6666-666666666661'
    ),
    user_delegations_to AS (
        -- Delegations to this user from others
        SELECT 
            d.delegation_id,
            u.username AS delegator_username,
            u.first_name || ' ' || u.last_name AS delegator_name,
            d.start_date,
            d.end_date,
            d.reason,
            d.status,
            CASE 
                WHEN d.start_date <= CURRENT_TIMESTAMP AND d.end_date >= CURRENT_TIMESTAMP AND d.status = 'APPROVED' 
                THEN TRUE 
                ELSE FALSE 
            END AS is_active
        FROM 
            delegations d
            JOIN users u ON d.delegator_user_id = u.user_id
        WHERE 
            d.delegate_user_id = '66666666-6666-6666-6666-666666666661'
    )

    -- Final result combining all information
    SELECT 
        json_build_object(
            'user_info', (SELECT row_to_json(ui) FROM user_info ui),
            'user_groups', (SELECT json_agg(ug) FROM user_groups ug),
            'entitlements', (SELECT json_agg(ue) FROM user_entitlements ue),
            'products', (SELECT json_agg(up) FROM user_products up),
            'services', (SELECT json_agg(us) FROM user_services us),
            'accounts', (SELECT json_agg(ua) FROM user_accounts ua),
            'approval_limits', (SELECT json_agg(ual) FROM user_approval_limits ual),
            'approval_groups', (SELECT json_agg(uag) FROM user_approval_groups uag),
            'approval_workflows', (SELECT json_agg(uaw) FROM user_approval_workflows uaw),
            'delegations_from', (SELECT json_agg(udf) FROM user_delegations_from udf),
            'delegations_to', (SELECT json_agg(udt) FROM user_delegations_to udt)
        ) AS user_comprehensive_info
) AS result;
