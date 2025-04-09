# Cash Management Entitlement System

A comprehensive database design for a banking cash management entitlement system with hierarchical permissions and approval workflows.

## Overview

This project provides a complete PostgreSQL database design for a Cash Management Entitlement System that allows banks to offer cash management services to their clients with granular permission control. The system implements a hierarchical permission model where permissions can be defined at multiple organizational levels (bank, region, client group, client entity, user group, user) and can be scoped to different levels (global, product category, product, service, account).

## Key Features

- **Multi-level Organizational Hierarchy**: Bank → Region → Client Group → Client Entity → User Group → User
- **Product and Service Categorization**: Product Categories → Products → Services
- **Flexible Permission Model**: Permissions can be defined at any level and inherited downward
- **Permission Override Capability**: Lower levels can override permissions from higher levels
- **Approval Workflows**: Support for multi-level approval processes with amount-based thresholds
- **Delegation**: Temporary permission delegation for vacation coverage or special circumstances
- **Audit Trail**: Comprehensive logging of all permission changes and access attempts

## Repository Contents

- `schema.sql`: Complete database schema with tables, constraints, and views
- `example_data.sql`: Example data with INSERT statements for all entities
- `entity_analysis.md`: Analysis of core entities and their relationships
- `entity_relationships.md`: Detailed entity relationship diagram and explanations
- `permission_hierarchy.md`: Implementation details of the permission hierarchy
- `documentation.md`: Comprehensive system documentation with usage examples
- `example_data_structure.md`: Overview of the example data scenario

## Database Schema

The database schema includes the following key components:

### Organizational Structure
- Banks
- Regions
- Client Groups
- Client Entities
- User Groups
- Users

### Product Structure
- Product Categories
- Products
- Services
- Accounts

### Permission Structure
- Permissions
- Roles
- Entitlements
- Approval Limits
- Approval Workflows
- Approval Groups

### Support Features
- Delegations
- Audit Logs

## Implementation

To implement this system:

1. Create a PostgreSQL database
2. Execute the `schema.sql` script to create all tables and views
3. Execute the `example_data.sql` script to populate with example data (optional)
4. Refer to the documentation for usage examples and best practices

## Example Scenarios

The example data includes several scenarios that demonstrate the system's capabilities:

1. **Toyota Corporation**: A global client with entities in North America, Europe, and Japan
2. **General Motors**: A client with entities in North America and Europe
3. **Sony Corporation**: A client with Electronics and Pictures divisions

Each scenario includes users with different roles and permissions, demonstrating the hierarchical permission model and approval workflows.

## Permission Hierarchy

The system implements a hierarchical permission model where permissions flow from higher organizational levels to lower levels:

1. Bank Level
2. Region Level
3. Product Level
4. Client Group Level
5. Client Entity Level
6. Account Level
7. User Group Level
8. User Level

Permissions defined at a higher level can be overridden at lower levels, and explicit denials take precedence over grants at any level.

## Usage Examples

The documentation includes detailed examples for:

1. Setting up a new client
2. Granting permissions at different levels
3. Setting up approval workflows
4. Setting approval limits
5. Temporary permission delegation
6. Permission override scenarios

## Best Practices

1. Assign permissions at the highest appropriate level to minimize maintenance
2. Use explicit denials sparingly and only when necessary
3. Set appropriate approval thresholds based on risk assessment
4. Regularly review audit logs and user permissions
5. Implement a formal user onboarding and offboarding process

## License

This project is provided as a reference implementation and can be freely used and modified for your specific requirements.

## Contact

For questions or customization requests, please contact the author.
