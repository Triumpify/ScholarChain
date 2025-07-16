# ScholarChain Smart Contract - Learning Token Framework

A Stacks blockchain smart contract that implements a learning token system for educational platforms, enabling users to earn, transfer, and redeem tokens for educational activities.

## Overview

ScholarChain is a decentralized learning token framework that allows educational institutions and platforms to create token-based incentive systems. Users can register with their academic credentials, earn tokens through learning activities, and transfer tokens to other registered users.

## Features

- **User Registration**: Register with name and student ID
- **Token Management**: Mint, transfer, and redeem learning tokens
- **Fee System**: Configurable transaction fees (default 1.5%)
- **Access Control**: Admin and authorized user roles
- **Session Locking**: Emergency pause functionality
- **STX Integration**: Token transfers backed by STX transactions

## Contract Functions

### Public Functions

#### User Management
- `reg(nm, sid)` - Register a new user with name and student ID
- `info(acct)` - View user registration information
- `bal(acct)` - Check token balance for an account

#### Token Operations
- `mint(amt)` - Mint new tokens to caller's account
- `course-xfer(to, amt)` - Transfer tokens to another registered user (with fees)
- `redeem(amt)` - Redeem tokens for STX

#### Configuration (Admin Only)
- `set-rate(r)` - Set the token exchange rate (authorized users only)
- `lock-toggle(v)` - Toggle session lock on/off (admin only)
- `chg-fee(v)` - Change transaction fee percentage (admin only)

#### Authorization Management (Admin Only)
- `add-auth(a)` - Add authorized user for rate setting
- `revoke-auth(a)` - Remove authorized user privileges

### Read-Only Functions
- `rate()` - Get current exchange rate
- `is-auth(addr)` - Check if address is authorized
- `lock-status()` - Check if sessions are locked

## Error Codes

| Code | Error | Description |
|------|-------|-------------|
| 100 | e401 | Admin access required |
| 101 | e402 | User not registered |
| 102 | e403 | Insufficient balance |
| 103 | e404 | Invalid amount |
| 104 | e405 | Reserved |
| 105 | e406 | Authorization required |
| 106 | e407 | Invalid rate |
| 107 | e408 | User already registered |
| 108 | e409 | Invalid input parameters |
| 109 | e410 | Session locked |

## Usage Examples

### User Registration
```clarity
;; Register a new user
(contract-call? .scholarchain reg "John Doe" "STU123456")
```

### Token Operations
```clarity
;; Mint tokens
(contract-call? .scholarchain mint u1000)

;; Transfer tokens to another user
(contract-call? .scholarchain course-xfer 'SP2...RECIPIENT u100)

;; Redeem tokens for STX
(contract-call? .scholarchain redeem u50)
```

### Admin Operations
```clarity
;; Set exchange rate (authorized users only)
(contract-call? .scholarchain set-rate u150000000)

;; Change fee to 2% (admin only)
(contract-call? .scholarchain chg-fee u200)

;; Add authorized user (admin only)
(contract-call? .scholarchain add-auth 'SP2...NEWAUTH)
```

## Configuration

### Default Settings
- **Fee Rate**: 150 basis points (1.5%)
- **Exchange Rate**: 0 (must be set by authorized user)
- **Session Lock**: false (unlocked)

### Limits
- **Name Length**: 1-55 ASCII characters
- **Student ID Length**: 1-22 ASCII characters
- **Maximum Fee**: 10,000 basis points (100%)

## Security Features

1. **Access Control**: Admin-only functions for critical operations
2. **Input Validation**: Strict validation on all user inputs
3. **Balance Checks**: Prevents overdraft scenarios
4. **Registration Checks**: Ensures users are registered before token operations
5. **Emergency Lock**: Admin can pause all transfers if needed

## Fee Structure

The contract implements a fee system for token transfers:
- Fees are calculated as: `(amount × fee_bps) / 10000`
- Default fee is 150 basis points (1.5%)
- Fees are paid in STX and sent to the admin address
- Fee rates can be adjusted by admin (0-100% range)

## Deployment

1. Deploy the contract to Stacks blockchain
2. Set initial exchange rate using `set-rate()`
3. Add authorized users for rate management with `add-auth()`
4. Configure fee structure if needed with `chg-fee()`

## Integration

Educational platforms can integrate ScholarChain by:
1. Registering students through the `reg()` function
2. Minting tokens as rewards for completed courses/activities
3. Allowing peer-to-peer transfers for collaborative learning
4. Implementing redemption systems for real-world benefits
