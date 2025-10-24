from flask import Flask, render_template, request, redirect, url_for, flash
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
    return render_template('donor_details.html', donor=donor, transactions=transactions, visits=visits)

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
    fundraiser = db.get_fundraiser(fundraiser_no)
    transactions = db.get_fundraiser_transactions(fundraiser_no)
    payrolls = db.get_fundraiser_payrolls(fundraiser_no)
    visits = db.get_fundraiser_visits(fundraiser_no)
    return render_template('fundraiser_details.html', fundraiser=fundraiser, transactions=transactions, payrolls=payrolls, visits=visits)

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
        transaction_date = request.form.get('transaction_date')
        
        result = db.add_transaction(donor_id, fundraiser_no, amount, payment_mode, transaction_date)
        if result['success']:
            flash('Transaction recorded successfully!', 'success')
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

@app.route('/payroll/add', methods=['GET', 'POST'])
def add_payroll():
    if request.method == 'POST':
        admin_id = request.form.get('admin_id')
        fundraiser_no = request.form.get('fundraiser_no')
        amount_released = request.form.get('amount_released')
        payout_date = request.form.get('payout_date')
        
        result = db.add_payroll(admin_id, fundraiser_no, payout_date, amount_released)
        if result['success']:
            flash('Payroll processed successfully!', 'success')
            return redirect(url_for('payroll'))
        else:
            flash(f'Error: {result["message"]}', 'danger')
    
    admins = db.get_all_administrators()
    fundraisers_list = db.get_all_fundraisers()
    return render_template('add_payroll.html', admins=admins, fundraisers=fundraisers_list)

@app.route('/visits')
def visits():
    visits_list = db.get_all_visits()
    return render_template('visits.html', visits=visits_list)

@app.route('/visits/add', methods=['GET', 'POST'])
def add_visit():
    if request.method == 'POST':
        donor_id = request.form.get('donor_id')
        fundraiser_no = request.form.get('fundraiser_no')
        visit_date = request.form.get('visit_date')
        duration = request.form.get('duration')
        interest_level = request.form.get('interest_level')
        
        result = db.add_visit(donor_id, fundraiser_no, visit_date, duration, interest_level)
        if result['success']:
            flash('Visit recorded successfully!', 'success')
            return redirect(url_for('visits'))
        else:
            flash(f'Error: {result["message"]}', 'danger')
    
    donors_list = db.get_all_donors()
    fundraisers_list = db.get_all_fundraisers()
    return render_template('add_visit.html', donors=donors_list, fundraisers=fundraisers_list)

@app.route('/visits/edit/<int:visit_id>', methods=['GET', 'POST'])
def edit_visit(visit_id):
    if request.method == 'POST':
        duration = request.form.get('duration')
        interest_level = request.form.get('interest_level')
        
        result = db.update_visit(visit_id, duration, interest_level)
        if result['success']:
            flash('Visit updated successfully!', 'success')
            return redirect(url_for('visits'))
        else:
            flash(f'Error: {result["message"]}', 'danger')
    
    visit = db.get_visit(visit_id)
    return render_template('edit_visit.html', visit=visit)

@app.route('/visits/delete/<int:visit_id>')
def delete_visit(visit_id):
    result = db.delete_visit(visit_id)
    if result['success']:
        flash('Visit deleted successfully!', 'success')
    else:
        flash(f'Error: {result["message"]}', 'danger')
    return redirect(url_for('visits'))

@app.route('/reports')
def reports():
    top_donors = db.get_top_donors()
    fundraiser_progress = db.get_fundraiser_progress()
    return render_template('reports.html', top_donors=top_donors, fundraiser_progress=fundraiser_progress)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
