# 🚀 Crowdfunding Platform - Complete Database Management System
A comprehensive, secure, and production-ready crowdfunding platform database system with automatic platform fee deduction, intelligent visit tracking, and immutable financial audit trails.

---

## 📋 Table of Contents

- [Features](#-features)
- [Database Schema](#-database-schema)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Core Functionality](#-core-functionality)
- [Security Features](#-security-features)
- [API Reference](#-api-reference)
- [Usage Examples](#-usage-examples)
- [Triggers & Automation](#-triggers--automation)
- [Views & Reports](#-views--reports)
- [Best Practices](#-best-practices)
- [Troubleshooting](#-troubleshooting)

---

## ✨ Features

### 🎯 Core Features
- ✅ **Automatic 1% Platform Fee** - Platform fee automatically deducted from every donation
- ✅ **Auto-Payroll Generation** - Administrator payouts (99% of donation) created instantly
- ✅ **Smart Visit Tracking** - Donor engagement monitored with interest level calculation
- ✅ **Immutable Transactions** - Financial records cannot be modified or deleted
- ✅ **Goal Tracking** - Real-time fundraiser progress with automatic completion
- ✅ **Safe Deletion** - Fundraisers can be deleted while preserving administrators and audit trails

### 🔐 Security Features
- 🔒 Transaction records are **permanent and immutable**
- 🔒 Payroll entries are **system-generated only**
- 🔒 Visit logs are **audit-protected**
- 🔒 All database constraints enforced via **triggers**
- 🔒 Foreign key relationships with **cascade protection**

### 📊 Analytics & Reporting
- 📈 Donor engagement tracking with interest levels
- 📈 Administrator earnings dashboard
- 📈 Fundraiser performance metrics
- 📈 Platform-wide statistics with fee collection tracking
- 📈 Complete audit trail for all activities

---

## 🗂️ Database Schema

### Core Tables

| Table | Purpose | Key Features |
|-------|---------|--------------|
| **Administrator** | Platform admins managing fundraisers | Total earnings tracking (99% of donations) |
| **Donor** | Users making donations | Total donation tracking |
| **Fundraiser** | Campaigns raising funds | Goal, raised, and remaining amounts |
| **Transactions** | Donation records | Immutable, auto-platform fee calculation |
| **Payroll** | Admin payouts | Auto-generated per transaction (99% of donation) |
| **Visits** | Donor engagement tracking | Interest level auto-updates |

### Key Relationships
```
Administrator (1) ──── (N) Fundraiser
Fundraiser (1) ──── (N) Transactions
Fundraiser (1) ──── (N) Visits
Donor (1) ──── (N) Transactions
Donor (1) ──── (N) Visits
Administrator (1) ──── (N) Payroll
```

---

## 📥 Installation

### Prerequisites
- MySQL 8.0 or higher
- Database client (MySQL Workbench, phpMyAdmin, or CLI)
- Appropriate database permissions (CREATE, INSERT, UPDATE, DELETE, TRIGGER)

### Installation Steps

1. **Clone or Download the SQL File**
```bash
git clone https://github.com/yourusername/crowdfunding-db.git
cd crowdfunding-db
```

2. **Create and Setup Database**
```bash
mysql -u root -p < DBMS_MP.sql
```

Or using MySQL Workbench:
- Open MySQL Workbench
- File → Open SQL Script → Select `DBMS_MP.sql`
- Execute the script (⚡ Lightning bolt icon)

3. **Verify Installation**
```sql
USE CrowdfundingDB;
SHOW TABLES;
SHOW PROCEDURE STATUS WHERE Db = 'CrowdfundingDB';
SHOW TRIGGERS;
```

Expected output: 6 tables, 20+ procedures, 12 triggers

---

## 🚀 Quick Start

### 1. Add an Administrator
```sql
CALL AddAdministrator('John Doe', 'john@crowdfund.com');
-- Returns: Admin_id = 1
```

### 2. Add a Donor
```sql
CALL AddDonor('Jane Smith', 'jane@email.com', '9876543210');
-- Returns: Donor_id = 1
```

### 3. Create a Fundraiser
```sql
CALL AddFundraiser(
    1,                          -- Admin_id
    'HDFC-1234',               -- Bank details
    'Medical Emergency Fund',   -- Title
    'Help save lives',         -- Description
    100000,                    -- Goal amount (₹1,00,000)
    '2025-12-31',              -- Deadline
    'Active',                  -- Status
    'Dr. Smith'                -- Owner name
);
-- Returns: Fundraiser_no = 1
```

### 4. Record a Visit (Donor views fundraiser)
```sql
CALL RecordFundraiserVisit(1, 1, 15);
-- donor_id=1, fundraiser_no=1, duration=15 minutes
-- Returns: Total_Visits=1, Interest_Level='Low'
```

### 4. Process a Donation
```sql
CALL ProcessDonation(1, 1, 5000.00, 'UPI');
-- Donor donates: ₹5,000
-- Platform fee (1%): ₹50 (kept by platform)
-- To fundraiser: ₹4,950
-- Admin receives: ₹4,950 (via payroll)
-- Returns: Transaction details with breakdown
```

---

## 🎯 Core Functionality

### Platform Fee & Payroll Flow

```
Donor donates ₹5,000
        ↓
Platform deducts 1% fee (₹50) → Platform Revenue
        ↓
Net amount: ₹4,950 → Goes to Fundraiser
        ↓
Payroll entry auto-created → Admin receives ₹4,950
        ↓
Admin's total_earnings updated with ₹4,950
```

**Key Points:**
- **Platform Fee (1%)**: Kept by the platform, NOT given to admin
- **Admin Receives (99%)**: The net amount after platform fee deduction
- **Fundraiser Gets**: Net amount (99% of donation)
- **Platform Revenue**: Accumulates from all 1% fees

### Interest Level System

The platform automatically tracks donor engagement:

| Visits | Interest Level | Color | Description |
|--------|---------------|-------|-------------|
| 1-2 | **Low** | 🟢 Gray | Exploring |
| 3-4 | **Medium** | 🟡 Yellow | Growing interest |
| 5-9 | **High** | 🟠 Orange | Strong interest |
| 10+ | **Very High** | 🔴 Red | Ready to donate |

---

## 🔐 Security Features

### Immutable Records

**Transactions** - Cannot be modified or deleted
```sql
-- ❌ THIS WILL FAIL
DELETE FROM Transactions WHERE Transaction_id = 1;
-- Error: Transactions cannot be deleted. They are permanent financial audit records.

-- ❌ THIS WILL FAIL
UPDATE Transactions SET amount = 10000 WHERE Transaction_id = 1;
-- Error: Transactions cannot be modified.
```

**Payroll** - System-generated only
```sql
-- ❌ THIS WILL FAIL
INSERT INTO Payroll (Admin_id, fundraiser_no, amount_released) 
VALUES (1, 1, 5000);
-- Error: Payroll entries are automatically created by the system.
```

---

## 📚 API Reference

### Administrator Procedures

#### `AddAdministrator(name, email)`
Creates a new administrator account.
```sql
CALL AddAdministrator('John Doe', 'john@cf.com');
```

#### `UpdateAdministrator(Admin_id, new_name, new_email)`
Updates administrator details.
```sql
CALL UpdateAdministrator(1, 'John Smith', 'johnsmith@cf.com');
```

#### `DeleteAdministrator(Admin_id)`
Deletes administrator (only if no active fundraisers).
```sql
CALL DeleteAdministrator(3);
```

#### `GetAdministratorEarnings(Admin_id)`
Retrieves complete earnings report.
```sql
CALL GetAdministratorEarnings(1);
```

---

### Donor Procedures

#### `AddDonor(name, email, phone)`
Registers a new donor.
```sql
CALL AddDonor('Jane Smith', 'jane@email.com', '9876543210');
```

#### `UpdateDonor(donor_id, new_name, new_email, new_phone)`
Updates donor information.
```sql
CALL UpdateDonor(1, 'Jane Doe', 'janedoe@email.com', '9876543210');
```

#### `DeleteDonor(donor_id)`
Removes donor (only if no transactions exist).
```sql
CALL DeleteDonor(5);
```

#### `GetDonorHistory(donor_id)`
Retrieves all donations made by donor.
```sql
CALL GetDonorHistory(1);
```

#### `GetDonorInterestAnalytics(donor_id)`
Shows donor's interest levels across fundraisers.
```sql
CALL GetDonorInterestAnalytics(1);
```

---

### Fundraiser Procedures

#### `AddFundraiser(admin_id, bank_details, title, description, goal_amount, deadline, status, owner_name)`
Creates a new fundraising campaign.
```sql
CALL AddFundraiser(
    1, 
    'HDFC-1234', 
    'Tech Fest 2025', 
    'University tech festival', 
    200000, 
    '2025-12-15', 
    'Active', 
    'Student Council'
);
```

#### `UpdateFundraiser(fundraiser_no, title, description, goal_amount, deadline, status, owner_name)`
Updates fundraiser details.
```sql
CALL UpdateFundraiser(
    1, 
    'Tech Fest 2025 - Extended', 
    'Extended description', 
    250000, 
    '2025-12-31', 
    'Active', 
    'Student Council'
);
```

#### `DeleteFundraiser(fundraiser_no)`
Safely deletes fundraiser (soft delete if has transactions).
```sql
CALL DeleteFundraiser(3);
-- If has transactions: Soft delete (preserves data)
-- If no transactions: Hard delete (permanent removal)
```

#### `GetFundraiserSummary(fundraiser_no)`
Retrieves comprehensive fundraiser statistics.
```sql
CALL GetFundraiserSummary(1);
```

---

### Visit Tracking Procedures

#### `RecordFundraiserVisit(donor_id, fundraiser_no, duration)` ⭐
Records donor visit and auto-updates interest level.
```sql
CALL RecordFundraiserVisit(1, 1, 15);
-- Returns: Total_Visits, Current_Interest_Level, Interest_Status
```

**Important:** This should be called every time a donor views a fundraiser page!

#### `ViewVisitHistory(fundraiser_no)`
Shows all visits to a fundraiser.
```sql
CALL ViewVisitHistory(1);
```

#### `ViewDonorVisits(donor_id)`
Shows all fundraisers visited by a donor.
```sql
CALL ViewDonorVisits(1);
```

---

### Transaction Procedures

#### `ProcessDonation(donor_id, fundraiser_no, amount, payment_mode)` ⭐⭐⭐
**THE MAIN PROCEDURE** - Processes complete donation flow.

```sql
CALL ProcessDonation(1, 1, 5000.00, 'UPI');
```

**What it does automatically:**
1. ✅ Validates donor and fundraiser exist
2. ✅ Checks fundraiser is active
3. ✅ Validates amount doesn't exceed remaining goal
4. ✅ Calculates 1% platform fee (₹50 from ₹5,000)
5. ✅ Calculates net amount to fundraiser (₹4,950)
6. ✅ Creates transaction record
7. ✅ Updates fundraiser raised_amount with net amount (₹4,950)
8. ✅ Updates donor total_donated with gross amount (₹5,000)
9. ✅ Creates payroll entry for administrator (₹4,950)
10. ✅ Updates administrator total_earnings (NOT commission)
11. ✅ Records visit with type "Transaction"
12. ✅ Updates interest level for all donor's visits

**Returns:**
```json
{
  "Message": "Donation processed successfully!",
  "Transaction_id": 15,
  "Gross_Amount": 5000.00,
  "Platform_Fee_1_Percent": 50.00,
  "Net_To_Fundraiser": 4950.00,
  "Admin_Receives": 4950.00,
  "Donor_Interest_Level": "High",
  "Total_Visits_To_Fundraiser": 6
}
```

#### `ViewTransactionDetails(transaction_id)`
Retrieves complete transaction information with payroll link.
```sql
CALL ViewTransactionDetails(1);
```

---

### Reporting Procedures

#### `GetPlatformStatistics()`
Platform-wide statistics.
```sql
CALL GetPlatformStatistics();
```

#### `ViewAuditTrail(fundraiser_no)`
Complete audit trail for a fundraiser.
```sql
CALL ViewAuditTrail(1);
```

---

## 💡 Usage Examples

### Example 1: Complete Donation Flow with Platform Fee

```sql
-- Donor makes donation
CALL ProcessDonation(1, 1, 10000.00, 'Credit Card');

-- BREAKDOWN:
-- Gross donation: ₹10,000 (what donor pays)
-- Platform fee (1%): ₹100 (platform revenue)
-- Net to fundraiser: ₹9,900 (fundraiser receives)
-- Admin payout: ₹9,900 (what admin gets via payroll)

-- Platform keeps: ₹100
-- Admin receives: ₹9,900
-- Fundraiser balance increases: ₹9,900
```

### Example 2: Multiple Donors, Platform Fee Tracking

```sql
-- Fundraiser needs ₹50,000
CALL AddFundraiser(1, 'SBI-5678', 'Education Fund', 
    'Books for children', 50000, '2025-12-31', 'Active', 'NGO');

-- Donor 1: ₹20,000
CALL ProcessDonation(1, 2, 20000, 'UPI');
-- Platform fee: ₹200
-- To fundraiser: ₹19,800
-- Admin receives: ₹19,800

-- Donor 2: ₹15,000
CALL ProcessDonation(2, 2, 15000, 'Debit Card');
-- Platform fee: ₹150
-- To fundraiser: ₹14,850
-- Admin receives: ₹14,850

-- Total platform revenue: ₹350 (₹200 + ₹150)
-- Total admin earnings: ₹34,650 (₹19,800 + ₹14,850)
```

---

## ⚡ Triggers & Automation

### Transaction Triggers

| Trigger | When | Action |
|---------|------|--------|
| `trg_before_transaction_insert` | Before INSERT | Validates fundraiser status, calculates platform fee |
| `trg_after_transaction_insert` | After INSERT | Updates amounts, creates payroll, updates totals |
| `trg_before_transaction_delete` | Before DELETE | **BLOCKS** - Transactions are immutable |
| `trg_before_transaction_update` | Before UPDATE | **BLOCKS** - Transactions are immutable |

### Fundraiser Triggers

| Trigger | When | Action |
|---------|------|--------|
| `trg_before_fundraiser_insert` | Before INSERT | Initializes amounts, validates goal and deadline |
| `trg_check_goal_reached` | After UPDATE | Auto-changes status to "Goal Reached" |

### Payroll Triggers

| Trigger | When | Action |
|---------|------|--------|
| `trg_before_payroll_manual_insert` | Before INSERT | **BLOCKS** manual entries (system-only) |
| `trg_before_payroll_delete` | Before DELETE | **BLOCKS** - Payroll is immutable |
| `trg_before_payroll_update` | Before UPDATE | **BLOCKS** - Payroll is immutable |

### Visit Triggers

| Trigger | When | Action |
|---------|------|--------|
| `trg_before_visit_insert` | Before INSERT | Validates duration is positive |
| `trg_before_visit_delete` | Before DELETE | **BLOCKS** - Visits are audit records |
| `trg_before_visit_update` | Before UPDATE | Allows only interest_level updates |

---

## 📊 Views & Reports

### Available Views

#### `vw_active_fundraisers`
Shows all active fundraisers with statistics.
```sql
SELECT * FROM vw_active_fundraisers;
```

#### `vw_transaction_summary`
Complete transaction history with platform fee breakdown.
```sql
SELECT * FROM vw_transaction_summary;
```

#### `vw_donor_engagement`
Donor activity metrics and engagement levels.
```sql
SELECT * FROM vw_donor_engagement;
```

#### `vw_administrator_dashboard`
Administrator performance and earnings.
```sql
SELECT * FROM vw_administrator_dashboard;
```

#### `vw_high_interest_donors`
Identifies donors with 5+ visits (ready to donate).
```sql
SELECT * FROM vw_high_interest_donors;
```

---

## 🎓 Best Practices

### ✅ DO's

1. **Always use `ProcessDonation()`** for creating transactions
   ```sql
   -- ✅ CORRECT - Automatically handles platform fee and payroll
   CALL ProcessDonation(1, 1, 5000, 'UPI');
   ```

2. **Understand the fee structure**
   ```
   Donation = 100%
   Platform Fee = 1% (platform revenue)
   Admin Receives = 99% (via payroll)
   Fundraiser Gets = 99% (net amount)
   ```

3. **Track platform revenue separately**
   ```sql
   -- Query total platform fees collected
   SELECT SUM(platform_fee) as total_platform_revenue 
   FROM Transactions;
   ```

### ❌ DON'Ts

1. **Don't confuse platform fee with admin commission**
   ```
   ❌ WRONG: "Admin gets 1% commission"
   ✅ CORRECT: "Platform deducts 1% fee; Admin receives remaining 99%"
   ```

2. **Don't try to give platform fee to admin**
   ```sql
   -- ❌ WRONG - Platform fee is NOT admin's money
   -- Admin automatically receives the 99% net amount via payroll
   ```

---

## 🔧 Troubleshooting

### Common Misunderstandings

#### "Where does the 1% go?"
**Answer:** The 1% platform fee is the platform's revenue. It's NOT given to the administrator. The admin receives the remaining 99% as payment for managing the fundraiser.

#### "What does admin receive?"
**Answer:** Admin receives 99% of each donation (the net amount after platform fee). This is automatically recorded in the Payroll table.

#### "How is platform revenue calculated?"
**Answer:** Sum of all `platform_fee` values in Transactions table:
```sql
SELECT SUM(platform_fee) as platform_revenue FROM Transactions;
```

### Common Errors and Solutions

#### Error: "Donation exceeds the remaining goal amount!"
**Cause:** Trying to donate more than fundraiser needs.
**Solution:** Check remaining_amount before processing donation.
```sql
SELECT remaining_amount FROM Fundraiser WHERE fundraiser_no = 1;
-- Donate amount <= remaining_amount
```

#### Error: "Fundraiser is not active. Cannot accept donations."
**Cause:** Fundraiser status is not 'Active' (e.g., 'Planned', 'Deleted', 'Goal Reached').
**Solution:** Change status to 'Active' or choose different fundraiser.
```sql
UPDATE Fundraiser SET status = 'Active' WHERE fundraiser_no = 1;
```

#### Error: "Transactions cannot be deleted. They are permanent financial audit records."
**Cause:** Attempting to delete a transaction.
**Solution:** Transactions are immutable by design. This is a security feature, not a bug. If you need to reverse a transaction, contact system administrator.

#### Error: "Payroll entries are automatically created by the system."
**Cause:** Trying to manually insert into Payroll table.
**Solution:** Payroll is auto-created when donations are processed. Use `ProcessDonation()` instead.

#### Error: "Donor does not exist" or "Fundraiser does not exist"
**Cause:** Invalid IDs provided to procedures.
**Solution:** Verify IDs exist before calling procedures.
```sql
SELECT * FROM Donor WHERE donor_id = 1;
SELECT * FROM Fundraiser WHERE fundraiser_no = 1;
```

---

## 💼 Use Cases

This database system is perfect for:

- 🏥 Healthcare crowdfunding platforms
- 🎓 Educational fundraising portals
- 🌱 Social cause campaigns
- 🚀 Startup equity crowdfunding
- 🎨 Creative project funding
- 🏘️ Community development initiatives

**Platform Revenue Model:**
- Platform earns 1% from every successful donation
- Administrators earn 99% as service fee for managing fundraisers
- Transparent, automated fee distribution
- Complete audit trail for all transactions

---

## 📝 Version History

### Version 3.0.0 (Current) - Platform Fee Model
- ✨ **CORRECTED**: 1% is platform fee (platform revenue), NOT admin commission
- ✨ **CLARIFIED**: Admins receive 99% of donations as earnings
- ✨ Updated all documentation to reflect correct fee structure
- ✨ Renamed `admin_commission` to `platform_fee` in displays
- ✨ Added platform revenue tracking capabilities
- 🔒 Maintained immutable transactions and audit compliance

### Version 2.0.0
- ✨ Added automatic 1% platform fee calculation
- ✨ Implemented auto-payroll generation via triggers
- ✨ Added intelligent visit tracking with interest levels

### Version 1.0.0
- 🎉 Initial release with basic CRUD operations

---

## 🎯 Financial Model Summary

### Every Donation Breakdown:
```
Example: ₹10,000 donation

├─ Platform Fee (1%): ₹100 → Platform Revenue
└─ Net Amount (99%): ₹9,900 → Split as:
   ├─ To Fundraiser: ₹9,900 (increases raised_amount)
   └─ To Admin: ₹9,900 (payroll entry created)
```

**Important Notes:**
- Platform fee is SEPARATE from admin earnings
- Admin earns money by managing fundraisers (receives 99%)
- Platform earns money through 1% fee on all donations
- All calculations are automatic and transparent
- Complete audit trail for regulatory compliance

---

**Built with transparency, security, and scalability in mind.**
