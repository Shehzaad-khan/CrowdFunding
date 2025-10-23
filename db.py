from flask_mysqldb import MySQL
from flask import Flask

app = Flask(__name__)
app.secret_key = "your_secret_key"

# MySQL config
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Shiva@12345'
app.config['MYSQL_DB'] = 'CrowdfundingDB'

mysql = MySQL(app)
