-- Cash Management Entitlement System Schema
-- PostgreSQL Database Design

-- Enable UUID extension for unique identifiers
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Organizational Hierarchy Tables

-- Bank - Root entity of the system
CREATE TABLE banks (
    bank_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Region/Branch - Geographic divisions of the bank
CREATE TABLE regions (
    region_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bank_id UUID NOT NULL REFERENCES banks(bank_id),
    name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Client Group - Parent organization using the system
CREATE TABLE client_groups (
    client_group_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bank_id UUID NOT NULL REFERENCES banks(bank_id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Client Entity - Specific business unit of a client group
CREATE TABLE client_entities (
    client_entity_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_group_id UUID NOT NULL REFERENCES client_groups(client_group_id),
    region_id UUID REFERENCES regions(region_id),
    name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User Group - Collection of users with similar roles
CREATE TABLE user_groups (
    user_group_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_entity_id UUID NOT NULL REFERENCES client_entities(client_entity_id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User - Individual system users
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_entity_id UUID NOT NULL REFERENCES client_entities(client_entity_id),
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User to User Group mapping (many-to-many)
CREATE TABLE user_group_members (
    user_id UUID NOT NULL REFERENCES users(user_id),
    user_group_id UUID NOT NULL REFERENCES user_groups(user_group_id),
    PRIMARY KEY (user_id, user_group_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Product & Service Hierarchy Tables

-- Product Category - High-level product grouping
CREATE TABLE product_categories (
    product_category_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Product - Specific financial product
CREATE TABLE products (
    product_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_category_id UUID NOT NULL REFERENCES product_categories(product_category_id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Service - Specific service within a product
CREATE TABLE services (
    service_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES products(product_id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Account - Financial accounts
CREATE TABLE accounts (
    account_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_entity_id UUID NOT NULL REFERENCES client_entities(client_entity_id),
    account_number VARCHAR(50) NOT NULL UNIQUE,
    account_name VARCHAR(100) NOT NULL,
    currency CHAR(3) NOT NULL,
    account_type VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Permission Structure Tables

-- Permission - Granular system capabilities
CREATE TABLE permissions (
    permission_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    code VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Role - Collection of permissions
CREATE TABLE roles (
    role_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Role to Permission mapping (many-to-many)
CREATE TABLE role_permissions (
    role_id UUID NOT NULL REFERENCES roles(role_id),
    permission_id UUID NOT NULL REFERENCES permissions(permission_id),
    PRIMARY KEY (role_id, permission_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

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

-- Entitlement - Assignment of permissions to entities at various levels
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

-- Create index for faster entitlement lookups
CREATE INDEX idx_entitlements_entity ON entitlements(entity_type, entity_id);
CREATE INDEX idx_entitlements_scope ON entitlements(scope_type, scope_id);

-- Approval Limit - Transaction amount limits
CREATE TABLE approval_limits (
    limit_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id),
    product_id UUID REFERENCES products(product_id),
    service_id UUID REFERENCES services(service_id),
    account_id UUID REFERENCES accounts(account_id),
    currency CHAR(3) NOT NULL,
    min_amount DECIMAL(20, 2) DEFAULT 0,
    max_amount DECIMAL(20, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_amount_range CHECK (max_amount >= min_amount)
);

-- Approval Workflow - Multi-level approval requirements
CREATE TABLE approval_workflows (
    workflow_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_entity_id UUID NOT NULL REFERENCES client_entities(client_entity_id),
    product_id UUID REFERENCES products(product_id),
    service_id UUID REFERENCES services(service_id),
    min_approvers INTEGER NOT NULL DEFAULT 1,
    threshold_amount DECIMAL(20, 2),
    currency CHAR(3) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_min_approvers CHECK (min_approvers > 0)
);

-- Approval Group - Groups of users who can approve transactions
CREATE TABLE approval_groups (
    approval_group_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_entity_id UUID NOT NULL REFERENCES client_entities(client_entity_id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Approval Group Members - Users in approval groups
CREATE TABLE approval_group_members (
    approval_group_id UUID NOT NULL REFERENCES approval_groups(approval_group_id),
    user_id UUID NOT NULL REFERENCES users(user_id),
    PRIMARY KEY (approval_group_id, user_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Workflow to Approval Group mapping
CREATE TABLE workflow_approval_groups (
    workflow_id UUID NOT NULL REFERENCES approval_workflows(workflow_id),
    approval_group_id UUID NOT NULL REFERENCES approval_groups(approval_group_id),
    approval_level INTEGER NOT NULL DEFAULT 1,
    PRIMARY KEY (workflow_id, approval_group_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Delegation - Temporary delegation of permissions
CREATE TABLE delegations (
    delegation_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    delegator_user_id UUID NOT NULL REFERENCES users(user_id),
    delegate_user_id UUID NOT NULL REFERENCES users(user_id),
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    reason TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_delegation_date_range CHECK (end_date > start_date),
    CONSTRAINT different_users CHECK (delegator_user_id != delegate_user_id)
);

-- Audit Trail - Tracking all permission changes and access attempts
CREATE TABLE audit_logs (
    log_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(user_id),
    action VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID,
    details JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Views for permission resolution

-- View to resolve effective permissions for users
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
    
    UNION ALL
    
    -- Region level permissions
    SELECT 
        e.permission_id,
        u.user_id,
        'REGION' AS source_type,
        r.region_id AS source_id,
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
        e.scope_type,
        e.scope_id,
        e.is_denied
    FROM 
        entitlements e
        JOIN users u ON e.entity_type = 'USER' AND e.entity_id = u.user_id
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

-- Function to check if a user has a specific permission
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
