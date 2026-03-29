import pyodbc
import pandas as pd
from config import DB_CONFIG
import logging

# Track pipeline execution(the success, failures, row counts).And helps debug (and is standard in production ETL pipelines)
logging.basicConfig(
    filename='etl.log',   #This part logs the file name,
    level=logging.INFO,   #This one  logs level like for example(INFO, ERROR, etc......)
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# Connecting
def connect_db():
    return pyodbc.connect(
        f"DRIVER={{{DB_CONFIG['driver']}}};"
        f"SERVER={DB_CONFIG['server']};"
        f"DATABASE={DB_CONFIG['database']};"
        f"UID={DB_CONFIG['uid']};"
        f"PWD={DB_CONFIG['pwd']};"
        "TrustServerCertificate=yes;"
    )
# for Extraction
def extract_data(conn):
    df = pd.read_sql("SELECT * FROM Orders", conn)
    logging.info(f"Extracted rows: {len(df)}")  # log extracted rows
    return df

# To TRANSFORM
def transform_data(df):

    print("Cleaning DATa............!!!")

    # Fixing data
    df['OrderDate'] = pd.to_datetime(df['OrderDate'], errors='coerce')
    df['TotalAmount'] = pd.to_numeric(df['TotalAmount'], errors='coerce')

    # Handling nulls
    df['Quantity'] = df['Quantity'].fillna(0)
    df['TotalAmount'] = df['TotalAmount'].fillna(0)

    # Remove bad rows (IMPORTANT: must use .copy() not .copy)
    df = df.dropna(subset=['OrderDate']).copy()

    # Add columns
    df['Year'] = df['OrderDate'].dt.year
    df['Month'] = df['OrderDate'].dt.month

    # Business calculations
    df['Cost'] = df['TotalAmount'] * 0.7
    df['Profit'] = df['TotalAmount'] * 0.3

    logging.info(f"Clean rows: {len(df)}")  # log cleaned rows

    # EXPORT CLEAN DATA (for debugging, sharing, external tools like Excel/Power BI)
    df.to_csv("clean_data.csv", index=False)

    return df

# Now we LOAD.
def load_data(conn, df):
    cursor = conn.cursor()

    # Create table if it does not exist
    cursor.execute("""
    IF OBJECT_ID('CleanOrders_Python', 'U') IS NULL
    CREATE TABLE CleanOrders_Python (
        OrderID INT,
        CustomerID INT,
        ProductID INT,
        OrderDate DATE,
        Quantity INT,
        TotalAmount FLOAT,
        Year INT,
        Month INT,
        Cost FLOAT,
        Profit FLOAT
    )
    """)
    conn.commit()

    # Clear old data
    cursor.execute("DELETE FROM CleanOrders_Python")
    conn.commit()

    # Insert new data row by row
    for _, row in df.iterrows():
        cursor.execute("""
        INSERT INTO CleanOrders_Python
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        int(row.OrderID),
        int(row.CustomerID),
        int(row.ProductID),
        row.OrderDate,
        int(row.Quantity),
        float(row.TotalAmount),
        int(row.Year),
        int(row.Month),
        float(row.Cost),
        float(row.Profit)
        )

    conn.commit()
    print("Data loaded!")

# Running the Pipeline;.
def run():
    try:
        logging.info("ETL process started")  # start log

        conn = connect_db()
        logging.info("Connected to database")  # connection log

        df = extract_data(conn)
        df = transform_data(df)
        load_data(conn, df)

        logging.info("ETL SUCCESS")  # success log

    except Exception as e:
        logging.error(f"ETL FAILED: {str(e)}")  # error log
        print("ERROR:", e)

if __name__ == "__main__":
    run()
    