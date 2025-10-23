from flask import Flask, render_template, request, redirect, url_for, flash
from db import app, mysql

# ===========================
# HOME / DASHBOARD ROUTE
# ===========================
@app.route('/')
def index():
    return render_template('index.html')


# ===========================
# DASHBOARD / CHART ROUTE
# ===========================
@app.route('/dashboard')
def dashboard():
    cur = mysql.connection.cursor()
    cur.execute("SELECT title, raised_amount, goal_amount FROM Fundraiser")
    fundraisers = cur.fetchall()
    cur.close()
    
    titles = [f[0] for f in fundraisers]
    raised = [float(f[1]) for f in fundraisers]
    goals = [float(f[2]) for f in fundraisers]
    
    return render_template('dashboard.html', titles=titles, raised=raised, goals=goals)


# ===========================
# ADMIN ROUTES
# ===========================
@app.route('/admins')
def admins():
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM Administrator")
    data = cur.fetchall()
    cur.close()
    return render_template('admins.html', admins=data)

@app.route('/add_admin', methods=['GET', 'POST'])
def add_admin():
    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        cur = mysql.connection.cursor()
        cur.execute("CALL AddAdministrator(%s, %s)", (name, email))
        mysql.connection.commit()
        cur.close()
        flash("Administrator added successfully!")
        return redirect(url_for('admins'))
    return render_template('add_admin.html')

@app.route('/update_admin/<int:admin_id>', methods=['GET', 'POST'])
def update_admin(admin_id):
    cur = mysql.connection.cursor()
    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        cur.execute("CALL UpdateAdministrator(%s,%s,%s)", (admin_id, name, email))
        mysql.connection.commit()
        cur.close()
        flash("Administrator updated successfully!")
        return redirect(url_for('admins'))
    cur.execute("SELECT * FROM Administrator WHERE Admin_id = %s", (admin_id,))
    admin = cur.fetchone()
    cur.close()
    return render_template('update_admin.html', admin=admin)

@app.route('/delete_admin/<int:admin_id>', methods=['POST'])
def delete_admin(admin_id):
    cur = mysql.connection.cursor()
    cur.execute("CALL DeleteAdministrator(%s)", (admin_id,))
    mysql.connection.commit()
    cur.close()
    flash("Administrator deleted successfully!")
    return redirect(url_for('admins'))


# ===========================
# DONOR ROUTES
# ===========================
@app.route('/donors')
def donors():
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM Donor")
    data = cur.fetchall()
    cur.close()
    return render_template('donors.html', donors=data)

@app.route('/add_donor', methods=['GET', 'POST'])
def add_donor():
    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        phone = request.form['phone']
        cur = mysql.connection.cursor()
        cur.execute("CALL AddDonor(%s,%s,%s)", (name, email, phone))
        mysql.connection.commit()
        cur.close()
        flash("Donor added successfully!")
        return redirect(url_for('donors'))
    return render_template('add_donor.html')

@app.route('/update_donor/<int:donor_id>', methods=['GET', 'POST'])
def update_donor(donor_id):
    cur = mysql.connection.cursor()
    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        phone = request.form['phone']
        cur.execute("CALL UpdateDonor(%s,%s,%s,%s)", (donor_id, name, email, phone))
        mysql.connection.commit()
        cur.close()
        flash("Donor updated successfully!")
        return redirect(url_for('donors'))
    cur.execute("SELECT * FROM Donor WHERE donor_id = %s", (donor_id,))
    donor = cur.fetchone()
    cur.close()
    return render_template('update_donor.html', donor=donor)

@app.route('/delete_donor/<int:donor_id>', methods=['POST'])
def delete_donor(donor_id):
    cur = mysql.connection.cursor()
    cur.execute("CALL DeleteDonor(%s)", (donor_id,))
    mysql.connection.commit()
    cur.close()
    flash("Donor deleted successfully!")
    return redirect(url_for('donors'))


# ===========================
# FUNDRAISER ROUTES
# ===========================
@app.route('/fundraisers')
def fundraisers():
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM Fundraiser")
    data = cur.fetchall()
    cur.close()
    return render_template('fundraisers.html', fundraisers=data)

@app.route('/add_fundraiser', methods=['GET', 'POST'])
def add_fundraiser():
    if request.method == 'POST':
        admin_id = request.form['admin_id']
        bank_details = request.form['bank_details']
        title = request.form['title']
        description = request.form['description']
        goal_amount = request.form['goal_amount']
        deadline = request.form['deadline']
        status = request.form['status']
        owner_name = request.form['owner_name']
        cur = mysql.connection.cursor()
        cur.execute("CALL AddFundraiser(%s,%s,%s,%s,%s,%s,%s,%s)",
                    (admin_id, bank_details, title, description, goal_amount, deadline, status, owner_name))
        mysql.connection.commit()
        cur.close()
        flash("Fundraiser added successfully!")
        return redirect(url_for('fundraisers'))
    cur = mysql.connection.cursor()
    cur.execute("SELECT Admin_id, name FROM Administrator")
    admins = cur.fetchall()
    cur.close()
    return render_template('add_fundraiser.html', admins=admins)

@app.route('/update_fundraiser/<int:fundraiser_no>', methods=['GET', 'POST'])
def update_fundraiser(fundraiser_no):
    cur = mysql.connection.cursor()
    if request.method == 'POST':
        title = request.form['title']
        description = request.form['description']
        goal_amount = request.form['goal_amount']
        deadline = request.form['deadline']
        status = request.form['status']
        owner_name = request.form['owner_name']
        cur.execute("CALL UpdateFundraiser(%s,%s,%s,%s,%s,%s,%s)",
                    (fundraiser_no, title, description, goal_amount, deadline, status, owner_name))
        mysql.connection.commit()
        cur.close()
        flash("Fundraiser updated successfully!")
        return redirect(url_for('fundraisers'))
    cur.execute("SELECT * FROM Fundraiser WHERE fundraiser_no = %s", (fundraiser_no,))
    fundraiser = cur.fetchone()
    cur.execute("SELECT Admin_id, name FROM Administrator")
    admins = cur.fetchall()
    cur.close()
    return render_template('update_fundraiser.html', fundraiser=fundraiser, admins=admins)

@app.route('/delete_fundraiser/<int:fundraiser_no>', methods=['POST'])
def delete_fundraiser(fundraiser_no):
    cur = mysql.connection.cursor()
    cur.execute("CALL DeleteFundraiser(%s)", (fundraiser_no,))
    mysql.connection.commit()
    cur.close()
    flash("Fundraiser deleted successfully!")
    return redirect(url_for('fundraisers'))


# ===========================
# TRANSACTIONS ROUTES
# ===========================
@app.route('/transactions')
def transactions():
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM Transactions")
    data = cur.fetchall()
    cur.close()
    return render_template('transactions.html', transactions=data)

@app.route('/add_transaction', methods=['GET', 'POST'])
def add_transaction():
    if request.method == 'POST':
        donor_id = request.form['donor_id']
        fundraiser_no = request.form['fundraiser_no']
        amount = request.form['amount']
        payment_mode = request.form['payment_mode']
        transaction_date = request.form['transaction_date']
        cur = mysql.connection.cursor()
        cur.execute("CALL AddTransaction(%s,%s,%s,%s,%s)",
                    (donor_id, fundraiser_no, amount, payment_mode, transaction_date))
        mysql.connection.commit()
        cur.close()
        flash("Transaction added successfully!")
        return redirect(url_for('transactions'))
    cur = mysql.connection.cursor()
    cur.execute("SELECT donor_id, dname FROM Donor")
    donors = cur.fetchall()
    cur.execute("SELECT fundraiser_no, title FROM Fundraiser")
    fundraisers = cur.fetchall()
    cur.close()
    return render_template('add_transaction.html', donors=donors, fundraisers=fundraisers)

@app.route('/delete_transaction/<int:transaction_id>', methods=['POST'])
def delete_transaction(transaction_id):
    cur = mysql.connection.cursor()
    cur.execute("CALL DeleteTransaction(%s)", (transaction_id,))
    mysql.connection.commit()
    cur.close()
    flash("Transaction deleted successfully!")
    return redirect(url_for('transactions'))


# ===========================
# PAYROLL ROUTES
# ===========================
@app.route('/payrolls')
def payrolls():
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM Payroll")
    data = cur.fetchall()
    cur.close()
    return render_template('payrolls.html', payrolls=data)

@app.route('/add_payroll', methods=['GET', 'POST'])
def add_payroll():
    if request.method == 'POST':
        admin_id = request.form['admin_id']
        fundraiser_no = request.form['fundraiser_no']
        payout_date = request.form['payout_date']
        amount_released = request.form['amount_released']
        cur = mysql.connection.cursor()
        cur.execute("CALL AddPayroll(%s,%s,%s,%s)", (admin_id, fundraiser_no, payout_date, amount_released))
        mysql.connection.commit()
        cur.close()
        flash("Payroll added successfully!")
        return redirect(url_for('payrolls'))
    cur = mysql.connection.cursor()
    cur.execute("SELECT Admin_id, name FROM Administrator")
    admins = cur.fetchall()
    cur.execute("SELECT fundraiser_no, title FROM Fundraiser")
    fundraisers = cur.fetchall()
    cur.close()
    return render_template('add_payroll.html', admins=admins, fundraisers=fundraisers)


# ===========================
# VISITS ROUTES
# ===========================
@app.route('/visits')
def visits():
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM Visits")
    data = cur.fetchall()
    cur.close()
    return render_template('visits.html', visits=data)

@app.route('/add_visit', methods=['GET', 'POST'])
def add_visit():
    if request.method == 'POST':
        donor_id = request.form['donor_id']
        fundraiser_no = request.form['fundraiser_no']
        visit_date = request.form['visit_date']
        duration = request.form['duration']
        interest_level = request.form['interest_level']
        cur = mysql.connection.cursor()
        cur.execute("CALL AddVisit(%s,%s,%s,%s,%s)",
                    (donor_id, fundraiser_no, visit_date, duration, interest_level))
        mysql.connection.commit()
        cur.close()
        flash("Visit added successfully!")
        return redirect(url_for('visits'))
    cur = mysql.connection.cursor()
    cur.execute("SELECT donor_id, dname FROM Donor")
    donors = cur.fetchall()
    cur.execute("SELECT fundraiser_no, title FROM Fundraiser")
    fundraisers = cur.fetchall()
    cur.close()
    return render_template('add_visit.html', donors=donors, fundraisers=fundraisers)


# ===========================
# RUN APP
# ===========================
if __name__ == "__main__":
    app.run(debug=True)
