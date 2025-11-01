# 🚀 Crowdfunding Platform - Complete Database Management System
A comprehensive, secure, and production-ready crowdfunding platform database system with automatic commission handling, intelligent visit tracking, and immutable financial audit trails.

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
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

### 🎯 Core Features
- ✅ **Automatic 1% Commission** - Platform fee automatically deducted from every donation
- ✅ **Auto-Payroll Generation** - Administrator payouts created instantly on donation
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
- 📈 Platform-wide statistics
- 📈 Complete audit trail for all activities

---

## 🗂️ Database Schema

### Core Tables

| Table | Purpose | Key Features |
|-------|---------|--------------|
| **Administrator** | Platform admins managing fundraisers | Commission tracking |
| **Donor** | Users making donations | Total donation tracking |
| **Fundraiser** | Campaigns raising funds | Goal, raised, and remaining amounts |
| **Transactions** | Donation records | Immutable, auto-commission calculation |
| **Payroll** | Admin payouts | Auto-generated per transaction |
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

### 5. Process a Donation
```sql
CALL ProcessDonation(1, 1, 5000.00, 'UPI');
-- Donates ₹5,000 to fundraiser
-- Auto-deducts ₹50 commission (1%)
-- Credits ₹4,950 to fundraiser
-- Creates payroll entry for admin
-- Records visit automatically
-- Returns: Transaction details with commission breakdown
```

---

## 🎯 Core Functionality

### Interest Level System

The platform automatically tracks donor engagement and calculates interest levels:

| Visits | Interest Level | Color | Description |
|--------|---------------|-------|-------------|
| 1-2 | **Low** | 🟢 Gray | Exploring |
| 3-4 | **Medium** | 🟡 Yellow | Growing interest |
| 5-9 | **High** | 🟠 Orange | Strong interest |
| 10+ | **Very High** | 🔴 Red | Ready to donate |

**How it works:**
1. Every time a donor views a fundraiser, a visit is recorded
2. The system counts total visits from that donor to that fundraiser
3. Interest level is calculated and **ALL previous visits are updated**
4. When donation occurs, interest level automatically increases

### Commission & Payroll Flow

```
Donor donates ₹5,000
        ↓
Platform deducts 1% (₹50)
        ↓
Fundraiser receives ₹4,950
        ↓
Payroll entry auto-created for Admin (₹50)
        ↓
Admin total_commission updated
```

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

**Visits** - Audit-protected
```sql
-- ❌ THIS WILL FAIL
DELETE FROM Visits WHERE visit_id = 1;
-- Error: Visits cannot be deleted. They are audit records.
```

### Data Validation

✅ Prevents donations exceeding fundraiser goal
✅ Blocks donations to inactive fundraisers
✅ Validates positive amounts only
✅ Ensures future deadlines
✅ Maintains referential integrity

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
4. ✅ Calculates 1% commission (₹50 from ₹5,000)
5. ✅ Calculates net amount (₹4,950)
6. ✅ Creates transaction record
7. ✅ Updates fundraiser raised_amount and remaining_amount
8. ✅ Updates donor total_donated
9. ✅ Creates payroll entry for administrator
10. ✅ Updates administrator total_commission
11. ✅ Records visit with type "Transaction"
12. ✅ Updates interest level for all donor's visits
13. ✅ Returns complete transaction summary

**Returns:**
```json
{
  "Message": "Donation processed successfully!",
  "Transaction_id": 15,
  "Gross_Amount": 5000.00,
  "Commission_1_Percent": 50.00,
  "Net_To_Fundraiser": 4950.00,
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

### Example 1: Complete Donation Flow

```sql
-- Step 1: Donor visits fundraiser 5 times (interest level increases)
CALL RecordFundraiserVisit(1, 1, 10);  -- Visit 1: Low
CALL RecordFundraiserVisit(1, 1, 15);  -- Visit 2: Low
CALL RecordFundraiserVisit(1, 1, 12);  -- Visit 3: Medium
CALL RecordFundraiserVisit(1, 1, 8);   -- Visit 4: Medium
CALL RecordFundraiserVisit(1, 1, 20);  -- Visit 5: High ✓

-- Step 2: Check donor's interest
CALL GetDonorInterestAnalytics(1);
-- Shows: Interest_Level = "High", Total_Visits = 5

-- Step 3: Process donation
CALL ProcessDonation(1, 1, 10000.00, 'Credit Card');
-- Gross: ₹10,000
-- Commission: ₹100 (1%)
-- Net to fundraiser: ₹9,900
-- Admin receives ₹100 in payroll
-- Visit recorded with type "Transaction"
-- Interest level updated across all visits

-- Step 4: View results
CALL GetFundraiserSummary(1);
-- Shows raised_amount increased by ₹9,900
-- Shows remaining_amount decreased by ₹9,900

CALL GetAdministratorEarnings(1);
-- Shows total_commission increased by ₹100
-- Shows new payroll entry
```

---

### Example 2: Multiple Donors, Single Fundraiser

```sql
-- Fundraiser needs ₹50,000
CALL AddFundraiser(1, 'SBI-5678', 'Education Fund', 
    'Books for children', 50000, '2025-12-31', 'Active', 'NGO');

-- Donor 1 contributes ₹20,000
CALL ProcessDonation(1, 2, 20000, 'UPI');
-- Net to fundraiser: ₹19,800 (₹200 commission)
-- Remaining: ₹30,200

-- Donor 2 contributes ₹15,000
CALL ProcessDonation(2, 2, 15000, 'Debit Card');
-- Net to fundraiser: ₹14,850 (₹150 commission)
-- Remaining: ₹15,350

-- Donor 3 completes the goal
CALL ProcessDonation(3, 2, 15500, 'Net Banking');
-- Net to fundraiser: ₹15,345 (₹155 commission)
-- Remaining: ₹5
-- Status automatically changes to "Goal Reached" via trigger!

-- Check final status
CALL GetFundraiserSummary(2);
-- Shows: Status = "Goal Reached", Completion = 99.99%
```

---

### Example 3: Donor Engagement Journey

```sql
-- Day 1: Donor discovers fundraiser
CALL RecordFundraiserVisit(5, 1, 5);
-- Interest: Low (1 visit)

-- Day 2: Returns to learn more
CALL RecordFundraiserVisit(5, 1, 12);
-- Interest: Low (2 visits)

-- Day 3: Spends more time
CALL RecordFundraiserVisit(5, 1, 20);
-- Interest: Medium (3 visits) ← Level increased!

-- Day 4: Very engaged
CALL RecordFundraiserVisit(5, 1, 25);
-- Interest: Medium (4 visits)

-- Day 5: Ready to donate
CALL RecordFundraiserVisit(5, 1, 30);
-- Interest: High (5 visits) ← Level increased!

-- Day 6: Makes donation
CALL ProcessDonation(5, 1, 5000, 'UPI');
-- Interest: High (6 visits, including transaction visit)
-- All 6 visits now marked as "High" interest

-- Check engagement
CALL GetDonorInterestAnalytics(5);
-- Shows progression from Low → Medium → High
```

---

## ⚡ Triggers & Automation

### Transaction Triggers

| Trigger | When | Action |
|---------|------|--------|
| `trg_before_transaction_insert` | Before INSERT | Validates fundraiser status, calculates commission |
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
Complete transaction history with commission breakdown.
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
   -- ✅ CORRECT
   CALL ProcessDonation(1, 1, 5000, 'UPI');
   ```

2. **Record visits on every fundraiser page view**
   ```sql
   -- ✅ CORRECT - Call this when user opens fundraiser details
   CALL RecordFundraiserVisit(donor_id, fundraiser_id, time_spent_in_minutes);
   ```

3. **Use views for reporting** instead of complex queries
   ```sql
   -- ✅ CORRECT
   SELECT * FROM vw_active_fundraisers WHERE days_remaining < 30;
   ```

4. **Check remaining_amount** before donations
   ```sql
   -- ✅ CORRECT
   SELECT remaining_amount FROM Fundraiser WHERE fundraiser_no = 1;
   -- Then validate donation amount <= remaining_amount
   ```

5. **Use procedures for all CRUD operations**
   ```sql
   -- ✅ CORRECT
   CALL AddDonor('Name', 'email@example.com', 'phone');
   ```

### ❌ DON'Ts

1. **Never insert transactions directly**
   ```sql
   -- ❌ WRONG - Bypasses commission calculation
   INSERT INTO Transactions VALUES (...);
   ```

2. **Never try to delete/update transactions**
   ```sql
   -- ❌ WRONG - Will be blocked by trigger
   DELETE FROM Transactions WHERE Transaction_id = 1;
   UPDATE Transactions SET amount = 10000 WHERE Transaction_id = 1;
   ```

3. **Never manually create payroll entries**
   ```sql
   -- ❌ WRONG - Payroll is auto-generated
   INSERT INTO Payroll VALUES (...);
   ```

4. **Don't delete donors/fundraisers with transactions**
   ```sql
   -- ❌ WRONG - Will fail due to referential integrity
   DELETE FROM Donor WHERE donor_id = 1;  -- If has transactions
   -- ✅ CORRECT - Use soft delete for fundraisers
   CALL SoftDeleteFundraiser(1);
   ```

5. **Don't forget to record visits**
   ```sql
   -- ❌ WRONG - Missing engagement tracking
   -- User views fundraiser but no visit recorded
   
   -- ✅ CORRECT
   CALL RecordFundraiserVisit(donor_id, fundraiser_id, duration);
   ```

---

## 🔧 Troubleshooting

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

## 🤝 Contributing

We welcome contributions! Here's how:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Test your changes thoroughly
4. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
5. Push to the branch (`git push origin feature/AmazingFeature`)
6. Open a Pull Request

## 🙏 Acknowledgments

- Developed as a comprehensive database management system project
- Built with MySQL 8.0+ for maximum compatibility
- Designed with security and audit compliance as top priorities
- Inspired by real-world crowdfunding platforms

---

## 📝 Version History

### Version 2.0.0 (Current)
- ✨ Added automatic 1% commission calculation
- ✨ Implemented auto-payroll generation via triggers
- ✨ Added intelligent visit tracking with interest levels
- ✨ Made transactions immutable for audit compliance
- ✨ Enhanced security with comprehensive trigger system
- ✨ Added 20+ stored procedures
- ✨ Created 5 analytical views
- 🔒 Implemented complete audit trail

### Version 1.0.0
- 🎉 Initial release with basic CRUD operations
- Basic transaction handling
- Simple fundraiser management

---

## 🎯 Roadmap

- [ ] Multi-currency support
- [ ] Automated email notifications
- [ ] Scheduled fundraiser end-date automation
- [ ] Advanced fraud detection
- [ ] API wrapper for web/mobile integration
- [ ] Real-time dashboard widgets
- [ ] Machine learning for donation prediction
- [ ] Blockchain integration for transparency

---

## 💼 Use Cases

This database system is perfect for:

- 🏥 Healthcare crowdfunding platforms
- 🎓 Educational fundraising portals
- 🌱 Social cause campaigns
- 🚀 Startup equity crowdfunding
- 🎨 Creative project funding
- 🏘️ Community development initiatives
- 🔬 Research funding platforms

---
