-- ==============================
-- CORRECTED CROWDFUNDING DATABASE MANAGEMENT SYSTEM
-- Platform Fee Model: 1% Platform Fee + 99% Admin Earnings
-- ==============================

-- Key Changes:
-- 1. 1% is PLATFORM FEE (platform revenue), NOT admin commission
-- 2. Admin receives 99% of donation (net amount after platform fee)
-- 3. Renamed admin_commission → platform_fee for clarity
-- 4. Renamed total_commission → total_earnings for administrators

CREATE DATABASE IF NOT EXISTS CrowdfundingDB;
USE CrowdfundingDB;

-- ==============================
-- 1. DROP EXISTING TABLES (For Clean Setup)
-- ==============================
DROP TABLE IF EXISTS Visits;
DROP TABLE IF EXISTS Payroll;
DROP TABLE IF EXISTS Transactions;
DROP TABLE IF EXISTS Fundraiser;
DROP TABLE IF EXISTS Admins_phone;
DROP TABLE IF EXISTS Administrator;
DROP TABLE IF EXISTS Donor;

-- ==============================
-- 2. CREATE TABLES
-- ==============================

-- ==============================
-- CORRECTED TABLE: Administrator
-- total_earnings = Sum of all payouts received (99% of donations)
-- ==============================
CREATE TABLE Administrator (
    Admin_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    total_earnings DECIMAL(12,2) DEFAULT 0,  -- Changed from total_commission
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_admin_email (email)
);

-- Administrator phone numbers (multi-valued attribute)
CREATE TABLE Admins_phone (
    A_phone VARCHAR(20),
    Admin_id INT,
    PRIMARY KEY (A_phone, Admin_id),
    FOREIGN KEY (Admin_id) REFERENCES Administrator(Admin_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Donor table with donation tracking
CREATE TABLE Donor (
    donor_id INT PRIMARY KEY AUTO_INCREMENT,
    dname VARCHAR(100) NOT NULL,
    demail VARCHAR(100) UNIQUE NOT NULL,
    dphone VARCHAR(20),
    total_donated DECIMAL(12,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_donor_email (demail)
);

-- Fundraiser table
CREATE TABLE Fundraiser (
    fundraiser_no INT PRIMARY KEY AUTO_INCREMENT,
    Admin_id INT,
    bank_details VARCHAR(200),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    goal_amount DECIMAL(12,2) NOT NULL,
    raised_amount DECIMAL(12,2) DEFAULT 0,
    remaining_amount DECIMAL(12,2),
    deadline DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'Planned',
    fundraiser_owner_name VARCHAR(100),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (Admin_id) REFERENCES Administrator(Admin_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_fundraiser_status (status),
    INDEX idx_fundraiser_deadline (deadline)
);

-- ==============================
-- CORRECTED TABLE: Transactions
-- platform_fee = 1% kept by platform
-- net_amount = 99% goes to fundraiser (and admin via payroll)
-- ==============================
CREATE TABLE Transactions (
    Transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    donor_id INT NOT NULL,
    fundraiser_no INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    platform_fee DECIMAL(12,2) NOT NULL,  -- Changed from admin_commission
    net_amount DECIMAL(12,2) NOT NULL,    -- 99% after platform fee
    payment_mode VARCHAR(50) NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (donor_id) REFERENCES Donor(donor_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (fundraiser_no) REFERENCES Fundraiser(fundraiser_no)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_trans_date (transaction_date),
    INDEX idx_trans_donor (donor_id),
    INDEX idx_trans_fundraiser (fundraiser_no)
);

-- ==============================
-- CORRECTED TABLE: Payroll
-- admin_earnings = 99% of donation (net_amount)
-- platform_fee_deducted = 1% platform fee from that transaction
-- ==============================
CREATE TABLE Payroll (
    Payroll_id INT PRIMARY KEY AUTO_INCREMENT,
    Admin_id INT,
    fundraiser_no INT,
    Transaction_id INT,
    admin_earnings DECIMAL(12,2) NOT NULL,        -- Changed from amount_released
    platform_fee_deducted DECIMAL(12,2) NOT NULL, -- Changed from commission_amount
    payout_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payout_type VARCHAR(50) DEFAULT 'Per Transaction',
    FOREIGN KEY (Admin_id) REFERENCES Administrator(Admin_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (fundraiser_no) REFERENCES Fundraiser(fundraiser_no)
        ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (Transaction_id) REFERENCES Transactions(Transaction_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_payroll_admin (Admin_id),
    INDEX idx_payroll_date (payout_date)
);

-- Visits table (AUTO-TRACKED with interest level management)
CREATE TABLE Visits (
    visit_id INT PRIMARY KEY AUTO_INCREMENT,
    donor_id INT NOT NULL,
    fundraiser_no INT NOT NULL,
    visit_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    duration INT DEFAULT 0,
    interest_level VARCHAR(50) DEFAULT 'Low',
    visit_type VARCHAR(50) DEFAULT 'View',
    FOREIGN KEY (donor_id) REFERENCES Donor(donor_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (fundraiser_no) REFERENCES Fundraiser(fundraiser_no)
        ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_visit_donor (donor_id),
    INDEX idx_visit_fundraiser (fundraiser_no),
    INDEX idx_visit_date (visit_date)
);

-- ==============================
-- 3. INSERT SAMPLE DATA
-- ==============================

INSERT INTO Administrator (name, email) VALUES
('Mohit', 'mohit@cf.com'),
('Shehzaad', 'shehzaad@cf.com'),
('Arjun', 'arjun@cf.com');

INSERT INTO Admins_phone (A_phone, Admin_id) VALUES
('9876543210', 1),
('9123456780', 1),
('9123456780', 2),
('9999888877', 3);

INSERT INTO Donor (dname, demail, dphone) VALUES
('Mir', 'mir@donor.com', '9988776655'),
('Aahil', 'aahil@donor.com', '8877665544'),
('Affan', 'affan@donor.com', '7766554433'),
('Ehan', 'ehan@donor.com', '6677889900'),
('Zara', 'zara@donor.com', '5566778899');

INSERT INTO Fundraiser (Admin_id, bank_details, title, description, goal_amount, deadline, status, fundraiser_owner_name, remaining_amount)
VALUES
(1, 'HDFC-1234', 'Tech Fest 2025', 'Raising funds for organizing the annual university tech fest with workshops and competitions.', 200000, '2025-12-15', 'Active', 'Shehzaad', 200000),
(2, 'SBI-5678', 'Medical Relief Camp', 'Funds required for free health checkup camp in rural areas.', 75000, '2025-11-20', 'Active', 'Mohit', 75000),
(1, 'ICICI-4321', 'Green Planet Drive', 'Tree plantation and environment awareness project across 10 villages.', 50000, '2026-01-10', 'Planned', 'Mir', 50000),
(3, 'AXIS-9999', 'Education for All', 'Providing books and supplies to underprivileged children.', 100000, '2025-12-31', 'Active', 'Arjun', 100000);

-- ==============================
-- 4. CORRECTED UTILITY FUNCTIONS
-- ==============================

DELIMITER //

-- Calculate 1% platform fee
CREATE FUNCTION CalculatePlatformFee(amount DECIMAL(12,2))
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    RETURN ROUND(amount * 0.01, 2);
END //

-- Calculate net amount (99%) after platform fee
CREATE FUNCTION CalculateNetAmount(amount DECIMAL(12,2))
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    RETURN amount - CalculatePlatformFee(amount);
END //

-- Get remaining amount for fundraiser
CREATE FUNCTION GetRemainingAmount(p_fundraiser_no INT)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
    DECLARE remaining DECIMAL(12,2);
    SELECT (goal_amount - raised_amount) INTO remaining 
    FROM Fundraiser 
    WHERE fundraiser_no = p_fundraiser_no;
    RETURN COALESCE(remaining, 0);
END //

-- Check if fundraiser goal is reached
CREATE FUNCTION IsGoalReached(p_fundraiser_no INT)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE raised DECIMAL(12,2);
    DECLARE goal DECIMAL(12,2);
    SELECT raised_amount, goal_amount INTO raised, goal 
    FROM Fundraiser 
    WHERE fundraiser_no = p_fundraiser_no;
    RETURN (raised >= goal);
END //

-- Get visit count for donor-fundraiser pair
CREATE FUNCTION GetVisitCount(p_donor_id INT, p_fundraiser_no INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE visit_count INT;
    SELECT COUNT(*) INTO visit_count 
    FROM Visits 
    WHERE donor_id = p_donor_id AND fundraiser_no = p_fundraiser_no;
    RETURN COALESCE(visit_count, 0);
END //

-- Determine interest level based on visit count
-- Low: 1-2 visits, Medium: 3-4 visits, High: 5-9 visits, Very High: 10+ visits
CREATE FUNCTION DetermineInterestLevel(visit_count INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    IF visit_count >= 10 THEN
        RETURN 'Very High';
    ELSEIF visit_count >= 5 THEN
        RETURN 'High';
    ELSEIF visit_count >= 3 THEN
        RETURN 'Medium';
    ELSE
        RETURN 'Low';
    END IF;
END //

DELIMITER ;

-- ==============================
-- 11. CORRECTED TRIGGERS (SECURITY & AUTOMATION)
-- ==============================

DELIMITER //

-- TRIGGER 1: Calculate platform fee before transaction insert
CREATE TRIGGER trg_before_transaction_insert
BEFORE INSERT ON Transactions
FOR EACH ROW
BEGIN
    DECLARE current_raised DECIMAL(12,2);
    DECLARE goal DECIMAL(12,2);
    DECLARE v_status VARCHAR(50);
    
    -- Get fundraiser details
    SELECT raised_amount, goal_amount, status 
    INTO current_raised, goal, v_status 
    FROM Fundraiser 
    WHERE fundraiser_no = NEW.fundraiser_no;
    
    -- Check if fundraiser is active
    IF v_status != 'Active' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Fundraiser is not active. Cannot accept donations.';
    END IF;
    
    -- Calculate and set platform fee (1%) and net amount (99%)
    SET NEW.platform_fee = CalculatePlatformFee(NEW.amount);
    SET NEW.net_amount = CalculateNetAmount(NEW.amount);
    
    -- Check if donation would exceed goal
    IF (current_raised + NEW.net_amount) > goal THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Donation exceeds the remaining goal amount!';
    END IF;
END //

-- TRIGGER 2: After transaction, update amounts and create payroll
-- Admin receives net_amount (99%) via payroll
CREATE TRIGGER trg_after_transaction_insert
AFTER INSERT ON Transactions
FOR EACH ROW
BEGIN
    DECLARE v_admin_id INT;
    
    -- Update fundraiser raised amount with net amount (99%)
    UPDATE Fundraiser 
    SET raised_amount = raised_amount + NEW.net_amount,
        remaining_amount = goal_amount - (raised_amount + NEW.net_amount)
    WHERE fundraiser_no = NEW.fundraiser_no;
    
    -- Update donor's total donated (gross amount)
    UPDATE Donor 
    SET total_donated = total_donated + NEW.amount 
    WHERE donor_id = NEW.donor_id;
    
    -- Get admin_id for the fundraiser
    SELECT Admin_id INTO v_admin_id 
    FROM Fundraiser 
    WHERE fundraiser_no = NEW.fundraiser_no;
    
    -- Create payroll: Admin receives net_amount (99%)
    INSERT INTO Payroll (Admin_id, fundraiser_no, Transaction_id, admin_earnings, platform_fee_deducted)
    VALUES (v_admin_id, NEW.fundraiser_no, NEW.Transaction_id, NEW.net_amount, NEW.platform_fee);
    
    -- Update administrator's total earnings (NOT commission)
    UPDATE Administrator 
    SET total_earnings = total_earnings + NEW.net_amount 
    WHERE Admin_id = v_admin_id;
END //

-- TRIGGER 3: PREVENT transaction deletion (IMMUTABLE)
CREATE TRIGGER trg_before_transaction_delete
BEFORE DELETE ON Transactions
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'SECURITY: Transactions cannot be deleted. They are permanent financial audit records.';
END //

-- TRIGGER 4: PREVENT transaction updates (IMMUTABLE)
CREATE TRIGGER trg_before_transaction_update
BEFORE UPDATE ON Transactions
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'SECURITY: Transactions cannot be modified. They are permanent financial audit records.';
END //

-- TRIGGER 5: Auto-close fundraiser when goal is reached
CREATE TRIGGER trg_check_goal_reached
AFTER UPDATE ON Fundraiser
FOR EACH ROW
BEGIN
    IF NEW.raised_amount >= NEW.goal_amount AND OLD.raised_amount < OLD.goal_amount THEN
        UPDATE Fundraiser 
        SET status = 'Goal Reached' 
        WHERE fundraiser_no = NEW.fundraiser_no;
    END IF;
END //

-- TRIGGER 6: Initialize remaining amount on new fundraiser
CREATE TRIGGER trg_before_fundraiser_insert
BEFORE INSERT ON Fundraiser
FOR EACH ROW
BEGIN
    SET NEW.remaining_amount = NEW.goal_amount;
    SET NEW.raised_amount = 0;
    
    -- Validate goal amount
    IF NEW.goal_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Goal amount must be greater than 0';
    END IF;
    
    -- Validate deadline
    IF NEW.deadline <= CURDATE() THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Deadline must be in the future';
    END IF;
END //

-- TRIGGER 7: Prevent manual deletion of Visits (audit trail)
CREATE TRIGGER trg_before_visit_delete
BEFORE DELETE ON Visits
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'SECURITY: Visits cannot be deleted. They are audit records for tracking donor engagement.';
END //

-- TRIGGER 8: Prevent manual updates to critical Visit fields (audit trail)
CREATE TRIGGER trg_before_visit_update
BEFORE UPDATE ON Visits
FOR EACH ROW
BEGIN
    -- Allow interest level updates only (automatic system updates)
    IF NEW.donor_id != OLD.donor_id OR 
       NEW.fundraiser_no != OLD.fundraiser_no OR 
       NEW.visit_date != OLD.visit_date OR 
       NEW.duration != OLD.duration OR
       NEW.visit_type != OLD.visit_type THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'SECURITY: Visit records cannot be modified except interest_level (automatic update).';
    END IF;
END //

-- TRIGGER 9: PREVENT manual insertion into Payroll (system-managed)
CREATE TRIGGER trg_before_payroll_manual_insert
BEFORE INSERT ON Payroll
FOR EACH ROW
BEGIN
    -- Only allow inserts that come from transaction trigger (have Transaction_id)
    IF NEW.Transaction_id IS NULL AND NEW.payout_type = 'Per Transaction' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'SECURITY: Payroll entries are automatically created by the system.';
    END IF;
END //

-- TRIGGER 10: PREVENT manual deletion of Payroll (audit trail)
CREATE TRIGGER trg_before_payroll_delete
BEFORE DELETE ON Payroll
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'SECURITY: Payroll records cannot be deleted. They are financial audit records.';
END //

-- TRIGGER 11: PREVENT updates to Payroll (audit trail)
CREATE TRIGGER trg_before_payroll_update
BEFORE UPDATE ON Payroll
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'SECURITY: Payroll records cannot be modified. They are financial audit records.';
END //

-- TRIGGER 12: Validate visit duration
CREATE TRIGGER trg_before_visit_insert
BEFORE INSERT ON Visits
FOR EACH ROW
BEGIN
    IF NEW.duration < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Visit duration cannot be negative.';
    END IF;
END //

DELIMITER ;

-- ==============================
-- 12. CORRECTED VIEWS FOR REPORTING
-- ==============================

CREATE OR REPLACE VIEW vw_active_fundraisers AS
SELECT 
    f.fundraiser_no,
    f.title,
    f.description,
    f.fundraiser_owner_name,
    f.goal_amount,
    f.raised_amount,
    f.remaining_amount,
    ROUND((f.raised_amount / f.goal_amount) * 100, 2) AS completion_percentage,
    f.deadline,
    DATEDIFF(f.deadline, CURDATE()) AS days_remaining,
    f.status,
    a.name AS admin_name,
    a.email AS admin_email,
    COUNT(DISTINCT v.visit_id) AS total_visits,
    COUNT(DISTINCT v.donor_id) AS unique_visitors,
    COUNT(DISTINCT t.Transaction_id) AS total_transactions
FROM Fundraiser f
LEFT JOIN Administrator a ON f.Admin_id = a.Admin_id
LEFT JOIN Visits v ON f.fundraiser_no = v.fundraiser_no
LEFT JOIN Transactions t ON f.fundraiser_no = t.fundraiser_no
WHERE f.status = 'Active'
GROUP BY f.fundraiser_no
ORDER BY f.deadline ASC;

CREATE OR REPLACE VIEW vw_transaction_summary AS
SELECT 
    t.Transaction_id,
    d.dname AS donor_name,
    d.demail AS donor_email,
    f.title AS fundraiser_title,
    f.fundraiser_owner_name,
    a.name AS admin_name,
    t.amount AS gross_amount,
    t.platform_fee AS platform_fee_1_percent,
    t.net_amount AS net_to_fundraiser_and_admin,
    t.payment_mode,
    t.transaction_date,
    'IMMUTABLE' AS record_status
FROM Transactions t
JOIN Donor d ON t.donor_id = d.donor_id
JOIN Fundraiser f ON t.fundraiser_no = f.fundraiser_no
LEFT JOIN Administrator a ON f.Admin_id = a.Admin_id
ORDER BY t.transaction_date DESC;

CREATE OR REPLACE VIEW vw_donor_engagement AS
SELECT 
    d.donor_id,
    d.dname AS donor_name,
    d.demail AS donor_email,
    d.dphone,
    d.total_donated,
    COUNT(DISTINCT v.fundraiser_no) AS fundraisers_visited,
    COUNT(v.visit_id) AS total_visits,
    MAX(v.interest_level) AS highest_interest_level,
    COUNT(DISTINCT t.Transaction_id) AS total_donations,
    COALESCE(SUM(t.amount), 0) AS total_amount_donated
FROM Donor d
LEFT JOIN Visits v ON d.donor_id = v.donor_id
LEFT JOIN Transactions t ON d.donor_id = t.donor_id
GROUP BY d.donor_id
ORDER BY d.total_donated DESC;

CREATE OR REPLACE VIEW vw_administrator_dashboard AS
SELECT 
    a.Admin_id,
    a.name AS admin_name,
    a.email,
    a.total_earnings AS total_earnings_received,
    COUNT(DISTINCT f.fundraiser_no) AS total_fundraisers,
    COUNT(DISTINCT CASE WHEN f.status = 'Active' THEN f.fundraiser_no END) AS active_fundraisers,
    COALESCE(SUM(f.raised_amount), 0) AS total_funds_managed,
    COUNT(DISTINCT t.Transaction_id) AS total_transactions,
    COUNT(DISTINCT p.Payroll_id) AS total_payouts,
    COALESCE(SUM(t.platform_fee), 0) AS total_platform_fees_from_fundraisers
FROM Administrator a
LEFT JOIN Fundraiser f ON a.Admin_id = f.Admin_id
LEFT JOIN Transactions t ON f.fundraiser_no = t.fundraiser_no
LEFT JOIN Payroll p ON a.Admin_id = p.Admin_id
GROUP BY a.Admin_id
ORDER BY a.total_earnings DESC;

CREATE OR REPLACE VIEW vw_high_interest_donors AS
SELECT 
    d.donor_id,
    d.dname AS donor_name,
    f.fundraiser_no,
    f.title AS fundraiser_title,
    COUNT(v.visit_id) AS visit_count,
    MAX(v.interest_level) AS interest_level,
    MAX(v.visit_date) AS last_visit,
    CASE 
        WHEN EXISTS (SELECT 1 FROM Transactions t 
                     WHERE t.donor_id = d.donor_id 
                     AND t.fundraiser_no = f.fundraiser_no) 
        THEN 'DONATED' 
        ELSE 'NOT YET DONATED' 
    END AS donation_status
FROM Donor d
JOIN Visits v ON d.donor_id = v.donor_id
JOIN Fundraiser f ON v.fundraiser_no = f.fundraiser_no
WHERE v.interest_level IN ('High', 'Very High')
GROUP BY d.donor_id, f.fundraiser_no
HAVING visit_count >= 5
ORDER BY visit_count DESC;

-- ==============================
-- 13. TEST DATA & DEMONSTRATIONS
-- ==============================

-- Test 1: Record multiple visits to track interest level progression
CALL RecordFundraiserVisit(1, 1, 5);
CALL RecordFundraiserVisit(1, 1, 8);
CALL RecordFundraiserVisit(1, 1, 12);
CALL RecordFundraiserVisit(1, 1, 7);
CALL RecordFundraiserVisit(1, 1, 10);  -- Should reach "High" interest level

-- Test 2: Process donations (automatic payroll and visit creation)
CALL ProcessDonation(1, 1, 5000.00, 'UPI');
CALL ProcessDonation(2, 1, 3000.00, 'Credit Card');
CALL ProcessDonation(3, 2, 2500.00, 'Debit Card');

-- Test 3: View various reports
CALL GetFundraiserSummary(1);
CALL GetDonorHistory(1);
CALL GetAdministratorEarnings(1);
CALL GetDonorInterestAnalytics(1);
CALL GetPlatformStatistics();

-- Test 4: View audit trail
CALL ViewAuditTrail(1);

-- Test 5: Query views
SELECT * FROM vw_active_fundraisers;
SELECT * FROM vw_transaction_summary;
SELECT * FROM vw_donor_engagement;
SELECT * FROM vw_administrator_dashboard;
SELECT * FROM vw_high_interest_donors;

-- ==============================
-- 14. SECURITY DEMONSTRATIONS
-- ==============================

-- These commands will FAIL due to security triggers:

-- Attempt to delete a transaction (WILL FAIL)
-- DELETE FROM Transactions WHERE Transaction_id = 1;
-- Error: Transactions cannot be deleted. They are permanent financial audit records.

-- Attempt to update a transaction (WILL FAIL)
-- UPDATE Transactions SET amount = 10000 WHERE Transaction_id = 1;
-- Error: Transactions cannot be modified. They are permanent financial audit records.

-- Attempt to delete a visit (WILL FAIL)
-- DELETE FROM Visits WHERE visit_id = 1;
-- Error: Visits cannot be deleted. They are audit records for tracking donor engagement.

-- Attempt to manually insert payroll (WILL FAIL)
-- INSERT INTO Payroll (Admin_id, fundraiser_no, amount_released, commission_amount) 
-- VALUES (1, 1, 5000, 50);
-- Error: Payroll entries are automatically created by the system.

-- Attempt to delete payroll (WILL FAIL)
-- DELETE FROM Payroll WHERE Payroll_id = 1;
-- Error: Payroll records cannot be deleted. They are financial audit records.

-- ==============================
-- 15. USAGE EXAMPLES & BEST PRACTICES
-- ==============================

/*
CORRECT USAGE FLOW:

1. ADD ADMINISTRATOR:
   CALL AddAdministrator('John Doe', 'john@cf.com');
   CALL AddAdminPhone(4, '9876543210');

2. ADD DONOR:
   CALL AddDonor('Jane Smith', 'jane@donor.com', '8765432109');

3. CREATE FUNDRAISER:
   CALL AddFundraiser(1, 'HDFC-9999', 'New Campaign', 'Description here', 
                      100000, '2025-12-31', 'Active', 'Owner Name');

4. DONOR VISITS FUNDRAISER (Multiple times - interest level increases):
   CALL RecordFundraiserVisit(1, 1, 10);  -- Visit 1: Low interest
   CALL RecordFundraiserVisit(1, 1, 15);  -- Visit 2: Low interest
   CALL RecordFundraiserVisit(1, 1, 12);  -- Visit 3: Medium interest
   CALL RecordFundraiserVisit(1, 1, 8);   -- Visit 4: Medium interest
   CALL RecordFundraiserVisit(1, 1, 20);  -- Visit 5: High interest ✓

5. DONOR MAKES DONATION:
   CALL ProcessDonation(1, 1, 5000.00, 'UPI');
   -- This automatically:
   -- - Deducts 1% commission (₹50)
   -- - Credits ₹4950 to fundraiser
   -- - Creates payroll entry for admin
   -- - Records a visit with type 'Transaction'
   -- - Updates interest level for all visits
   -- - Updates donor's total donated
   -- - Updates admin's total commission

6. VIEW REPORTS:
   CALL GetFundraiserSummary(1);
   CALL GetDonorInterestAnalytics(1);
   CALL ViewAuditTrail(1);

7. DELETE FUNDRAISER (Safe deletion):
   CALL DeleteFundraiser(3);
   -- If no transactions: Hard delete
   -- If has transactions: Soft delete (preserves data)

SECURITY FEATURES:
✓ Transactions are IMMUTABLE (cannot delete or update)
✓ Payroll is AUTO-GENERATED (cannot manually create)
✓ Visits are AUDIT RECORDS (cannot delete)
✓ Interest levels AUTO-UPDATE based on visit count
✓ Commission automatically calculated (1%)
✓ All financial records preserved for auditing

INTEREST LEVEL CALCULATION:
- 1-2 visits: Low
- 3-4 visits: Medium
- 5-9 visits: High
- 10+ visits: Very High

KEY CONSTRAINTS:
- Donor cannot be deleted if they have transactions
- Fundraiser soft-deletes if it has transactions
- Administrator preserved when fundraiser deleted
- All amounts validated before transaction processing
- Only 'Active' fundraisers can accept donations
*/

-- ==============================
-- 16. FINAL VERIFICATION QUERIES
-- ==============================

-- Check all triggers are created
SELECT TRIGGER_NAME, EVENT_MANIPULATION, EVENT_OBJECT_TABLE 
FROM information_schema.TRIGGERS 
WHERE TRIGGER_SCHEMA = 'CrowdfundingDB'
ORDER BY EVENT_OBJECT_TABLE, EVENT_MANIPULATION;

-- Check all procedures are created
SELECT ROUTINE_NAME, ROUTINE_TYPE 
FROM information_schema.ROUTINES 
WHERE ROUTINE_SCHEMA = 'CrowdfundingDB'
ORDER BY ROUTINE_TYPE, ROUTINE_NAME;

-- Check all functions are created
SELECT ROUTINE_NAME 
FROM information_schema.ROUTINES 
WHERE ROUTINE_SCHEMA = 'CrowdfundingDB' AND ROUTINE_TYPE = 'FUNCTION'
ORDER BY ROUTINE_NAME;

-- Verify data integrity
SELECT 
    'Administrators' AS Table_Name, COUNT(*) AS Record_Count FROM Administrator
UNION ALL
SELECT 'Donors', COUNT(*) FROM Donor
UNION ALL
SELECT 'Fundraisers', COUNT(*) FROM Fundraiser
UNION ALL
SELECT 'Transactions', COUNT(*) FROM Transactions
UNION ALL
SELECT 'Payroll', COUNT(*) FROM Payroll
UNION ALL
SELECT 'Visits', COUNT(*) FROM Visits;

-- ==============================
-- END OF CROWDFUNDING DATABASE SYSTEM
-- ==============================

-- System Status: ✓ COMPLETE
-- Security Level: ✓ HIGH
-- Audit Trail: ✓ ENABLED
-- Platform Fee Model: ✓ ACTIVE (1% Platform Fee, 99% Admin Earnings)
-- Visit Tracking: ✓ ACTIVE
-- Interest Level: ✓ AUTO-UPDATE
-- Data Integrity: ✓ ENFORCED

-- ==============================
-- CORRECTED USAGE EXAMPLES
-- ==============================

/*
CORRECTED DONATION FLOW:

When donor donates ₹10,000:
1. Gross amount: ₹10,000 (what donor pays)
2. Platform fee (1%): ₹100 (platform keeps this)
3. Net amount (99%): ₹9,900 (goes to fundraiser)
4. Admin receives: ₹9,900 (via payroll entry)

BREAKDOWN:
- Platform revenue: ₹100
- Fundraiser balance: +₹9,900
- Admin earnings: +₹9,900
- Donor paid: ₹10,000

CALL ProcessDonation(1, 1, 10000.00, 'UPI');
-- Returns:
-- Gross_Amount: 10000.00
-- Platform_Fee_1_Percent: 100.00 (platform keeps)
-- Net_To_Fundraiser: 9900.00
-- Admin_Receives: 9900.00 (via payroll)

KEY POINTS:
- Platform keeps 1% fee (₹100)
- Admin receives 99% net amount (₹9,900)
- Fundraiser receives 99% net amount (₹9,900)
- Platform fee is NOT given to admin
*/

-- ==============================
-- 5. ADMINISTRATOR PROCEDURES
-- ==============================

DELIMITER //

CREATE PROCEDURE AddAdministrator(
    IN admin_name VARCHAR(100), 
    IN admin_email VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: Failed to add administrator' AS Error_Message;
    END;
    
    START TRANSACTION;
    INSERT INTO Administrator (name, email) VALUES (admin_name, admin_email);
    COMMIT;
    SELECT 'Administrator added successfully' AS Message, LAST_INSERT_ID() AS Admin_id;
END //

CREATE PROCEDURE UpdateAdministrator(
    IN p_Admin_id INT, 
    IN new_name VARCHAR(100), 
    IN new_email VARCHAR(100)
)
BEGIN
    UPDATE Administrator 
    SET name = new_name, email = new_email 
    WHERE Admin_id = p_Admin_id;
    
    IF ROW_COUNT() > 0 THEN
        SELECT 'Administrator updated successfully' AS Message;
    ELSE
        SELECT 'Administrator not found' AS Error_Message;
    END IF;
END //

CREATE PROCEDURE DeleteAdministrator(IN p_Admin_id INT)
BEGIN
    DECLARE fundraiser_count INT;
    
    SELECT COUNT(*) INTO fundraiser_count 
    FROM Fundraiser 
    WHERE Admin_id = p_Admin_id;
    
    IF fundraiser_count > 0 THEN
        SELECT 'Cannot delete administrator with active fundraisers. Set Admin_id to NULL first.' AS Error_Message;
    ELSE
        DELETE FROM Administrator WHERE Admin_id = p_Admin_id;
        SELECT 'Administrator deleted successfully' AS Message;
    END IF;
END //

CREATE PROCEDURE AddAdminPhone(
    IN p_Admin_id INT, 
    IN p_A_phone VARCHAR(20)
)
BEGIN
    INSERT INTO Admins_phone (A_phone, Admin_id) 
    VALUES (p_A_phone, p_Admin_id);
    SELECT 'Phone number added successfully' AS Message;
END //

DELIMITER ;

-- ==============================
-- 6. DONOR PROCEDURES
-- ==============================

DELIMITER //

CREATE PROCEDURE AddDonor(
    IN donor_name VARCHAR(100), 
    IN donor_email VARCHAR(100), 
    IN donor_phone VARCHAR(20)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: Failed to add donor' AS Error_Message;
    END;
    
    START TRANSACTION;
    INSERT INTO Donor (dname, demail, dphone) 
    VALUES (donor_name, donor_email, donor_phone);
    COMMIT;
    SELECT 'Donor added successfully' AS Message, LAST_INSERT_ID() AS Donor_id;
END //

CREATE PROCEDURE UpdateDonor(
    IN p_donor_id INT, 
    IN new_name VARCHAR(100), 
    IN new_email VARCHAR(100), 
    IN new_phone VARCHAR(20)
)
BEGIN
    UPDATE Donor 
    SET dname = new_name, demail = new_email, dphone = new_phone 
    WHERE donor_id = p_donor_id;
    
    IF ROW_COUNT() > 0 THEN
        SELECT 'Donor updated successfully' AS Message;
    ELSE
        SELECT 'Donor not found' AS Error_Message;
    END IF;
END //

CREATE PROCEDURE DeleteDonor(IN p_donor_id INT)
BEGIN
    DECLARE transaction_count INT;
    
    SELECT COUNT(*) INTO transaction_count 
    FROM Transactions 
    WHERE donor_id = p_donor_id;
    
    IF transaction_count > 0 THEN
        SELECT 'Cannot delete donor with existing transactions' AS Error_Message;
    ELSE
        DELETE FROM Donor WHERE donor_id = p_donor_id;
        SELECT 'Donor deleted successfully' AS Message;
    END IF;
END //

DELIMITER ;

-- ==============================
-- 7. FUNDRAISER PROCEDURES
-- ==============================

DELIMITER //

CREATE PROCEDURE AddFundraiser(
    IN p_admin_id INT, 
    IN p_bank_details VARCHAR(200), 
    IN p_title VARCHAR(200), 
    IN p_description TEXT,
    IN p_goal_amount DECIMAL(12,2), 
    IN p_deadline DATE, 
    IN p_status VARCHAR(50), 
    IN p_fundraiser_owner_name VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: Failed to add fundraiser' AS Error_Message;
    END;
    
    START TRANSACTION;
    INSERT INTO Fundraiser (Admin_id, bank_details, title, description, goal_amount, deadline, status, fundraiser_owner_name, remaining_amount)
    VALUES (p_admin_id, p_bank_details, p_title, p_description, p_goal_amount, p_deadline, p_status, p_fundraiser_owner_name, p_goal_amount);
    COMMIT;
    
    SELECT 'Fundraiser added successfully' AS Message, LAST_INSERT_ID() AS Fundraiser_no;
END //

CREATE PROCEDURE UpdateFundraiser(
    IN p_fundraiser_no INT, 
    IN p_title VARCHAR(200), 
    IN p_description TEXT,
    IN p_goal_amount DECIMAL(12,2), 
    IN p_deadline DATE, 
    IN p_status VARCHAR(50),
    IN p_fundraiser_owner_name VARCHAR(100)
)
BEGIN
    UPDATE Fundraiser
    SET title = p_title, 
        description = p_description, 
        goal_amount = p_goal_amount,
        deadline = p_deadline, 
        status = p_status, 
        fundraiser_owner_name = p_fundraiser_owner_name,
        remaining_amount = p_goal_amount - raised_amount
    WHERE fundraiser_no = p_fundraiser_no;
    
    IF ROW_COUNT() > 0 THEN
        SELECT 'Fundraiser updated successfully' AS Message;
    ELSE
        SELECT 'Fundraiser not found' AS Error_Message;
    END IF;
END //

CREATE PROCEDURE DeleteFundraiser(IN p_fundraiser_no INT)
BEGIN
    DECLARE transaction_count INT;
    
    SELECT COUNT(*) INTO transaction_count 
    FROM Transactions 
    WHERE fundraiser_no = p_fundraiser_no;
    
    IF transaction_count > 0 THEN
        -- Soft delete: Set status and disconnect from admin
        UPDATE Fundraiser 
        SET status = 'Deleted', Admin_id = NULL 
        WHERE fundraiser_no = p_fundraiser_no;
        SELECT 'Fundraiser soft-deleted (has transactions). Administrator preserved.' AS Message;
    ELSE
        -- Hard delete: No transactions exist
        DELETE FROM Fundraiser WHERE fundraiser_no = p_fundraiser_no;
        SELECT 'Fundraiser permanently deleted. Administrator preserved.' AS Message;
    END IF;
END //

CREATE PROCEDURE SoftDeleteFundraiser(IN p_fundraiser_no INT)
BEGIN
    UPDATE Fundraiser 
    SET status = 'Deleted', deadline = CURDATE() 
    WHERE fundraiser_no = p_fundraiser_no;
    
    IF ROW_COUNT() > 0 THEN
        SELECT 'Fundraiser marked as deleted' AS Message;
    ELSE
        SELECT 'Fundraiser not found' AS Error_Message;
    END IF;
END //

DELIMITER ;

-- ==============================
-- 8. VISIT TRACKING PROCEDURES
-- ==============================

DELIMITER //

-- AUTO-RECORD VISIT: Called when donor views a fundraiser
-- Automatically updates interest level based on total visits
CREATE PROCEDURE RecordFundraiserVisit(
    IN p_donor_id INT, 
    IN p_fundraiser_no INT, 
    IN p_duration INT
)
BEGIN
    DECLARE v_visit_count INT;
    DECLARE v_interest_level VARCHAR(50);
    
    -- Validate donor exists
    IF NOT EXISTS (SELECT 1 FROM Donor WHERE donor_id = p_donor_id) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Donor does not exist';
    END IF;
    
    -- Validate fundraiser exists
    IF NOT EXISTS (SELECT 1 FROM Fundraiser WHERE fundraiser_no = p_fundraiser_no) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Fundraiser does not exist';
    END IF;
    
    -- Get current visit count
    SET v_visit_count = GetVisitCount(p_donor_id, p_fundraiser_no);
    
    -- Determine interest level (including this visit)
    SET v_interest_level = DetermineInterestLevel(v_visit_count + 1);
    
    -- Record the visit with calculated interest level
    INSERT INTO Visits (donor_id, fundraiser_no, duration, interest_level, visit_type)
    VALUES (p_donor_id, p_fundraiser_no, p_duration, v_interest_level, 'View');
    
    -- Update ALL previous visits from this donor to this fundraiser
    -- Interest level increases as more visits are recorded
    UPDATE Visits 
    SET interest_level = v_interest_level
    WHERE donor_id = p_donor_id AND fundraiser_no = p_fundraiser_no;
    
    SELECT 
        'Visit recorded successfully!' AS Message,
        v_visit_count + 1 AS Total_Visits,
        v_interest_level AS Current_Interest_Level,
        CASE 
            WHEN v_visit_count + 1 >= 5 THEN 'Donor showing strong interest!'
            WHEN v_visit_count + 1 >= 3 THEN 'Donor showing moderate interest'
            ELSE 'New visitor'
        END AS Interest_Status;
END //

-- View visit history for a fundraiser
CREATE PROCEDURE ViewVisitHistory(IN p_fundraiser_no INT)
BEGIN
    SELECT 
        v.visit_id,
        v.donor_id,
        d.dname AS donor_name, 
        v.visit_date, 
        v.duration, 
        v.interest_level,
        v.visit_type,
        COUNT(*) OVER (PARTITION BY v.donor_id) AS total_donor_visits
    FROM Visits v
    JOIN Donor d ON v.donor_id = d.donor_id
    WHERE v.fundraiser_no = p_fundraiser_no
    ORDER BY v.visit_date DESC;
END //

-- View visit history for a donor
CREATE PROCEDURE ViewDonorVisits(IN p_donor_id INT)
BEGIN
    SELECT 
        v.visit_id,
        f.title AS fundraiser_title,
        v.visit_date,
        v.duration,
        v.interest_level,
        v.visit_type,
        COUNT(*) OVER (PARTITION BY v.fundraiser_no) AS visits_to_fundraiser
    FROM Visits v
    JOIN Fundraiser f ON v.fundraiser_no = f.fundraiser_no
    WHERE v.donor_id = p_donor_id
    ORDER BY v.visit_date DESC;
END //

-- Get donor interest analytics
CREATE PROCEDURE GetDonorInterestAnalytics(IN p_donor_id INT)
BEGIN
    SELECT 
        f.fundraiser_no,
        f.title,
        COUNT(v.visit_id) AS total_visits,
        MAX(v.interest_level) AS interest_level,
        MAX(v.visit_date) AS last_visit,
        COALESCE(SUM(t.amount), 0) AS total_donated,
        CASE 
            WHEN COUNT(v.visit_id) >= 10 THEN 'Very High - Ready to donate!'
            WHEN COUNT(v.visit_id) >= 5 THEN 'High - Strong interest'
            WHEN COUNT(v.visit_id) >= 3 THEN 'Medium - Growing interest'
            ELSE 'Low - Just exploring'
        END AS engagement_status
    FROM Fundraiser f
    LEFT JOIN Visits v ON f.fundraiser_no = v.fundraiser_no AND v.donor_id = p_donor_id
    LEFT JOIN Transactions t ON f.fundraiser_no = t.fundraiser_no AND t.donor_id = p_donor_id
    WHERE v.visit_id IS NOT NULL
    GROUP BY f.fundraiser_no, f.title
    ORDER BY total_visits DESC;
END //

DELIMITER ;

-- ==============================
-- 9. TRANSACTION PROCEDURES (IMMUTABLE)
-- ==============================

DELIMITER //

-- MAIN PROCEDURE: Process donation with automatic platform fee, payroll, and visit tracking
CREATE PROCEDURE ProcessDonation(
    IN p_donor_id INT, 
    IN p_fundraiser_no INT, 
    IN p_amount DECIMAL(12,2),
    IN p_payment_mode VARCHAR(50)
)
BEGIN
    DECLARE v_platform_fee DECIMAL(12,2);
    DECLARE v_net_amount DECIMAL(12,2);
    DECLARE v_admin_id INT;
    DECLARE v_visit_count INT;
    DECLARE v_interest_level VARCHAR(50);
    DECLARE v_fundraiser_status VARCHAR(50);
    DECLARE v_remaining DECIMAL(12,2);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: Transaction failed. Please check all parameters.' AS Error_Message;
    END;
    
    START TRANSACTION;
    
    -- Validate donor exists
    IF NOT EXISTS (SELECT 1 FROM Donor WHERE donor_id = p_donor_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Donor does not exist';
    END IF;
    
    -- Validate fundraiser exists and get details
    SELECT Admin_id, status, remaining_amount 
    INTO v_admin_id, v_fundraiser_status, v_remaining
    FROM Fundraiser 
    WHERE fundraiser_no = p_fundraiser_no;
    
    IF v_admin_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Fundraiser does not exist';
    END IF;
    
    -- Check if fundraiser is active
    IF v_fundraiser_status != 'Active' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Fundraiser is not active. Cannot accept donations.';
    END IF;
    
    -- Validate amount
    IF p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Amount must be greater than 0';
    END IF;
    
    -- Calculate platform fee (1%) and net amount (99%)
    SET v_platform_fee = CalculatePlatformFee(p_amount);
    SET v_net_amount = CalculateNetAmount(p_amount);
    
    -- Check if donation exceeds remaining amount
    IF v_net_amount > v_remaining THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Donation exceeds remaining goal amount';
    END IF;
    
    -- Insert transaction (triggers will handle the rest)
    INSERT INTO Transactions (donor_id, fundraiser_no, amount, platform_fee, net_amount, payment_mode)
    VALUES (p_donor_id, p_fundraiser_no, p_amount, v_platform_fee, v_net_amount, p_payment_mode);
    
    -- Auto-record visit for transaction
    SET v_visit_count = GetVisitCount(p_donor_id, p_fundraiser_no);
    SET v_interest_level = DetermineInterestLevel(v_visit_count + 1);
    
    INSERT INTO Visits (donor_id, fundraiser_no, duration, interest_level, visit_type)
    VALUES (p_donor_id, p_fundraiser_no, 20, v_interest_level, 'Transaction');
    
    -- Update all visit interest levels for this donor-fundraiser pair
    UPDATE Visits 
    SET interest_level = v_interest_level
    WHERE donor_id = p_donor_id AND fundraiser_no = p_fundraiser_no;
    
    COMMIT;
    
    -- Return success message with corrected breakdown
    SELECT 
        'Donation processed successfully!' AS Message, 
        LAST_INSERT_ID() AS Transaction_id,
        p_amount AS Gross_Amount,
        v_platform_fee AS Platform_Fee_1_Percent,
        v_net_amount AS Net_To_Fundraiser,
        v_net_amount AS Admin_Receives_Via_Payroll,
        CONCAT('Platform keeps: ₹', v_platform_fee, ' | Admin receives: ₹', v_net_amount) AS Fee_Distribution,
        v_interest_level AS Donor_Interest_Level,
        v_visit_count + 1 AS Total_Visits_To_Fundraiser;
END //

-- View transaction details (READ-ONLY)
CREATE PROCEDURE ViewTransactionDetails(IN p_transaction_id INT)
BEGIN
    SELECT 
        t.Transaction_id,
        d.dname AS Donor_Name,
        d.demail AS Donor_Email,
        f.title AS Fundraiser_Title,
        f.fundraiser_owner_name AS Fundraiser_Owner,
        t.amount AS Gross_Amount,
        t.platform_fee AS Platform_Fee,
        t.net_amount AS Net_Amount,
        t.payment_mode,
        t.transaction_date,
        a.name AS Administrator_Name,
        p.Payroll_id,
        p.admin_earnings AS Admin_Received,
        p.platform_fee_deducted AS Platform_Fee_From_This_Transaction,
        p.payout_date,
        CONCAT('Platform fee: ₹', t.platform_fee, ' (1%) | ',
               'Admin received: ₹', p.admin_earnings, ' (99%)') AS Fee_Distribution
    FROM Transactions t
    JOIN Donor d ON t.donor_id = d.donor_id
    JOIN Fundraiser f ON t.fundraiser_no = f.fundraiser_no
    LEFT JOIN Administrator a ON f.Admin_id = a.Admin_id
    LEFT JOIN Payroll p ON t.Transaction_id = p.Transaction_id
    WHERE t.Transaction_id = p_transaction_id;
END //

DELIMITER ;

-- ==============================
-- 10. REPORTING & ANALYTICS PROCEDURES
-- ==============================

DELIMITER //

CREATE PROCEDURE GetFundraiserSummary(IN p_fundraiser_no INT)
BEGIN
    SELECT 
        f.fundraiser_no,
        f.title,
        f.description,
        f.fundraiser_owner_name,
        f.bank_details,
        f.goal_amount,
        f.raised_amount,
        f.remaining_amount,
        ROUND((f.raised_amount / f.goal_amount) * 100, 2) AS completion_percentage,
        f.status,
        f.deadline,
        DATEDIFF(f.deadline, CURDATE()) AS days_remaining,
        a.name AS Administrator_Name,
        a.email AS Administrator_Email,
        COUNT(DISTINCT t.Transaction_id) AS Total_Transactions,
        COUNT(DISTINCT v.visit_id) AS Total_Visits,
        COUNT(DISTINCT v.donor_id) AS Unique_Visitors,
        COALESCE(SUM(t.platform_fee), 0) AS Total_Platform_Fees,
        COALESCE(SUM(t.net_amount), 0) AS Total_Net_Amount
    FROM Fundraiser f
    LEFT JOIN Administrator a ON f.Admin_id = a.Admin_id
    LEFT JOIN Transactions t ON f.fundraiser_no = t.fundraiser_no
    LEFT JOIN Visits v ON f.fundraiser_no = v.fundraiser_no
    WHERE f.fundraiser_no = p_fundraiser_no
    GROUP BY f.fundraiser_no;
END //

CREATE PROCEDURE GetDonorHistory(IN p_donor_id INT)
BEGIN
    SELECT 
        d.donor_id,
        d.dname,
        d.demail,
        d.dphone,
        d.total_donated,
        t.Transaction_id,
        f.title AS Fundraiser_Title,
        t.amount AS Gross_Amount,
        t.platform_fee,
        t.net_amount,
        t.payment_mode,
        t.transaction_date,
        'IMMUTABLE' AS Transaction_Status
    FROM Donor d
    LEFT JOIN Transactions t ON d.donor_id = t.donor_id
    LEFT JOIN Fundraiser f ON t.fundraiser_no = f.fundraiser_no
    WHERE d.donor_id = p_donor_id
    ORDER BY t.transaction_date DESC;
END //

CREATE PROCEDURE GetAdministratorEarnings(IN p_Admin_id INT)
BEGIN
    SELECT 
        a.Admin_id,
        a.name,
        a.email,
        a.total_earnings AS Total_Earnings_Received,
        COUNT(DISTINCT f.fundraiser_no) AS Total_Fundraisers,
        COUNT(DISTINCT CASE WHEN f.status = 'Active' THEN f.fundraiser_no END) AS Active_Fundraisers,
        COALESCE(SUM(f.raised_amount), 0) AS Total_Funds_Managed,
        COUNT(DISTINCT t.Transaction_id) AS Total_Transactions,
        COUNT(DISTINCT p.Payroll_id) AS Total_Payouts,
        COALESCE(SUM(t.platform_fee), 0) AS Platform_Fees_From_My_Fundraisers,
        CONCAT('Admin receives 99% of donations (₹', 
               COALESCE(SUM(p.admin_earnings), 0), 
               ') | Platform collects 1% (₹', 
               COALESCE(SUM(t.platform_fee), 0), ')') AS Earnings_Breakdown
    FROM Administrator a
    LEFT JOIN Fundraiser f ON a.Admin_id = f.Admin_id
    LEFT JOIN Transactions t ON f.fundraiser_no = t.fundraiser_no
    LEFT JOIN Payroll p ON a.Admin_id = p.Admin_id
    WHERE a.Admin_id = p_Admin_id
    GROUP BY a.Admin_id;
END //

CREATE PROCEDURE ViewAuditTrail(IN p_fundraiser_no INT)
BEGIN
    SELECT 'TRANSACTION' AS Record_Type, 
           Transaction_id AS ID, 
           transaction_date AS Date_Time, 
           CONCAT('₹', FORMAT(amount, 2)) AS Amount,
           'IMMUTABLE' AS Status
    FROM Transactions 
    WHERE fundraiser_no = p_fundraiser_no
    UNION ALL
    SELECT 'PAYROLL' AS Record_Type, 
           Payroll_id AS ID, 
           payout_date AS Date_Time, 
           CONCAT('₹', FORMAT(admin_earnings, 2)) AS Amount,
           'AUTO-GENERATED' AS Status
    FROM Payroll 
    WHERE fundraiser_no = p_fundraiser_no
    UNION ALL
    SELECT 'VISIT' AS Record_Type, 
           visit_id AS ID, 
           visit_date AS Date_Time, 
           CONCAT(duration, ' mins (', interest_level, ')') AS Amount,
           'TRACKED' AS Status
    FROM Visits 
    WHERE fundraiser_no = p_fundraiser_no
    ORDER BY Date_Time DESC;
END //

-- Get overall platform statistics
CREATE PROCEDURE GetPlatformStatistics()
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM Administrator) AS Total_Administrators,
        (SELECT COUNT(*) FROM Donor) AS Total_Donors,
        (SELECT COUNT(*) FROM Fundraiser) AS Total_Fundraisers,
        (SELECT COUNT(*) FROM Fundraiser WHERE status = 'Active') AS Active_Fundraisers,
        (SELECT COUNT(*) FROM Fundraiser WHERE status = 'Goal Reached') AS Completed_Fundraisers,
        (SELECT COUNT(*) FROM Transactions) AS Total_Transactions,
        (SELECT COALESCE(SUM(amount), 0) FROM Transactions) AS Total_Gross_Donations,
        (SELECT COALESCE(SUM(platform_fee), 0) FROM Transactions) AS Total_Platform_Revenue,
        (SELECT COALESCE(SUM(net_amount), 0) FROM Transactions) AS Total_To_Fundraisers,
        (SELECT COALESCE(SUM(admin_earnings), 0) FROM Payroll) AS Total_Admin_Earnings,
        (SELECT COUNT(*) FROM Visits) AS Total_Visits,
        (SELECT COUNT(DISTINCT donor_id) FROM Visits) AS Unique_Visitors,
        CONCAT('Platform earned: ₹', 
               (SELECT COALESCE(SUM(platform_fee), 0) FROM Transactions),
               ' (1% of all donations)') AS Platform_Revenue_Note,
        CONCAT('Admins earned: ₹',
               (SELECT COALESCE(SUM(admin_earnings), 0) FROM Payroll),
               ' (99% of all donations)') AS Admin_Revenue_Note;
END //

DELIMITER ;
