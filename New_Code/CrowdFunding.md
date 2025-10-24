# 💰 Crowdfunding Database Management System

## 📖 Overview
A **Flask-based web application** for managing a crowdfunding platform with complete CRUD operations for:
- Administrators  
- Donors  
- Fundraisers  
- Transactions  
- Payroll  
- Visit tracking  

---

## 🆕 Recent Changes (October 24, 2025)
- ✅ Created complete Flask web application from scratch  
- ✅ Implemented all database tables from user's SQL schema  
- ✅ Integrated all stored procedures from the MySQL database  
- ✅ Built responsive UI using **Bootstrap 5**  
- ✅ Fixed critical `None`-handling bug in dashboard statistics  
- ✅ Configured Flask workflow to run on **port 5000**

---

## 🏗️ Project Architecture

### 🔹 Backend (Python / Flask)
- **`app.py`** — Main Flask application containing all routes and view functions  
- **`database.py`** — Database connection module using MySQL integration  
  - Uses `mysql-connector-python` for database connectivity  
  - Implements all stored procedures from the SQL schema  
  - Handles connection pooling and error management  

### 🔹 Frontend (HTML / CSS / Bootstrap)
- **Base Template:** `templates/base.html` → Navigation and layout  
- **Dashboard:** `templates/index.html` → Statistics and overview page  
- **Entity Management Templates:** CRUD interfaces for all entities  
- **Static Assets:** `static/css/style.css` → Custom styling  

---

## 🗄️ Database Integration

The application uses **all stored procedures** from the SQL schema:

| Entity | Stored Procedures |
|--------|--------------------|
| **Administrator** | `AddAdministrator`, `UpdateAdministrator`, `DeleteAdministrator`, `AddAdminPhone` |
| **Donor** | `AddDonor`, `UpdateDonor`, `DeleteDonor` |
| **Fundraiser** | `AddFundraiser`, `UpdateFundraiser`, `DeleteFundraiser` |
| **Transaction** | `AddTransaction` *(auto updates `raised_amount` via trigger)* |
| **Payroll** | `AddPayroll` *(auto closes fundraiser when completed)* |
| **Visit** | `AddVisit`, `UpdateVisit`, `DeleteVisit` |

---

## ⚙️ Triggers Implemented (in MySQL)
- Auto-update **raised amount** on transaction insert  
- Reverse **raised amount** on transaction delete  
- Prevent **overfunding** (donation exceeds goal)  
- Remove **donor’s visits and transactions** when deleted  
- Auto-close **fundraiser** when goal is reached via payroll  
- Auto-create **payroll** when fundraiser marked as “Completed”  

---

## ✨ Features
- 📊 **Dashboard:** Real-time statistics, recent transactions, top fundraisers  
- 👨‍💼 **Administrator Management:** Add, edit, delete admins and phone numbers  
- 🙋 **Donor Management:** Full CRUD with transaction and visit history  
- 🎯 **Fundraiser Management:** Track progress and manage fundraiser status  
- 💸 **Transaction Processing:** Record donations with automatic updates  
- 🧾 **Payroll System:** Release funds with automatic status handling  
- 👁️ **Visit Tracking:** Monitor donor engagement  
- 📈 **Reports & Analytics:** Top donors, fundraiser progress, performance metrics  

---

## 🔐 Environment Variables

Create a `.env` file in your project root with the following content:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=CrowdfundingDB
SESSION_SECRET=your-secret-key

## 🧬 Database Schema

The application expects a **MySQL database** with the following tables:

- `Administrator`
- `Admins_phone`
- `Donor`
- `Fundraiser`
- `Transactions`
- `Payroll`
- `Visits`

---

## 🛠️ Technology Stack

| Layer | Technology |
|-------|-------------|
| **Backend** | Flask 3.1.2, Python 3.11 |
| **Database** | MySQL with `mysql-connector-python` 9.5.0 |
| **Frontend** | Bootstrap 5, HTML5, CSS3 |
| **Config** | `python-dotenv` for environment management |

---

## 🚀 Workflow

- Flask server runs on **port 5000**, serving the web application  
- Access the application at:  
  🔗 [http://0.0.0.0:5000](http://0.0.0.0:5000)

---

## 🛡️ Security

- Session secrets managed via **environment variables**  
- SQL injection prevented through **parameterized queries**  
- CSRF protection via **Flask's built-in security mechanisms**

---

## ⚠️ Known Issues

- LSP type-checking warnings (not runtime errors) for dictionary access patterns  
- Database connection requires **manual MySQL setup** using the provided schema  
