# Example Data for Cash Management Entitlement System

This document contains example data for all entities in the Cash Management Entitlement System. The data represents a realistic scenario with multiple banks, regions, client groups, client entities, users, products, and permissions.

## Scenario Overview

In this example scenario:

- **ABC Bank** is the primary banking institution offering cash management services
- **SMBC Bank** is another banking institution in the system
- Both banks have multiple regions (Americas, EMEA, Asia)
- Multiple client groups (Toyota, General Motors, Sony) with various entities
- Various products (Payments, Deposits, Loans) with associated services
- Different permission levels and entitlements across the hierarchy

## Example Data Structure

### Banks
1. ABC Bank - Global financial institution
2. SMBC Bank - Japanese multinational banking institution

### Regions
1. Americas (ABC Bank) - North and South America operations
2. EMEA (ABC Bank) - Europe, Middle East, and Africa operations
3. Asia (ABC Bank) - Asia-Pacific operations
4. Americas (SMBC Bank) - North and South America operations
5. Asia (SMBC Bank) - Asia-Pacific operations

### Client Groups
1. Toyota Corporation - Global automotive manufacturer
2. General Motors - American automotive manufacturer
3. Sony Corporation - Japanese multinational conglomerate

### Client Entities
1. Toyota North America - Based in New York
2. Toyota Europe - Based in London
3. Toyota Japan - Based in Tokyo
4. GM North America - Based in Detroit
5. GM Europe - Based in Frankfurt
6. Sony Electronics - Based in Tokyo
7. Sony Pictures - Based in Los Angeles

### User Groups
1. Finance Administrators - Users who manage financial operations
2. Payment Initiators - Users who can initiate payments
3. Payment Approvers - Users who can approve payments
4. Account Viewers - Users who can only view account information
5. Loan Officers - Users who manage loan products
6. System Administrators - Users who manage system settings

### Users
1. John Smith - Toyota North America Finance Administrator
2. Emily Johnson - Toyota North America Payment Initiator
3. Michael Brown - Toyota North America Payment Approver
4. Sarah Davis - Toyota Japan Finance Administrator
5. David Wilson - GM North America Finance Administrator
6. Jennifer Lee - GM North America Payment Approver
7. Robert Chen - Sony Electronics Finance Administrator
8. Lisa Wang - Sony Electronics Payment Initiator

### Product Categories
1. Payments - All payment-related products
2. Deposits - All deposit-related products
3. Loans - All loan-related products
4. Treasury - All treasury management products

### Products
1. Wire Transfers - Electronic funds transfers
2. ACH Payments - Automated Clearing House payments
3. Term Deposits - Fixed-term deposit accounts
4. Demand Deposits - On-demand deposit accounts
5. Commercial Loans - Business loans
6. Trade Finance - Import/export financing
7. Foreign Exchange - Currency exchange services

### Services
1. Initiate Wire Transfer - Create a new wire transfer
2. Approve Wire Transfer - Approve a pending wire transfer
3. View Wire Transfer - View wire transfer details
4. Initiate ACH Payment - Create a new ACH payment
5. Approve ACH Payment - Approve a pending ACH payment
6. View ACH Payment - View ACH payment details
7. Open Term Deposit - Create a new term deposit
8. Close Term Deposit - Close an existing term deposit
9. Apply for Loan - Submit a loan application
10. Approve Loan - Approve a loan application

### Accounts
1. Toyota North America Operating Account - USD current account
2. Toyota North America Payroll Account - USD payroll account
3. Toyota Japan Operating Account - JPY current account
4. GM North America Operating Account - USD current account
5. Sony Electronics Operating Account - JPY current account

### Permissions
1. VIEW_ACCOUNT - View account details
2. VIEW_BALANCE - View account balance
3. VIEW_TRANSACTIONS - View account transactions
4. INITIATE_PAYMENT - Initiate a payment
5. APPROVE_PAYMENT - Approve a payment
6. CANCEL_PAYMENT - Cancel a payment
7. OPEN_DEPOSIT - Open a deposit account
8. CLOSE_DEPOSIT - Close a deposit account
9. APPLY_LOAN - Apply for a loan
10. APPROVE_LOAN - Approve a loan application
11. ADMIN_USER_MANAGEMENT - Manage users
12. ADMIN_ENTITLEMENT - Manage entitlements

### Roles
1. Account Viewer - Can view account information
2. Payment Initiator - Can initiate payments
3. Payment Approver - Can approve payments
4. Deposit Manager - Can manage deposit accounts
5. Loan Officer - Can manage loan applications
6. System Administrator - Can manage system settings

### Approval Groups
1. Toyota NA Payment Approvers - Group for Toyota North America payment approvers
2. Toyota Japan Payment Approvers - Group for Toyota Japan payment approvers
3. GM NA Payment Approvers - Group for GM North America payment approvers
4. Sony Electronics Payment Approvers - Group for Sony Electronics payment approvers

### Approval Workflows
1. Toyota NA Wire Transfer Approval - Requires 2 approvers for amounts over $50,000
2. Toyota Japan Wire Transfer Approval - Requires 2 approvers for amounts over ¥5,000,000
3. GM NA ACH Payment Approval - Requires 1 approver for amounts up to $25,000, 2 approvers for higher amounts
4. Sony Electronics Payment Approval - Requires 2 approvers for all payments
