-- Example Data for Cash Management Entitlement System
-- This file contains INSERT statements for all entities in the system

-- Banks
INSERT INTO banks (bank_id, name, description, status) VALUES
('11111111-1111-1111-1111-111111111111', 'ABC Bank', 'Global financial institution', 'ACTIVE'),
('22222222-2222-2222-2222-222222222222', 'SMBC Bank', 'Japanese multinational banking institution', 'ACTIVE');

-- Regions
INSERT INTO regions (region_id, bank_id, name, location, status) VALUES
('11111111-1111-1111-1111-111111111112', '11111111-1111-1111-1111-111111111111', 'Americas', 'New York', 'ACTIVE'),
('11111111-1111-1111-1111-111111111113', '11111111-1111-1111-1111-111111111111', 'EMEA', 'London', 'ACTIVE'),
('11111111-1111-1111-1111-111111111114', '11111111-1111-1111-1111-111111111111', 'Asia', 'Singapore', 'ACTIVE'),
('22222222-2222-2222-2222-222222222223', '22222222-2222-2222-2222-222222222222', 'Americas', 'New York', 'ACTIVE'),
('22222222-2222-2222-2222-222222222224', '22222222-2222-2222-2222-222222222222', 'Asia', 'Tokyo', 'ACTIVE');

-- Client Groups
INSERT INTO client_groups (client_group_id, bank_id, name, description, status) VALUES
('33333333-3333-3333-3333-333333333331', '11111111-1111-1111-1111-111111111111', 'Toyota Corporation', 'Global automotive manufacturer', 'ACTIVE'),
('33333333-3333-3333-3333-333333333332', '11111111-1111-1111-1111-111111111111', 'General Motors', 'American automotive manufacturer', 'ACTIVE'),
('33333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222', 'Sony Corporation', 'Japanese multinational conglomerate', 'ACTIVE');

-- Client Entities
INSERT INTO client_entities (client_entity_id, client_group_id, region_id, name, location, status) VALUES
('44444444-4444-4444-4444-444444444441', '33333333-3333-3333-3333-333333333331', '11111111-1111-1111-1111-111111111112', 'Toyota North America', 'New York', 'ACTIVE'),
('44444444-4444-4444-4444-444444444442', '33333333-3333-3333-3333-333333333331', '11111111-1111-1111-1111-111111111113', 'Toyota Europe', 'London', 'ACTIVE'),
('44444444-4444-4444-4444-444444444443', '33333333-3333-3333-3333-333333333331', '11111111-1111-1111-1111-111111111114', 'Toyota Japan', 'Tokyo', 'ACTIVE'),
('44444444-4444-4444-4444-444444444444', '33333333-3333-3333-3333-333333333332', '11111111-1111-1111-1111-111111111112', 'GM North America', 'Detroit', 'ACTIVE'),
('44444444-4444-4444-4444-444444444445', '33333333-3333-3333-3333-333333333332', '11111111-1111-1111-1111-111111111113', 'GM Europe', 'Frankfurt', 'ACTIVE'),
('44444444-4444-4444-4444-444444444446', '33333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222224', 'Sony Electronics', 'Tokyo', 'ACTIVE'),
('44444444-4444-4444-4444-444444444447', '33333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222223', 'Sony Pictures', 'Los Angeles', 'ACTIVE');

-- User Groups
INSERT INTO user_groups (user_group_id, client_entity_id, name, description, status) VALUES
('55555555-5555-5555-5555-555555555551', '44444444-4444-4444-4444-444444444441', 'Finance Administrators', 'Users who manage financial operations', 'ACTIVE'),
('55555555-5555-5555-5555-555555555552', '44444444-4444-4444-4444-444444444441', 'Payment Initiators', 'Users who can initiate payments', 'ACTIVE'),
('55555555-5555-5555-5555-555555555553', '44444444-4444-4444-4444-444444444441', 'Payment Approvers', 'Users who can approve payments', 'ACTIVE'),
('55555555-5555-5555-5555-555555555554', '44444444-4444-4444-4444-444444444443', 'Finance Administrators', 'Users who manage financial operations', 'ACTIVE'),
('55555555-5555-5555-5555-555555555555', '44444444-4444-4444-4444-444444444444', 'Finance Administrators', 'Users who manage financial operations', 'ACTIVE'),
('55555555-5555-5555-5555-555555555556', '44444444-4444-4444-4444-444444444444', 'Payment Approvers', 'Users who can approve payments', 'ACTIVE'),
('55555555-5555-5555-5555-555555555557', '44444444-4444-4444-4444-444444444446', 'Finance Administrators', 'Users who manage financial operations', 'ACTIVE'),
('55555555-5555-5555-5555-555555555558', '44444444-4444-4444-4444-444444444446', 'Payment Initiators', 'Users who can initiate payments', 'ACTIVE');

-- Users
INSERT INTO users (user_id, client_entity_id, username, email, first_name, last_name, status) VALUES
('66666666-6666-6666-6666-666666666661', '44444444-4444-4444-4444-444444444441', 'jsmith', 'john.smith@toyota.com', 'John', 'Smith', 'ACTIVE'),
('66666666-6666-6666-6666-666666666662', '44444444-4444-4444-4444-444444444441', 'ejohnson', 'emily.johnson@toyota.com', 'Emily', 'Johnson', 'ACTIVE'),
('66666666-6666-6666-6666-666666666663', '44444444-4444-4444-4444-444444444441', 'mbrown', 'michael.brown@toyota.com', 'Michael', 'Brown', 'ACTIVE'),
('66666666-6666-6666-6666-666666666664', '44444444-4444-4444-4444-444444444443', 'sdavis', 'sarah.davis@toyota.co.jp', 'Sarah', 'Davis', 'ACTIVE'),
('66666666-6666-6666-6666-666666666665', '44444444-4444-4444-4444-444444444444', 'dwilson', 'david.wilson@gm.com', 'David', 'Wilson', 'ACTIVE'),
('66666666-6666-6666-6666-666666666666', '44444444-4444-4444-4444-444444444444', 'jlee', 'jennifer.lee@gm.com', 'Jennifer', 'Lee', 'ACTIVE'),
('66666666-6666-6666-6666-666666666667', '44444444-4444-4444-4444-444444444446', 'rchen', 'robert.chen@sony.com', 'Robert', 'Chen', 'ACTIVE'),
('66666666-6666-6666-6666-666666666668', '44444444-4444-4444-4444-444444444446', 'lwang', 'lisa.wang@sony.com', 'Lisa', 'Wang', 'ACTIVE');

-- User Group Members
INSERT INTO user_group_members (user_id, user_group_id) VALUES
('66666666-6666-6666-6666-666666666661', '55555555-5555-5555-5555-555555555551'),
('66666666-6666-6666-6666-666666666662', '55555555-5555-5555-5555-555555555552'),
('66666666-6666-6666-6666-666666666663', '55555555-5555-5555-5555-555555555553'),
('66666666-6666-6666-6666-666666666664', '55555555-5555-5555-5555-555555555554'),
('66666666-6666-6666-6666-666666666665', '55555555-5555-5555-5555-555555555555'),
('66666666-6666-6666-6666-666666666666', '55555555-5555-5555-5555-555555555556'),
('66666666-6666-6666-6666-666666666667', '55555555-5555-5555-5555-555555555557'),
('66666666-6666-6666-6666-666666666668', '55555555-5555-5555-5555-555555555558');

-- Product Categories
INSERT INTO product_categories (product_category_id, name, description, status) VALUES
('77777777-7777-7777-7777-777777777771', 'Payments', 'All payment-related products', 'ACTIVE'),
('77777777-7777-7777-7777-777777777772', 'Deposits', 'All deposit-related products', 'ACTIVE'),
('77777777-7777-7777-7777-777777777773', 'Loans', 'All loan-related products', 'ACTIVE'),
('77777777-7777-7777-7777-777777777774', 'Treasury', 'All treasury management products', 'ACTIVE');

-- Products
INSERT INTO products (product_id, product_category_id, name, description, status) VALUES
('88888888-8888-8888-8888-888888888881', '77777777-7777-7777-7777-777777777771', 'Wire Transfers', 'Electronic funds transfers', 'ACTIVE'),
('88888888-8888-8888-8888-888888888882', '77777777-7777-7777-7777-777777777771', 'ACH Payments', 'Automated Clearing House payments', 'ACTIVE'),
('88888888-8888-8888-8888-888888888883', '77777777-7777-7777-7777-777777777772', 'Term Deposits', 'Fixed-term deposit accounts', 'ACTIVE'),
('88888888-8888-8888-8888-888888888884', '77777777-7777-7777-7777-777777777772', 'Demand Deposits', 'On-demand deposit accounts', 'ACTIVE'),
('88888888-8888-8888-8888-888888888885', '77777777-7777-7777-7777-777777777773', 'Commercial Loans', 'Business loans', 'ACTIVE'),
('88888888-8888-8888-8888-888888888886', '77777777-7777-7777-7777-777777777773', 'Trade Finance', 'Import/export financing', 'ACTIVE'),
('88888888-8888-8888-8888-888888888887', '77777777-7777-7777-7777-777777777774', 'Foreign Exchange', 'Currency exchange services', 'ACTIVE');

-- Services
INSERT INTO services (service_id, product_id, name, description, status) VALUES
('99999999-9999-9999-9999-999999999991', '88888888-8888-8888-8888-888888888881', 'Initiate Wire Transfer', 'Create a new wire transfer', 'ACTIVE'),
('99999999-9999-9999-9999-999999999992', '88888888-8888-8888-8888-888888888881', 'Approve Wire Transfer', 'Approve a pending wire transfer', 'ACTIVE'),
('99999999-9999-9999-9999-999999999993', '88888888-8888-8888-8888-888888888881', 'View Wire Transfer', 'View wire transfer details', 'ACTIVE'),
('99999999-9999-9999-9999-999999999994', '88888888-8888-8888-8888-888888888882', 'Initiate ACH Payment', 'Create a new ACH payment', 'ACTIVE'),
('99999999-9999-9999-9999-999999999995', '88888888-8888-8888-8888-888888888882', 'Approve ACH Payment', 'Approve a pending ACH payment', 'ACTIVE'),
('99999999-9999-9999-9999-999999999996', '88888888-8888-8888-8888-888888888882', 'View ACH Payment', 'View ACH payment details', 'ACTIVE'),
('99999999-9999-9999-9999-999999999997', '88888888-8888-8888-8888-888888888883', 'Open Term Deposit', 'Create a new term deposit', 'ACTIVE'),
('99999999-9999-9999-9999-999999999998', '88888888-8888-8888-8888-888888888883', 'Close Term Deposit', 'Close an existing term deposit', 'ACTIVE'),
('99999999-9999-9999-9999-999999999999', '88888888-8888-8888-8888-888888888885', 'Apply for Loan', 'Submit a loan application', 'ACTIVE'),
('99999999-9999-9999-9999-999999999910', '88888888-8888-8888-8888-888888888885', 'Approve Loan', 'Approve a loan application', 'ACTIVE');

-- Accounts
INSERT INTO accounts (account_id, client_entity_id, account_number, account_name, currency, account_type, status) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '44444444-4444-4444-4444-444444444441', '1001001001', 'Toyota NA Operating Account', 'USD', 'CURRENT', 'ACTIVE'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaab', '44444444-4444-4444-4444-444444444441', '1001001002', 'Toyota NA Payroll Account', 'USD', 'CURRENT', 'ACTIVE'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaac', '44444444-4444-4444-4444-444444444443', '1001001003', 'Toyota Japan Operating Account', 'JPY', 'CURRENT', 'ACTIVE'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaad', '44444444-4444-4444-4444-444444444444', '1001001004', 'GM NA Operating Account', 'USD', 'CURRENT', 'ACTIVE'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaae', '44444444-4444-4444-4444-444444444446', '1001001005', 'Sony Electronics Operating Account', 'JPY', 'CURRENT', 'ACTIVE');

-- Permissions
INSERT INTO permissions (permission_id, name, description, code) VALUES
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbba', 'View Account', 'View account details', 'VIEW_ACCOUNT'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'View Balance', 'View account balance', 'VIEW_BALANCE'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbc', 'View Transactions', 'View account transactions', 'VIEW_TRANSACTIONS'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbd', 'Initiate Payment', 'Initiate a payment', 'INITIATE_PAYMENT'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbe', 'Approve Payment', 'Approve a payment', 'APPROVE_PAYMENT'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbf', 'Cancel Payment', 'Cancel a payment', 'CANCEL_PAYMENT'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbcg', 'Open Deposit', 'Open a deposit account', 'OPEN_DEPOSIT'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbch', 'Close Deposit', 'Close a deposit account', 'CLOSE_DEPOSIT'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbci', 'Apply Loan', 'Apply for a loan', 'APPLY_LOAN'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbcj', 'Approve Loan', 'Approve a loan application', 'APPROVE_LOAN'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbck', 'Admin User Management', 'Manage users', 'ADMIN_USER_MANAGEMENT'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbcl', 'Admin Entitlement', 'Manage entitlements', 'ADMIN_ENTITLEMENT');

-- Roles
INSERT INTO roles (role_id, name, description) VALUES
('cccccccc-cccc-cccc-cccc-ccccccccccca', 'Account Viewer', 'Can view account information'),
('cccccccc-cccc-cccc-cccc-cccccccccccb', 'Payment Initiator', 'Can initiate payments'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Payment Approver', 'Can approve payments'),
('cccccccc-cccc-cccc-cccc-cccccccccccd', 'Deposit Manager', 'Can manage deposit accounts'),
('cccccccc-cccc-cccc-cccc-cccccccccccf', 'Loan Officer', 'Can manage loan applications'),
('cccccccc-cccc-cccc-cccc-cccccccccccg', 'System Administrator', 'Can manage system settings');

-- Role Permissions
INSERT INTO role_permissions (role_id, permission_id) VALUES
('cccccccc-cccc-cccc-cccc-ccccccccccca', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbba'),
('cccccccc-cccc-cccc-cccc-ccccccccccca', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
('cccccccc-cccc-cccc-cccc-ccccccccccca', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbc'),
('cccccccc-cccc-cccc-cccc-cccccccccccb', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbba'),
('cccccccc-cccc-cccc-cccc-cccccccccccb', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
('cccccccc-cccc-cccc-cccc-cccccccccccb', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbc'),
('cccccccc-cccc-cccc-cccc-cccccccccccb', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbd'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbba'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbc'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbe'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbf');

-- Approval Groups
INSERT INTO approval_groups (approval_group_id, client_entity_id, name, description, status) VALUES
('dddddddd-dddd-dddd-dddd-ddddddddddda', '44444444-4444-4444-4444-444444444441', 'Toyota NA Payment Approvers', 'Group for Toyota North America payment approvers', 'ACTIVE'),
('dddddddd-dddd-dddd-dddd-ddddddddddb', '44444444-4444-4444-4444-444444444443', 'Toyota Japan Payment Approvers', 'Group for Toyota Japan payment approvers', 'ACTIVE'),
('dddddddd-dddd-dddd-dddd-dddddddddddc', '44444444-4444-4444-4444-444444444444', 'GM NA Payment Approvers', 'Group for GM North America payment approvers', 'ACTIVE'),
('dddddddd-dddd-dddd-dddd-ddddddddddd', '44444444-4444-4444-4444-444444444446', 'Sony Electronics Payment Approvers', 'Group for Sony Electronics payment approvers', 'ACTIVE');

-- Approval Group Members
INSERT INTO approval_group_members (approval_group_id, user_id) VALUES
('dddddddd-dddd-dddd-dddd-ddddddddddda', '66666666-6666-6666-6666-666666666663'),
('dddddddd-dddd-dddd-dddd-ddddddddddb', '66666666-6666-6666-6666-666666666664'),
('dddddddd-dddd-dddd-dddd-dddddddddddc', '66666666-6666-6666-6666-666666666666'),
('dddddddd-dddd-dddd-dddd-ddddddddddd', '66666666-6666-6666-6666-666666666667');

-- Approval Workflows
INSERT INTO approval_workflows (workflow_id, client_entity_id, product_id, service_id, min_approvers, threshold_amount, currency, description) VALUES
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeea', '44444444-4444-4444-4444-444444444441', '88888888-8888-8888-8888-888888888881', '99999999-9999-9999-9999-999999999992', 2, 50000.00, 'USD', 'Toyota NA Wire Transfer Approval'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeb', '44444444-4444-4444-4444-444444444443', '88888888-8888-8888-8888-888888888881', '99999999-9999-9999-9999-999999999992', 2, 5000000.00, 'JPY', 'Toyota Japan Wire Transfer Approval'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeec', '44444444-4444-4444-4444-444444444444', '88888888-8888-8888-8888-888888888882', '99999999-9999-9999-9999-999999999995', 1, 25000.00, 'USD', 'GM NA ACH Payment Approval - Tier 1'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeed', '44444444-4444-4444-4444-444444444444', '88888888-8888-8888-8888-888888888882', '99999999-9999-9999-9999-999999999995', 2, 100000.00, 'USD', 'GM NA ACH Payment Approval - Tier 2'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '44444444-4444-4444-4444-444444444446', '88888888-8888-8888-8888-888888888881', '99999999-9999-9999-9999-999999999992', 2, 0.00, 'JPY', 'Sony Electronics Payment Approval');

-- Workflow Approval Groups
INSERT INTO workflow_approval_groups (workflow_id, approval_group_id, approval_level) VALUES
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeea', 'dddddddd-dddd-dddd-dddd-ddddddddddda', 1),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeb', 'dddddddd-dddd-dddd-dddd-ddddddddddb', 1),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeec', 'dddddddd-dddd-dddd-dddd-dddddddddddc', 1),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeed', 'dddddddd-dddd-dddd-dddd-dddddddddddc', 1),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'dddddddd-dddd-dddd-dddd-ddddddddddd', 1);

-- Approval Limits
INSERT INTO approval_limits (limit_id, user_id, product_id, service_id, account_id, currency, min_amount, max_amount) VALUES
('ffffffff-ffff-ffff-ffff-ffffffffffff', '66666666-6666-6666-6666-666666666663', '88888888-8888-8888-8888-888888888881', '99999999-9999-9999-9999-999999999992', NULL, 'USD', 0.00, 25000.00),
('ffffffff-ffff-ffff-ffff-fffffffffff1', '66666666-6666-6666-6666-666666666661', '88888888-8888-8888-8888-888888888881', '99999999-9999-9999-9999-999999999992', NULL, 'USD', 0.00, 100000.00),
('ffffffff-ffff-ffff-ffff-fffffffffff2', '66666666-6666-6666-6666-666666666664', '88888888-8888-8888-8888-888888888881', '99999999-9999-9999-9999-999999999992', NULL, 'JPY', 0.00, 2000000.00),
('ffffffff-ffff-ffff-ffff-fffffffffff3', '66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888882', '99999999-9999-9999-9999-999999999995', NULL, 'USD', 0.00, 50000.00),
('ffffffff-ffff-ffff-ffff-fffffffffff4', '66666666-6666-6666-6666-666666666667', '88888888-8888-8888-8888-888888888881', '99999999-9999-9999-9999-999999999992', NULL, 'JPY', 0.00, 3000000.00);

-- Entitlements (Bank Level)
INSERT INTO entitlements (entitlement_id, entity_type, entity_id, permission_id, scope_type, scope_id, is_denied, created_by) VALUES
('11111111-aaaa-bbbb-cccc-dddddddddddd', 'BANK', '11111111-1111-1111-1111-111111111111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbba', 'GLOBAL', NULL, FALSE, '66666666-6666-6666-6666-666666666661'),
('22222222-aaaa-bbbb-cccc-dddddddddddd', 'BANK', '11111111-1111-1111-1111-111111111111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'GLOBAL', NULL, FALSE, '66666666-6666-6666-6666-666666666661'),
('33333333-aaaa-bbbb-cccc-dddddddddddd', 'BANK', '11111111-1111-1111-1111-111111111111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbc', 'GLOBAL', NULL, FALSE, '66666666-6666-6666-6666-666666666661');

-- Entitlements (Region Level)
INSERT INTO entitlements (entitlement_id, entity_type, entity_id, permission_id, scope_type, scope_id, is_denied, created_by) VALUES
('44444444-aaaa-bbbb-cccc-dddddddddddd', 'REGION', '11111111-1111-1111-1111-111111111112', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbd', 'PRODUCT', '88888888-8888-8888-8888-888888888881', FALSE, '66666666-6666-6666-6666-666666666661'),
('55555555-aaaa-bbbb-cccc-dddddddddddd', 'REGION', '11111111-1111-1111-1111-111111111112', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbd', 'PRODUCT', '88888888-8888-8888-8888-888888888882', FALSE, '66666666-6666-6666-6666-666666666661'),
('66666666-aaaa-bbbb-cccc-dddddddddddd', 'REGION', '11111111-1111-1111-1111-111111111114', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbd', 'PRODUCT', '88888888-8888-8888-8888-888888888881', FALSE, '66666666-6666-6666-6666-666666666661');

-- Entitlements (Client Group Level)
INSERT INTO entitlements (entitlement_id, entity_type, entity_id, permission_id, scope_type, scope_id, is_denied, created_by) VALUES
('77777777-aaaa-bbbb-cccc-dddddddddddd', 'CLIENT_GROUP', '33333333-3333-3333-3333-333333333331', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbe', 'PRODUCT', '88888888-8888-8888-8888-888888888881', FALSE, '66666666-6666-6666-6666-666666666661'),
('88888888-aaaa-bbbb-cccc-dddddddddddd', 'CLIENT_GROUP', '33333333-3333-3333-3333-333333333332', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbe', 'PRODUCT', '88888888-8888-8888-8888-888888888882', FALSE, '66666666-6666-6666-6666-666666666661'),
('99999999-aaaa-bbbb-cccc-dddddddddddd', 'CLIENT_GROUP', '33333333-3333-3333-3333-333333333333', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbe', 'PRODUCT', '88888888-8888-8888-8888-888888888881', FALSE, '66666666-6666-6666-6666-666666666661');

-- Entitlements (Client Entity Level)
INSERT INTO entitlements (entitlement_id, entity_type, entity_id, permission_id, scope_type, scope_id, is_denied, created_by) VALUES
('aaaaaaaa-aaaa-bbbb-cccc-dddddddddddd', 'CLIENT_ENTITY', '44444444-4444-4444-4444-444444444441', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbcg', 'PRODUCT', '88888888-8888-8888-8888-888888888883', FALSE, '66666666-6666-6666-6666-666666666661'),
('bbbbbbbb-aaaa-bbbb-cccc-dddddddddddd', 'CLIENT_ENTITY', '44444444-4444-4444-4444-444444444443', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbcg', 'PRODUCT', '88888888-8888-8888-8888-888888888883', FALSE, '66666666-6666-6666-6666-666666666661'),
('cccccccc-aaaa-bbbb-cccc-dddddddddddd', 'CLIENT_ENTITY', '44444444-4444-4444-4444-444444444444', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbci', 'PRODUCT', '88888888-8888-8888-8888-888888888885', FALSE, '66666666-6666-6666-6666-666666666661');

-- Entitlements (User Group Level)
INSERT INTO entitlements (entitlement_id, entity_type, entity_id, permission_id, scope_type, scope_id, is_denied, created_by) VALUES
('dddddddd-aaaa-bbbb-cccc-dddddddddddd', 'USER_GROUP', '55555555-5555-5555-5555-555555555551', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbck', 'GLOBAL', NULL, FALSE, '66666666-6666-6666-6666-666666666661'),
('eeeeeeee-aaaa-bbbb-cccc-dddddddddddd', 'USER_GROUP', '55555555-5555-5555-5555-555555555552', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbd', 'PRODUCT', '88888888-8888-8888-8888-888888888881', FALSE, '66666666-6666-6666-6666-666666666661'),
('ffffffff-aaaa-bbbb-cccc-dddddddddddd', 'USER_GROUP', '55555555-5555-5555-5555-555555555553', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbe', 'PRODUCT', '88888888-8888-8888-8888-888888888881', FALSE, '66666666-6666-6666-6666-666666666661');

-- Entitlements (User Level)
INSERT INTO entitlements (entitlement_id, entity_type, entity_id, permission_id, scope_type, scope_id, is_denied, created_by) VALUES
('11111111-aaaa-bbbb-cccc-eeeeeeeeeeee', 'USER', '66666666-6666-6666-6666-666666666661', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbcl', 'GLOBAL', NULL, FALSE, '66666666-6666-6666-6666-666666666661'),
('22222222-aaaa-bbbb-cccc-eeeeeeeeeeee', 'USER', '66666666-6666-6666-6666-666666666662', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbd', 'ACCOUNT', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', FALSE, '66666666-6666-6666-6666-666666666661'),
('33333333-aaaa-bbbb-cccc-eeeeeeeeeeee', 'USER', '66666666-6666-6666-6666-666666666663', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbe', 'ACCOUNT', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', FALSE, '66666666-6666-6666-6666-666666666661'),
('44444444-aaaa-bbbb-cccc-eeeeeeeeeeee', 'USER', '66666666-6666-6666-6666-666666666664', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbe', 'ACCOUNT', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaac', FALSE, '66666666-6666-6666-6666-666666666661'),
('55555555-aaaa-bbbb-cccc-eeeeeeeeeeee', 'USER', '66666666-6666-6666-6666-666666666665', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbd', 'ACCOUNT', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaad', FALSE, '66666666-6666-6666-6666-666666666661');

-- Entitlements (Explicit Denial Example)
INSERT INTO entitlements (entitlement_id, entity_type, entity_id, permission_id, scope_type, scope_id, is_denied, created_by) VALUES
('66666666-aaaa-bbbb-cccc-eeeeeeeeeeee', 'USER', '66666666-6666-6666-6666-666666666668', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbe', 'PRODUCT', '88888888-8888-8888-8888-888888888881', TRUE, '66666666-6666-6666-6666-666666666661');

-- Delegations
INSERT INTO delegations (delegation_id, delegator_user_id, delegate_user_id, start_date, end_date, reason, status) VALUES
('11111111-dddd-dddd-dddd-dddddddddddd', '66666666-6666-6666-6666-666666666661', '66666666-6666-6666-6666-666666666662', '2025-04-15 09:00:00', '2025-04-20 17:00:00', 'Vacation coverage', 'APPROVED');

-- Audit Logs
INSERT INTO audit_logs (log_id, user_id, action, entity_type, entity_id, details) VALUES
('11111111-eeee-eeee-eeee-eeeeeeeeeeee', '66666666-6666-6666-6666-666666666661', 'PERMISSION_GRANT', 'USER', '66666666-6666-6666-6666-666666666662', '{"permission": "INITIATE_PAYMENT", "scope": "ACCOUNT", "scope_id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"}'),
('22222222-eeee-eeee-eeee-eeeeeeeeeeee', '66666666-6666-6666-6666-666666666661', 'LOGIN', 'USER', '66666666-6666-6666-6666-666666666661', '{"ip": "192.168.1.1", "success": true}'),
('33333333-eeee-eeee-eeee-eeeeeeeeeeee', '66666666-6666-6666-6666-666666666663', 'PAYMENT_APPROVE', 'PAYMENT', NULL, '{"payment_id": "payment123", "amount": 15000.00, "currency": "USD"}');
