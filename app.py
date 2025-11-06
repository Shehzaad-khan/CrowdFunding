from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
from database import Database
from datetime import datetime
import os

app = Flask(__name__)
app.secret_key = os.getenv('SESSION_SECRET', 'your-secret-key-here')

db = Database()

@app.route('/')
def index():
    stats = db.get_dashboard_stats()
    recent_transactions = db.get_recent_transactions()
    top_fundraisers = db.get_top_fundraisers()
    return render_template('index.html', stats=stats, recent_transactions=recent_transactions, top_fundraisers=top_fundraisers)

@app.route('/administrators')
def administrators():
    admins = db.get_all_administrators()
    return render_template('administrators.html', admins=admins)

@app.route('/administrators/add', methods=['GET', 'POST'])
def add_administrator():
    if request.method == 'POST':
        name = request.form.get('name')
        email = request.form.get('email')
        phone = request.form.get('phone')
        
        result = db.add_administrator(name, email, phone)
        if result['success']:
            flash('Administrator added successfully!', 'success')
            return redirect(url_for('administrators'))
        else:
            flash(f'Error: {result["message"]}', 'danger')
    
    return render_template('add_administrator.html')

@app.route('/administrators/edit/<int:admin_id>', methods=['GET', 'POST'])
def edit_administrator(admin_id):
    if request.method == 'POST':
        name = request.form.get('name')
        email = request.form.get('email')
        
        result = db.update_administrator(admin_id, name, email)
        if result['success']:
            flash('Administrator updated successfully!', 'success')
            return redirect(url_for('administrators'))
        else:
            flash(f'Error: {result["message"]}', 'danger')
    
    admin = db.get_administrator(admin_id)
    return render_template('edit_administrator.html', admin=admin)

@app.route('/administrators/delete/<int:admin_id>')
def delete_administrator(admin_id):
    result = db.delete_administrator(admin_id)
    if result['success']:
        flash('Administrator deleted successfully!', 'success')
    else:
        flash(f'Error: {result["message"]}', 'danger')
    return redirect(url_for('administrators'))

@app.route('/administrators/<int:admin_id>/add_phone', methods=['POST'])
def add_admin_phone(admin_id):
    phone = request.form.get('phone')
    result = db.add_admin_phone(admin_id, phone)
    if result['success']:
        flash('Phone number added successfully!', 'success')
    else:
        flash(f'Error: {result["message"]}', 'danger')
    return redirect(url_for('edit_administrator', admin_id=admin_id))

@app.route('/donors')
def donors():
    donors_list = db.get_all_donors()
    return render_template('donors.html', donors=donors_list)

@app.route('/donors/add', methods=['GET', 'POST'])
def add_donor():
    if request.method == 'POST':
        name = request.form.get('name')
        email = request.form.get('email')
        phone = request.form.get('phone')
        
        result = db.add_donor(name, email, phone)
        if result['success']:
            flash('Donor added successfully!', 'success')
            return redirect(url_for('donors'))
        else:
            flash(f'Error: {result["message"]}', 'danger')
    
    return render_template('add_donor.html')

@app.route('/donors/edit/<int:donor_id>', methods=['GET', 'POST'])
def edit_donor(donor_id):
    if request.method == 'POST':
        name = request.form.get('name')
        email = request.form.get('email')
        phone = request.form.get('phone')
        
        result = db.update_donor(donor_id, name, email, phone)
        if result['success']:
            flash('Donor updated successfully!', 'success')
            return redirect(url_for('donors'))
        else:
            flash(f'Error: {result["message"]}', 'danger')
    
    donor = db.get_donor(donor_id)
    return render_template('edit_donor.html', donor=donor)

@app.route('/donors/delete/<int:donor_id>')
def delete_donor(donor_id):
    result = db.delete_donor(donor_id)
    if result['success']:
        flash('Donor deleted successfully!', 'success')
    else:
        flash(f'Error: {result["message"]}', 'danger')
    return redirect(url_for('donors'))

@app.route('/donors/<int:donor_id>')
def donor_details(donor_id):
    donor = db.get_donor(donor_id)
    transactions = db.get_donor_transactions(donor_id)
    visits = db.get_donor_visits(donor_id)
    analytics = db.get_donor_interest_analytics(donor_id)
    # Get all active fundraisers for the donor to explore
    available_fundraisers = db.fetch_all(
        """SELECT f.fundraiser_no, f.title, f.description, f.goal_amount, f.raised_amount, 
                  f.deadline, f.status, 
                  ROUND((f.raised_amount / f.goal_amount * 100), 2) as progress
           FROM Fundraiser f
           WHERE f.status = 'Active'
           ORDER BY f.deadline ASC"""
    )
    return render_template('donor_details.html', donor=donor, transactions=transactions, 
                         visits=visits, analytics=analytics, available_fundraisers=available_fundraisers)

@app.route('/fundraisers')
def fundraisers():
    fundraisers_list = db.get_all_fundraisers()
    return render_template('fundraisers.html', fundraisers=fundraisers_list)

@app.route('/fundraisers/add', methods=['GET', 'POST'])
def add_fundraiser():
    if request.method == 'POST':
        admin_id = request.form.get('admin_id')
        bank_details = request.form.get('bank_details')
        title = request.form.get('title')
        description = request.form.get('description')
        goal_amount = request.form.get('goal_amount')
        deadline = request.form.get('deadline')
        status = request.form.get('status')
        fundraiser_owner_name = request.form.get('fundraiser_owner_name')
        
        result = db.add_fundraiser(admin_id, bank_details, title, description, goal_amount, deadline, status, fundraiser_owner_name)
        if result['success']:
            flash('Fundraiser created successfully!', 'success')
            return redirect(url_for('fundraisers'))
        else:
            flash(f'Error: {result["message"]}', 'danger')
    
    admins = db.get_all_administrators()
    return render_template('add_fundraiser.html', admins=admins)

@app.route('/fundraisers/edit/<int:fundraiser_no>', methods=['GET', 'POST'])
def edit_fundraiser(fundraiser_no):
    if request.method == 'POST':
        title = request.form.get('title')
        description = request.form.get('description')
        goal_amount = request.form.get('goal_amount')
        deadline = request.form.get('deadline')
        status = request.form.get('status')
        fundraiser_owner_name = request.form.get('fundraiser_owner_name')
        
        result = db.update_fundraiser(fundraiser_no, title, description, goal_amount, deadline, status, fundraiser_owner_name)
        if result['success']:
            flash('Fundraiser updated successfully!', 'success')
            return redirect(url_for('fundraisers'))
        else:
            flash(f'Error: {result["message"]}', 'danger')
    
    fundraiser = db.get_fundraiser(fundraiser_no)
    return render_template('edit_fundraiser.html', fundraiser=fundraiser)

@app.route('/fundraisers/delete/<int:fundraiser_no>')
def delete_fundraiser(fundraiser_no):
    result = db.delete_fundraiser(fundraiser_no)
    if result['success']:
        flash('Fundraiser deleted successfully!', 'success')
    else:
        flash(f'Error: {result["message"]}', 'danger')
    return redirect(url_for('fundraisers'))

@app.route('/fundraisers/<int:fundraiser_no>')
def fundraiser_details(fundraiser_no):
    # Get donor_id from session or query parameter for visit tracking
    donor_id = request.args.get('donor_id', type=int)
    
    # Record visit if donor_id is provided
    if donor_id:
        db.record_fundraiser_visit(donor_id, fundraiser_no, 5)  # Default 5 min duration
    
    fundraiser = db.get_fundraiser(fundraiser_no)
    summary = db.get_fundraiser_summary(fundraiser_no)
    transactions = db.get_fundraiser_transactions(fundraiser_no)
    payrolls = db.get_fundraiser_payrolls(fundraiser_no)
    visits = db.get_fundraiser_visits(fundraiser_no)
    return render_template('fundraiser_details.html', fundraiser=fundraiser, summary=summary, transactions=transactions, payrolls=payrolls, visits=visits)

@app.route('/transactions')
def transactions():
    transactions_list = db.get_all_transactions()
    return render_template('transactions.html', transactions=transactions_list)

@app.route('/transactions/add', methods=['GET', 'POST'])
def add_transaction():
    if request.method == 'POST':
        donor_id = request.form.get('donor_id')
        fundraiser_no = request.form.get('fundraiser_no')
        amount = request.form.get('amount')
        payment_mode = request.form.get('payment_mode')
        
        result = db.process_donation(donor_id, fundraiser_no, amount, payment_mode)
        if result['success']:
            if 'data' in result:
                data = result['data']
                flash(f'Donation processed successfully! Platform fee: ₹{data.get("Platform_Fee_1_Percent", 0):.2f} | Admin receives: ₹{data.get("Admin_Receives_Via_Payroll", 0):.2f}', 'success')
            else:
                flash('Donation processed successfully!', 'success')
            return redirect(url_for('transactions'))
        else:
            flash(f'Error: {result["message"]}', 'danger')
    
    donors_list = db.get_all_donors()
    fundraisers_list = db.get_all_fundraisers()
    return render_template('add_transaction.html', donors=donors_list, fundraisers=fundraisers_list)

@app.route('/payroll')
def payroll():
    payroll_list = db.get_all_payroll()
    return render_template('payroll.html', payroll=payroll_list)

@app.route('/administrators/<int:admin_id>/earnings')
def admin_earnings(admin_id):
    admin = db.get_administrator(admin_id)
    earnings = db.get_administrator_earnings(admin_id)
    payrolls = db.fetch_all(
        "SELECT p.*, f.title as fundraiser_title FROM Payroll p JOIN Fundraiser f ON p.fundraiser_no = f.fundraiser_no WHERE p.Admin_id = %s ORDER BY p.payout_date DESC",
        (admin_id,)
    )
    return render_template('admin_earnings.html', admin=admin, earnings=earnings, payrolls=payrolls)

@app.route('/visits')
def visits():
    visits_list = db.get_all_visits()
    return render_template('visits.html', visits=visits_list)

@app.route('/record_visit', methods=['POST'])
def record_visit():
    """API endpoint to record visits via AJAX"""
    donor_id = request.form.get('donor_id', type=int)
    fundraiser_no = request.form.get('fundraiser_no', type=int)
    duration = request.form.get('duration', type=int, default=5)
    
    if donor_id and fundraiser_no:
        result = db.record_fundraiser_visit(donor_id, fundraiser_no, duration)
        if result['success']:
            return jsonify({'success': True, 'data': result.get('data', {})})
        else:
            return jsonify({'success': False, 'message': result.get('message', 'Failed to record visit')})
    return jsonify({'success': False, 'message': 'Missing parameters'})

@app.route('/reports')
def reports():
    top_donors = db.get_top_donors()
    fundraiser_progress = db.get_fundraiser_progress()
    platform_stats = db.get_platform_statistics()
    high_interest_donors = db.get_high_interest_donors_view()
    return render_template('reports.html', top_donors=top_donors, fundraiser_progress=fundraiser_progress, 
                         platform_stats=platform_stats, high_interest_donors=high_interest_donors)

@app.route('/fundraisers/<int:fundraiser_no>/audit')
def fundraiser_audit(fundraiser_no):
    fundraiser = db.get_fundraiser(fundraiser_no)
    audit_trail = db.view_audit_trail(fundraiser_no)
    visit_history = db.view_visit_history(fundraiser_no)
    return render_template('fundraiser_audit.html', fundraiser=fundraiser, audit_trail=audit_trail, visit_history=visit_history)

@app.route('/transactions/<int:transaction_id>/details')
def transaction_details(transaction_id):
    details = db.view_transaction_details(transaction_id)
    return render_template('transaction_details.html', transaction=details)

@app.route('/analytics/views')
def analytics_views():
    active_fundraisers = db.get_active_fundraisers_view()
    transaction_summary = db.get_transaction_summary_view()
    donor_engagement = db.get_donor_engagement_view()
    admin_dashboard = db.get_administrator_dashboard_view()
    return render_template('analytics_views.html', 
                         active_fundraisers=active_fundraisers,
                         transaction_summary=transaction_summary,
                         donor_engagement=donor_engagement,
                         admin_dashboard=admin_dashboard)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
