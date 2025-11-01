import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv

load_dotenv()

class Database:
    def __init__(self):
        self.host = os.getenv('DB_HOST', 'localhost')
        self.user = os.getenv('DB_USER', 'root')
        self.password = os.getenv('DB_PASSWORD', 'Shiva@12345')
        self.database = os.getenv('DB_NAME', 'CrowdfundingDB')
        
    def get_connection(self):
        try:
            connection = mysql.connector.connect(
                host=self.host,
                user=self.user,
                password=self.password,
                database=self.database
            )
            return connection
        except Error as e:
            print(f"Error connecting to MySQL: {e}")
            return None
    
    def execute_query(self, query, params=None):
        connection = self.get_connection()
        if connection is None:
            return {'success': False, 'message': 'Database connection failed'}
        
        try:
            cursor = connection.cursor(dictionary=True)
            cursor.execute(query, params or ())
            connection.commit()
            cursor.close()
            connection.close()
            return {'success': True}
        except Error as e:
            return {'success': False, 'message': str(e)}
    
    def execute_procedure(self, procedure_name, params=None):
        connection = self.get_connection()
        if connection is None:
            return {'success': False, 'message': 'Database connection failed'}
        
        try:
            cursor = connection.cursor()
            cursor.callproc(procedure_name, params or ())
            connection.commit()
            cursor.close()
            connection.close()
            return {'success': True}
        except Error as e:
            return {'success': False, 'message': str(e)}
    
    def fetch_all(self, query, params=None):
        connection = self.get_connection()
        if connection is None:
            return []
        
        try:
            cursor = connection.cursor(dictionary=True)
            cursor.execute(query, params or ())
            results = cursor.fetchall()
            cursor.close()
            connection.close()
            return results
        except Error as e:
            print(f"Error fetching data: {e}")
            return []
    
    def fetch_one(self, query, params=None):
        connection = self.get_connection()
        if connection is None:
            return None
        
        try:
            cursor = connection.cursor(dictionary=True)
            cursor.execute(query, params or ())
            result = cursor.fetchone()
            cursor.close()
            connection.close()
            return result
        except Error as e:
            print(f"Error fetching data: {e}")
            return None
    
    def get_dashboard_stats(self):
        stats = {}
        
        result = self.fetch_one("SELECT COUNT(*) as count FROM Fundraiser")
        stats['total_fundraisers'] = result.get('count', 0) if result else 0
        
        result = self.fetch_one("SELECT COUNT(*) as count FROM Fundraiser WHERE status = 'Active'")
        stats['active_fundraisers'] = result.get('count', 0) if result else 0
        
        result = self.fetch_one("SELECT COUNT(*) as count FROM Donor")
        stats['total_donors'] = result.get('count', 0) if result else 0
        
        result = self.fetch_one("SELECT COALESCE(SUM(raised_amount), 0) as total FROM Fundraiser")
        stats['total_raised'] = result.get('total', 0) if result else 0
        
        result = self.fetch_one("SELECT COUNT(*) as count FROM Transactions")
        stats['total_transactions'] = result.get('count', 0) if result else 0
        
        result = self.fetch_one("SELECT COALESCE(SUM(goal_amount), 0) as total FROM Fundraiser")
        stats['total_goal'] = result.get('total', 0) if result else 0
        
        result = self.fetch_one("SELECT COALESCE(SUM(admin_commission), 0) as total FROM Transactions")
        stats['total_commission'] = result.get('total', 0) if result else 0
        
        result = self.fetch_one("SELECT COUNT(*) as count FROM Visits")
        stats['total_visits'] = result.get('count', 0) if result else 0
        
        return stats
    
    def get_recent_transactions(self, limit=5):
        query = """
        SELECT t.Transaction_id, d.dname as donor_name, f.title as fundraiser_title, 
               t.amount, t.admin_commission, t.net_amount, t.payment_mode, t.transaction_date
        FROM Transactions t
        JOIN Donor d ON t.donor_id = d.donor_id
        JOIN Fundraiser f ON t.fundraiser_no = f.fundraiser_no
        ORDER BY t.transaction_date DESC
        LIMIT %s
        """
        return self.fetch_all(query, (limit,))
    
    def get_top_fundraisers(self, limit=5):
        query = """
        SELECT fundraiser_no, title, goal_amount, raised_amount, remaining_amount, status,
               ROUND((raised_amount / goal_amount * 100), 2) as progress
        FROM Fundraiser
        ORDER BY raised_amount DESC
        LIMIT %s
        """
        return self.fetch_all(query, (limit,))
    
    def get_top_donors(self, limit=10):
        query = """
        SELECT d.donor_id, d.dname, d.demail, COALESCE(SUM(t.amount), 0) as total_donated,
               COUNT(t.Transaction_id) as transaction_count
        FROM Donor d
        LEFT JOIN Transactions t ON d.donor_id = t.donor_id
        GROUP BY d.donor_id, d.dname, d.demail
        ORDER BY total_donated DESC
        LIMIT %s
        """
        return self.fetch_all(query, (limit,))
    
    def get_fundraiser_progress(self):
        query = """
        SELECT fundraiser_no, title, goal_amount, raised_amount, remaining_amount, status, deadline,
               ROUND((raised_amount / goal_amount * 100), 2) as progress,
               DATEDIFF(deadline, CURDATE()) as days_remaining
        FROM Fundraiser
        ORDER BY deadline ASC
        """
        return self.fetch_all(query)
    
    def get_all_administrators(self):
        query = """
        SELECT a.Admin_id, a.name, a.email, a.total_commission,
               GROUP_CONCAT(ap.A_phone SEPARATOR ', ') as phones
        FROM Administrator a
        LEFT JOIN Admins_phone ap ON a.Admin_id = ap.Admin_id
        GROUP BY a.Admin_id, a.name, a.email, a.total_commission
        """
        return self.fetch_all(query)
    
    def get_administrator(self, admin_id):
        admin = self.fetch_one("SELECT * FROM Administrator WHERE Admin_id = %s", (admin_id,))
        if admin:
            admin['phones'] = self.fetch_all("SELECT A_phone FROM Admins_phone WHERE Admin_id = %s", (admin_id,))
        return admin
    
    def add_administrator(self, name, email, phone=None):
        result = self.execute_procedure('AddAdministrator', (name, email))
        if result['success'] and phone:
            admin = self.fetch_one("SELECT Admin_id FROM Administrator WHERE email = %s", (email,))
            if admin:
                self.add_admin_phone(admin['Admin_id'], phone)
        return result
    
    def update_administrator(self, admin_id, name, email):
        return self.execute_procedure('UpdateAdministrator', (admin_id, name, email))
    
    def delete_administrator(self, admin_id):
        return self.execute_procedure('DeleteAdministrator', (admin_id,))
    
    def add_admin_phone(self, admin_id, phone):
        """Add phone number to administrator"""
        return self.execute_procedure('AddAdminPhone', (admin_id, phone))
    
    def get_all_donors(self):
        return self.fetch_all("SELECT * FROM Donor ORDER BY donor_id DESC")
    
    def get_donor(self, donor_id):
        return self.fetch_one("SELECT * FROM Donor WHERE donor_id = %s", (donor_id,))
    
    def add_donor(self, name, email, phone):
        return self.execute_procedure('AddDonor', (name, email, phone))
    
    def update_donor(self, donor_id, name, email, phone):
        return self.execute_procedure('UpdateDonor', (donor_id, name, email, phone))
    
    def delete_donor(self, donor_id):
        return self.execute_procedure('DeleteDonor', (donor_id,))
    
    def get_donor_transactions(self, donor_id):
        query = """
        SELECT t.*, f.title as fundraiser_title
        FROM Transactions t
        JOIN Fundraiser f ON t.fundraiser_no = f.fundraiser_no
        WHERE t.donor_id = %s
        ORDER BY t.transaction_date DESC
        """
        return self.fetch_all(query, (donor_id,))
    
    def get_donor_visits(self, donor_id):
        query = """
        SELECT v.*, f.title as fundraiser_title
        FROM Visits v
        JOIN Fundraiser f ON v.fundraiser_no = f.fundraiser_no
        WHERE v.donor_id = %s
        ORDER BY v.visit_date DESC
        """
        return self.fetch_all(query, (donor_id,))
    
    def get_all_fundraisers(self):
        query = """
        SELECT f.*, a.name as admin_name,
               ROUND((f.raised_amount / f.goal_amount * 100), 2) as progress,
               (SELECT COUNT(*) FROM Visits v WHERE v.fundraiser_no = f.fundraiser_no) as total_visits,
               (SELECT COUNT(DISTINCT v.donor_id) FROM Visits v WHERE v.fundraiser_no = f.fundraiser_no) as unique_visitors
        FROM Fundraiser f
        LEFT JOIN Administrator a ON f.Admin_id = a.Admin_id
        ORDER BY f.fundraiser_no DESC
        """
        return self.fetch_all(query)
    
    def get_fundraiser(self, fundraiser_no):
        query = """
        SELECT f.*, a.name as admin_name,
               ROUND((f.raised_amount / f.goal_amount * 100), 2) as progress,
               (SELECT COUNT(*) FROM Visits v WHERE v.fundraiser_no = f.fundraiser_no) as total_visits,
               (SELECT COUNT(DISTINCT v.donor_id) FROM Visits v WHERE v.fundraiser_no = f.fundraiser_no) as unique_visitors
        FROM Fundraiser f
        LEFT JOIN Administrator a ON f.Admin_id = a.Admin_id
        WHERE f.fundraiser_no = %s
        """
        return self.fetch_one(query, (fundraiser_no,))
    
    def add_fundraiser(self, admin_id, bank_details, title, description, goal_amount, deadline, status, fundraiser_owner_name):
        return self.execute_procedure('AddFundraiser', (admin_id, bank_details, title, description, goal_amount, deadline, status, fundraiser_owner_name))
    
    def update_fundraiser(self, fundraiser_no, title, description, goal_amount, deadline, status, fundraiser_owner_name):
        return self.execute_procedure('UpdateFundraiser', (fundraiser_no, title, description, goal_amount, deadline, status, fundraiser_owner_name))
    
    def delete_fundraiser(self, fundraiser_no):
        return self.execute_procedure('DeleteFundraiser', (fundraiser_no,))
    
    def soft_delete_fundraiser(self, fundraiser_no):
        """Soft delete fundraiser (sets status to 'Deleted')"""
        return self.execute_procedure('SoftDeleteFundraiser', (fundraiser_no,))
    
    def get_fundraiser_transactions(self, fundraiser_no):
        query = """
        SELECT t.*, d.dname as donor_name
        FROM Transactions t
        JOIN Donor d ON t.donor_id = d.donor_id
        WHERE t.fundraiser_no = %s
        ORDER BY t.transaction_date DESC
        """
        return self.fetch_all(query, (fundraiser_no,))
    
    def get_fundraiser_payrolls(self, fundraiser_no):
        query = """
        SELECT p.*, a.name as admin_name
        FROM Payroll p
        JOIN Administrator a ON p.Admin_id = a.Admin_id
        WHERE p.fundraiser_no = %s
        ORDER BY p.payout_date DESC
        """
        return self.fetch_all(query, (fundraiser_no,))
    
    def get_fundraiser_visits(self, fundraiser_no):
        query = """
        SELECT v.*, d.dname as donor_name
        FROM Visits v
        JOIN Donor d ON v.donor_id = d.donor_id
        WHERE v.fundraiser_no = %s
        ORDER BY v.visit_date DESC
        """
        return self.fetch_all(query, (fundraiser_no,))
    
    def get_all_transactions(self):
        query = """
        SELECT t.*, d.dname as donor_name, f.title as fundraiser_title,
               'IMMUTABLE' as record_status
        FROM Transactions t
        JOIN Donor d ON t.donor_id = d.donor_id
        JOIN Fundraiser f ON t.fundraiser_no = f.fundraiser_no
        ORDER BY t.transaction_date DESC
        """
        return self.fetch_all(query)
    
    def process_donation(self, donor_id, fundraiser_no, amount, payment_mode):
        """Process donation using new ProcessDonation procedure (auto-calculates commission)"""
        connection = self.get_connection()
        if connection is None:
            return {'success': False, 'message': 'Database connection failed'}
        
        try:
            cursor = connection.cursor(dictionary=True)
            cursor.callproc('ProcessDonation', (donor_id, fundraiser_no, amount, payment_mode))
            
            # Fetch the result
            result = None
            for result_set in cursor.stored_results():
                result = result_set.fetchone()
            
            connection.commit()
            cursor.close()
            connection.close()
            
            if result:
                return {'success': True, 'data': result}
            return {'success': True}
        except Error as e:
            return {'success': False, 'message': str(e)}
    
    def get_all_payroll(self):
        query = """
        SELECT p.*, a.name as admin_name, f.title as fundraiser_title
        FROM Payroll p
        JOIN Administrator a ON p.Admin_id = a.Admin_id
        JOIN Fundraiser f ON p.fundraiser_no = f.fundraiser_no
        ORDER BY p.payout_date DESC
        """
        return self.fetch_all(query)
    
    def add_payroll(self, admin_id, fundraiser_no, payout_date, amount_released):
        return self.execute_procedure('AddPayroll', (admin_id, fundraiser_no, payout_date, amount_released))
    
    def get_all_visits(self):
        query = """
        SELECT v.*, d.dname as donor_name, f.title as fundraiser_title
        FROM Visits v
        JOIN Donor d ON v.donor_id = d.donor_id
        JOIN Fundraiser f ON v.fundraiser_no = f.fundraiser_no
        ORDER BY v.visit_date DESC
        """
        return self.fetch_all(query)
    
    def get_visit(self, visit_id):
        query = """
        SELECT v.*, d.dname as donor_name, f.title as fundraiser_title
        FROM Visits v
        JOIN Donor d ON v.donor_id = d.donor_id
        JOIN Fundraiser f ON v.fundraiser_no = f.fundraiser_no
        WHERE v.visit_id = %s
        """
        return self.fetch_one(query, (visit_id,))
    
    def add_visit(self, donor_id, fundraiser_no, visit_date, duration, interest_level):
        return self.execute_procedure('AddVisit', (donor_id, fundraiser_no, visit_date, duration, interest_level))
    
    def update_visit(self, visit_id, duration, interest_level):
        return self.execute_procedure('UpdateVisit', (visit_id, duration, interest_level))
    
    def record_fundraiser_visit(self, donor_id, fundraiser_no, duration):
        """Record a visit using RecordFundraiserVisit procedure"""
        connection = self.get_connection()
        if connection is None:
            return {'success': False, 'message': 'Database connection failed'}
        
        try:
            cursor = connection.cursor(dictionary=True)
            cursor.callproc('RecordFundraiserVisit', (donor_id, fundraiser_no, duration))
            
            # Fetch the result
            result = None
            for result_set in cursor.stored_results():
                result = result_set.fetchone()
            
            connection.commit()
            cursor.close()
            connection.close()
            
            if result:
                return {'success': True, 'data': result}
            return {'success': True}
        except Error as e:
            return {'success': False, 'message': str(e)}
    
    def get_donor_interest_analytics(self, donor_id):
        """Get donor interest analytics"""
        connection = self.get_connection()
        if connection is None:
            return []
        
        try:
            cursor = connection.cursor(dictionary=True)
            cursor.callproc('GetDonorInterestAnalytics', (donor_id,))
            
            results = []
            for result_set in cursor.stored_results():
                results = result_set.fetchall()
            
            cursor.close()
            connection.close()
            return results
        except Error as e:
            print(f"Error fetching donor analytics: {e}")
            return []
    
    def get_administrator_earnings(self, admin_id):
        """Get administrator earnings summary"""
        connection = self.get_connection()
        if connection is None:
            return None
        
        try:
            cursor = connection.cursor(dictionary=True)
            cursor.callproc('GetAdministratorEarnings', (admin_id,))
            
            result = None
            for result_set in cursor.stored_results():
                result = result_set.fetchone()
            
            cursor.close()
            connection.close()
            return result
        except Error as e:
            print(f"Error fetching admin earnings: {e}")
            return None
    
    def get_fundraiser_summary(self, fundraiser_no):
        """Get comprehensive fundraiser summary"""
        connection = self.get_connection()
        if connection is None:
            return None
        
        try:
            cursor = connection.cursor(dictionary=True)
            cursor.callproc('GetFundraiserSummary', (fundraiser_no,))
            
            result = None
            for result_set in cursor.stored_results():
                result = result_set.fetchone()
            
            cursor.close()
            connection.close()
            return result
        except Error as e:
            print(f"Error fetching fundraiser summary: {e}")
            return None
    
    def get_platform_statistics(self):
        """Get overall platform statistics"""
        connection = self.get_connection()
        if connection is None:
            return None
        
        try:
            cursor = connection.cursor(dictionary=True)
            cursor.callproc('GetPlatformStatistics', ())
            
            result = None
            for result_set in cursor.stored_results():
                result = result_set.fetchone()
            
            cursor.close()
            connection.close()
            return result
        except Error as e:
            print(f"Error fetching platform stats: {e}")
            return None
    
    def view_visit_history(self, fundraiser_no):
        """View all visits to a fundraiser"""
        connection = self.get_connection()
        if connection is None:
            return []
        
        try:
            cursor = connection.cursor(dictionary=True)
            cursor.callproc('ViewVisitHistory', (fundraiser_no,))
            
            results = []
            for result_set in cursor.stored_results():
                results = result_set.fetchall()
            
            cursor.close()
            connection.close()
            return results
        except Error as e:
            print(f"Error fetching visit history: {e}")
            return []
    
    def view_donor_visits(self, donor_id):
        """View all fundraisers visited by a donor"""
        connection = self.get_connection()
        if connection is None:
            return []
        
        try:
            cursor = connection.cursor(dictionary=True)
            cursor.callproc('ViewDonorVisits', (donor_id,))
            
            results = []
            for result_set in cursor.stored_results():
                results = result_set.fetchall()
            
            cursor.close()
            connection.close()
            return results
        except Error as e:
            print(f"Error fetching donor visits: {e}")
            return []
    
    def view_transaction_details(self, transaction_id):
        """View complete transaction details with payroll link"""
        connection = self.get_connection()
        if connection is None:
            return None
        
        try:
            cursor = connection.cursor(dictionary=True)
            cursor.callproc('ViewTransactionDetails', (transaction_id,))
            
            result = None
            for result_set in cursor.stored_results():
                result = result_set.fetchone()
            
            cursor.close()
            connection.close()
            return result
        except Error as e:
            print(f"Error fetching transaction details: {e}")
            return None
    
    def view_audit_trail(self, fundraiser_no):
        """View complete audit trail for a fundraiser"""
        connection = self.get_connection()
        if connection is None:
            return []
        
        try:
            cursor = connection.cursor(dictionary=True)
            cursor.callproc('ViewAuditTrail', (fundraiser_no,))
            
            results = []
            for result_set in cursor.stored_results():
                results = result_set.fetchall()
            
            cursor.close()
            connection.close()
            return results
        except Error as e:
            print(f"Error fetching audit trail: {e}")
            return []
    
    # ========== DATABASE VIEWS ==========
    
    def get_active_fundraisers_view(self):
        """Query vw_active_fundraisers view"""
        query = "SELECT * FROM vw_active_fundraisers"
        return self.fetch_all(query)
    
    def get_transaction_summary_view(self):
        """Query vw_transaction_summary view"""
        query = "SELECT * FROM vw_transaction_summary"
        return self.fetch_all(query)
    
    def get_donor_engagement_view(self):
        """Query vw_donor_engagement view"""
        query = "SELECT * FROM vw_donor_engagement"
        return self.fetch_all(query)
    
    def get_administrator_dashboard_view(self):
        """Query vw_administrator_dashboard view"""
        query = "SELECT * FROM vw_administrator_dashboard"
        return self.fetch_all(query)
    
    def get_high_interest_donors_view(self):
        """Query vw_high_interest_donors view (donors with 5+ visits)"""
        query = "SELECT * FROM vw_high_interest_donors"
        return self.fetch_all(query)
