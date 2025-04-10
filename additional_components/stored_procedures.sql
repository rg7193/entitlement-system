-- Stored Procedures for Cash Management Entitlement System

-- 1. Create Client Hierarchy Procedure
-- Creates a complete client hierarchy (client group, entity, user groups, users)
CREATE OR REPLACE PROCEDURE create_client_hierarchy_proc(
    p_bank_id UUID,
    p_client_group_name VARCHAR,
    p_client_group_description TEXT,
    p_client_entity_name VARCHAR,
    p_client_entity_location VARCHAR,
    p_region_id UUID,
    OUT p_client_group_id UUID,
    OUT p_client_entity_id UUID
) LANGUAGE plpgsql AS $$
BEGIN
    -- Create client group
    INSERT INTO client_groups (
        client_group_id,
        bank_id,
        name,
        description,
        status
    ) VALUES (
        uuid_generate_v4(),
        p_bank_id,
        p_client_group_name,
        p_client_group_description,
        'ACTIVE'
    ) RETURNING client_group_id INTO p_client_group_id;
    
    -- Create client entity
    INSERT INTO client_entities (
        client_entity_id,
        client_group_id,
        region_id,
        name,
        location,
        status
    ) VALUES (
        uuid_generate_v4(),
        p_client_group_id,
        p_region_id,
        p_client_entity_name,
        p_client_entity_location,
        'ACTIVE'
    ) RETURNING client_entity_id INTO p_client_entity_id;
    
    -- Create default user groups
    INSERT INTO user_groups (
        user_group_id,
        client_entity_id,
        name,
        description,
        status
    ) VALUES
    (uuid_generate_v4(), p_client_entity_id, 'Finance Administrators', 'Users who manage financial operations', 'ACTIVE'),
    (uuid_generate_v4(), p_client_entity_id, 'Payment Initiators', 'Users who can initiate payments', 'ACTIVE'),
    (uuid_generate_v4(), p_client_entity_id, 'Payment Approvers', 'Users who can approve payments', 'ACTIVE'),
    (uuid_generate_v4(), p_client_entity_id, 'Account Viewers', 'Users who can only view account information', 'ACTIVE');
    
    -- Log the creation
    INSERT INTO audit_logs (
        user_id,
        action,
        entity_type,
        entity_id,
        details
    ) VALUES (
        NULL,
        'CREATE_CLIENT_HIERARCHY',
        'CLIENT_GROUP',
        p_client_group_id,
        jsonb_build_object(
            'client_group_name', p_client_group_name,
            'client_entity_name', p_client_entity_name,
            'client_entity_id', p_client_entity_id
        )
    );
END;
$$;

-- 2. Grant Permission Procedure
-- Grants a permission to an entity at a specific level
CREATE OR REPLACE PROCEDURE grant_permission_proc(
    p_entity_type entity_type,
    p_entity_id UUID,
    p_permission_code VARCHAR,
    p_scope_type scope_type,
    p_scope_id UUID,
    p_created_by UUID,
    p_start_date DATE DEFAULT NULL,
    p_end_date DATE DEFAULT NULL
) LANGUAGE plpgsql AS $$
DECLARE
    v_permission_id UUID;
    v_entitlement_id UUID;
BEGIN
    -- Get permission ID from code
    SELECT permission_id INTO v_permission_id
    FROM permissions
    WHERE code = p_permission_code;
    
    IF v_permission_id IS NULL THEN
        RAISE EXCEPTION 'Permission with code % not found', p_permission_code;
    END IF;
    
    -- Check if entity exists
    CASE p_entity_type
        WHEN 'BANK' THEN
            IF NOT EXISTS (SELECT 1 FROM banks WHERE bank_id = p_entity_id) THEN
                RAISE EXCEPTION 'Bank with ID % not found', p_entity_id;
            END IF;
        WHEN 'REGION' THEN
            IF NOT EXISTS (SELECT 1 FROM regions WHERE region_id = p_entity_id) THEN
                RAISE EXCEPTION 'Region with ID % not found', p_entity_id;
            END IF;
        WHEN 'CLIENT_GROUP' THEN
            IF NOT EXISTS (SELECT 1 FROM client_groups WHERE client_group_id = p_entity_id) THEN
                RAISE EXCEPTION 'Client group with ID % not found', p_entity_id;
            END IF;
        WHEN 'CLIENT_ENTITY' THEN
            IF NOT EXISTS (SELECT 1 FROM client_entities WHERE client_entity_id = p_entity_id) THEN
                RAISE EXCEPTION 'Client entity with ID % not found', p_entity_id;
            END IF;
        WHEN 'USER_GROUP' THEN
            IF NOT EXISTS (SELECT 1 FROM user_groups WHERE user_group_id = p_entity_id) THEN
                RAISE EXCEPTION 'User group with ID % not found', p_entity_id;
            END IF;
        WHEN 'USER' THEN
            IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = p_entity_id) THEN
                RAISE EXCEPTION 'User with ID % not found', p_entity_id;
            END IF;
        ELSE
            RAISE EXCEPTION 'Invalid entity type: %', p_entity_type;
    END CASE;
    
    -- Check if scope exists if not GLOBAL
    IF p_scope_type != 'GLOBAL' AND p_scope_id IS NOT NULL THEN
        CASE p_scope_type
            WHEN 'PRODUCT_CATEGORY' THEN
                IF NOT EXISTS (SELECT 1 FROM product_categories WHERE product_category_id = p_scope_id) THEN
                    RAISE EXCEPTION 'Product category with ID % not found', p_scope_id;
                END IF;
            WHEN 'PRODUCT' THEN
                IF NOT EXISTS (SELECT 1 FROM products WHERE product_id = p_scope_id) THEN
                    RAISE EXCEPTION 'Product with ID % not found', p_scope_id;
                END IF;
            WHEN 'SERVICE' THEN
                IF NOT EXISTS (SELECT 1 FROM services WHERE service_id = p_scope_id) THEN
                    RAISE EXCEPTION 'Service with ID % not found', p_scope_id;
                END IF;
            WHEN 'ACCOUNT' THEN
                IF NOT EXISTS (SELECT 1 FROM accounts WHERE account_id = p_scope_id) THEN
                    RAISE EXCEPTION 'Account with ID % not found', p_scope_id;
                END IF;
            ELSE
                RAISE EXCEPTION 'Invalid scope type: %', p_scope_type;
        END CASE;
    END IF;
    
    -- Check if entitlement already exists
    SELECT entitlement_id INTO v_entitlement_id
    FROM entitlements
    WHERE entity_type = p_entity_type
    AND entity_id = p_entity_id
    AND permission_id = v_permission_id
    AND scope_type = p_scope_type
    AND (
        (p_scope_id IS NULL AND scope_id IS NULL) OR
        (p_scope_id IS NOT NULL AND scope_id = p_scope_id)
    );
    
    -- Update existing entitlement or create new one
    IF v_entitlement_id IS NOT NULL THEN
        UPDATE entitlements
        SET is_denied = FALSE,
            start_date = p_start_date,
            end_date = p_end_date,
            updated_at = CURRENT_TIMESTAMP
        WHERE entitlement_id = v_entitlement_id;
    ELSE
        INSERT INTO entitlements (
            entity_type,
            entity_id,
            permission_id,
            scope_type,
            scope_id,
            is_denied,
            start_date,
            end_date,
            created_by
        ) VALUES (
            p_entity_type,
            p_entity_id,
            v_permission_id,
            p_scope_type,
            p_scope_id,
            FALSE,
            p_start_date,
            p_end_date,
            p_created_by
        ) RETURNING entitlement_id INTO v_entitlement_id;
    END IF;
    
    -- Log the permission grant
    INSERT INTO audit_logs (
        user_id,
        action,
        entity_type,
        entity_id,
        details
    ) VALUES (
        p_created_by,
        'PERMISSION_GRANT',
        p_entity_type::VARCHAR,
        p_entity_id,
        jsonb_build_object(
            'permission_code', p_permission_code,
            'scope_type', p_scope_type,
            'scope_id', p_scope_id,
            'entitlement_id', v_entitlement_id
        )
    );
END;
$$;

-- 3. Revoke Permission Procedure
-- Revokes a permission from an entity
CREATE OR REPLACE PROCEDURE revoke_permission_proc(
    p_entity_type entity_type,
    p_entity_id UUID,
    p_permission_code VARCHAR,
    p_scope_type scope_type,
    p_scope_id UUID,
    p_created_by UUID,
    p_is_denied BOOLEAN DEFAULT TRUE
) LANGUAGE plpgsql AS $$
DECLARE
    v_permission_id UUID;
    v_entitlement_id UUID;
BEGIN
    -- Get permission ID from code
    SELECT permission_id INTO v_permission_id
    FROM permissions
    WHERE code = p_permission_code;
    
    IF v_permission_id IS NULL THEN
        RAISE EXCEPTION 'Permission with code % not found', p_permission_code;
    END IF;
    
    -- Check if entitlement exists
    SELECT entitlement_id INTO v_entitlement_id
    FROM entitlements
    WHERE entity_type = p_entity_type
    AND entity_id = p_entity_id
    AND permission_id = v_permission_id
    AND scope_type = p_scope_type
    AND (
        (p_scope_id IS NULL AND scope_id IS NULL) OR
        (p_scope_id IS NOT NULL AND scope_id = p_scope_id)
    );
    
    IF v_entitlement_id IS NULL THEN
        -- If p_is_denied is TRUE, create a new entitlement with is_denied = TRUE
        IF p_is_denied THEN
            INSERT INTO entitlements (
                entity_type,
                entity_id,
                permission_id,
                scope_type,
                scope_id,
                is_denied,
                created_by
            ) VALUES (
                p_entity_type,
                p_entity_id,
                v_permission_id,
                p_scope_type,
                p_scope_id,
                TRUE,
                p_created_by
            ) RETURNING entitlement_id INTO v_entitlement_id;
        ELSE
            RAISE NOTICE 'No entitlement found to revoke';
            RETURN;
        END IF;
    ELSE
        -- If p_is_denied is TRUE, update to explicitly deny
        -- If p_is_denied is FALSE, delete the entitlement
        IF p_is_denied THEN
            UPDATE entitlements
            SET is_denied = TRUE,
                updated_at = CURRENT_TIMESTAMP
            WHERE entitlement_id = v_entitlement_id;
        ELSE
            DELETE FROM entitlements
            WHERE entitlement_id = v_entitlement_id;
        END IF;
    END IF;
    
    -- Log the permission revocation
    INSERT INTO audit_logs (
        user_id,
        action,
        entity_type,
        entity_id,
        details
    ) VALUES (
        p_created_by,
        CASE WHEN p_is_denied THEN 'PERMISSION_DENY' ELSE 'PERMISSION_REVOKE' END,
        p_entity_type::VARCHAR,
        p_entity_id,
        jsonb_build_object(
            'permission_code', p_permission_code,
            'scope_type', p_scope_type,
            'scope_id', p_scope_id,
            'is_denied', p_is_denied
        )
    );
END;
$$;

-- 4. Setup Approval Workflow Procedure
-- Sets up a complete approval workflow with approval groups
CREATE OR REPLACE PROCEDURE setup_approval_workflow_proc(
    p_client_entity_id UUID,
    p_product_id UUID,
    p_service_id UUID,
    p_min_approvers INTEGER,
    p_threshold_amount DECIMAL(20, 2),
    p_currency CHAR(3),
    p_description TEXT,
    p_approval_group_name VARCHAR,
    p_approver_user_ids UUID[],
    OUT p_workflow_id UUID,
    OUT p_approval_group_id UUID
) LANGUAGE plpgsql AS $$
DECLARE
    v_user_id UUID;
BEGIN
    -- Create approval workflow
    INSERT INTO approval_workflows (
        workflow_id,
        client_entity_id,
        product_id,
        service_id,
        min_approvers,
        threshold_amount,
        currency,
        description
    ) VALUES (
        uuid_generate_v4(),
        p_client_entity_id,
        p_product_id,
        p_service_id,
        p_min_approvers,
        p_threshold_amount,
        p_currency,
        p_description
    ) RETURNING workflow_id INTO p_workflow_id;
    
    -- Create approval group
    INSERT INTO approval_groups (
        approval_group_id,
        client_entity_id,
        name,
        description,
        status
    ) VALUES (
        uuid_generate_v4(),
        p_client_entity_id,
        p_approval_group_name,
        'Approval group for ' || p_description,
        'ACTIVE'
    ) RETURNING approval_group_id INTO p_approval_group_id;
    
    -- Link workflow to approval group
    INSERT INTO workflow_approval_groups (
        workflow_id,
        approval_group_id,
        approval_level
    ) VALUES (
        p_workflow_id,
        p_approval_group_id,
        1
    );
    
    -- Add users to approval group
    FOREACH v_user_id IN ARRAY p_approver_user_ids
    LOOP
        -- Check if user exists
        IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = v_user_id) THEN
            RAISE EXCEPTION 'User with ID % not found', v_user_id;
        END IF;
        
        -- Add user to approval group
        INSERT INTO approval_group_members (
            approval_group_id,
            user_id
        ) VALUES (
            p_approval_group_id,
            v_user_id
        );
    END LOOP;
    
    -- Log the workflow setup
    INSERT INTO audit_logs (
        user_id,
        action,
        entity_type,
        entity_id,
        details
    ) VALUES (
        NULL,
        'SETUP_APPROVAL_WORKFLOW',
        'WORKFLOW',
        p_workflow_id,
        jsonb_build_object(
            'description', p_description,
            'min_approvers', p_min_approvers,
            'threshold_amount', p_threshold_amount,
            'currency', p_currency,
            'approval_group_id', p_approval_group_id,
            'approver_count', array_length(p_approver_user_ids, 1)
        )
    );
END;
$$;

-- 5. Delegate Permissions Procedure
-- Delegates permissions from one user to another
CREATE OR REPLACE PROCEDURE delegate_permissions_proc(
    p_delegator_user_id UUID,
    p_delegate_user_id UUID,
    p_start_date TIMESTAMP WITH TIME ZONE,
    p_end_date TIMESTAMP WITH TIME ZONE,
    p_reason TEXT,
    p_created_by UUID,
    OUT p_delegation_id UUID
) LANGUAGE plpgsql AS $$
BEGIN
    -- Check if users exist
    IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = p_delegator_user_id) THEN
        RAISE EXCEPTION 'Delegator user with ID % not found', p_delegator_user_id;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = p_delegate_user_id) THEN
        RAISE EXCEPTION 'Delegate user with ID % not found', p_delegate_user_id;
    END IF;
    
    -- Check if users are the same
    IF p_delegator_user_id = p_delegate_user_id THEN
        RAISE EXCEPTION 'Delegator and delegate cannot be the same user';
    END IF;
    
    -- Check date range
    IF p_start_date >= p_end_date THEN
        RAISE EXCEPTION 'End date must be after start date';
    END IF;
    
    -- Create delegation
    INSERT INTO delegations (
        delegation_id,
        delegator_user_id,
        delegate_user_id,
        start_date,
        end_date,
        reason,
        status
    ) VALUES (
        uuid_generate_v4(),
        p_delegator_user_id,
        p_delegate_user_id,
        p_start_date,
        p_end_date,
        p_reason,
        'APPROVED'
    ) RETURNING delegation_id INTO p_delegation_id;
    
    -- Log the delegation
    INSERT INTO audit_logs (
        user_id,
        action,
        entity_type,
        entity_id,
        details
    ) VALUES (
        p_created_by,
        'CREATE_DELEGATION',
        'USER',
        p_delegator_user_id,
        jsonb_build_object(
            'delegation_id', p_delegation_id,
            'delegate_user_id', p_delegate_user_id,
            'start_date', p_start_date,
            'end_date', p_end_date,
            'reason', p_reason
        )
    );
END;
$$;

-- 6. Add User to Groups Procedure
-- Adds a user to multiple groups in one operation
CREATE OR REPLACE PROCEDURE add_user_to_groups_proc(
    p_user_id UUID,
    p_user_group_ids UUID[],
    p_created_by UUID
) LANGUAGE plpgsql AS $$
DECLARE
    v_user_group_id UUID;
    v_client_entity_id UUID;
    v_user_client_entity_id UUID;
BEGIN
    -- Check if user exists
    SELECT client_entity_id INTO v_user_client_entity_id
    FROM users
    WHERE user_id = p_user_id;
    
    IF v_user_client_entity_id IS NULL THEN
        RAISE EXCEPTION 'User with ID % not found', p_user_id;
    END IF;
    
    -- Add user to each group
    FOREACH v_user_group_id IN ARRAY p_user_group_ids
    LOOP
        -- Check if group exists
        SELECT client_entity_id INTO v_client_entity_id
        FROM user_groups
        WHERE user_group_id = v_user_group_id;
        
        IF v_client_entity_id IS NULL THEN
            RAISE EXCEPTION 'User group with ID % not found', v_user_group_id;
        END IF;
        
        -- Check if user and group belong to the same client entity
        IF v_client_entity_id != v_user_client_entity_id THEN
            RAISE EXCEPTION 'User and group must belong to the same client entity';
        END IF;
        
        -- Check if user is already in the group
        IF EXISTS (
            SELECT 1
            FROM user_group_members
            WHERE user_id = p_user_id AND user_group_id = v_user_group_id
        ) THEN
            RAISE NOTICE 'User is already a member of group %', v_user_group_id;
            CONTINUE;
        END IF;
        
        -- Add user to group
        INSERT INTO user_group_members (
            user_id,
            user_group_id
        ) VALUES (
            p_user_id,
            v_user_group_id
        );
        
        -- Log the addition
        INSERT INTO audit_logs (
            user_id,
            action,
            entity_type,
            entity_id,
            details
        ) VALUES (
            p_created_by,
            'ADD_USER_TO_GROUP',
            'USER',
            p_user_id,
            jsonb_build_object(
                'user_group_id', v_user_group_id
            )
        );
    END LOOP;
END;
$$;

-- 7. Audit Permission Changes Procedure
-- Records permission changes in the audit log
CREATE OR REPLACE PROCEDURE audit_permission_changes_proc(
    p_user_id UUID,
    p_action VARCHAR,
    p_entity_type VARCHAR,
    p_entity_id UUID,
    p_details JSONB
) LANGUAGE plpgsql AS $$
BEGIN
    -- Check if user exists if provided
    IF p_user_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM users WHERE user_id = p_user_id) THEN
        RAISE EXCEPTION 'User with ID % not found', p_user_id;
    END IF;
    
    -- Insert audit log
    INSERT INTO audit_logs (
        user_id,
        action,
        entity_type,
        entity_id,
        details,
        ip_address,
        user_agent
    ) VALUES (
        p_user_id,
        p_action,
        p_entity_type,
        p_entity_id,
        p_details,
        NULL, -- IP address would be captured in a real application
        NULL  -- User agent would be captured in a real application
    );
END;
$$;
