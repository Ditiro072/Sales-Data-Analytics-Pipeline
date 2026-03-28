import pyodbc
import pandas as pd
from config import DB_CONFIG

# Connecting
def connect_db():
    return pyodbc.connect(
        f"DRIVER={{{DB_CONFIG['driver']}}};"
        f"SERVER={DB_CONFIG['server']};"
        f"DATABASE={DB_CONFIG['database']};"
        f"Trusted_Connection={DB_CONFIG['trusted_connection']};"
        "TrustServerCertificate=yes;"
    )

# for Extraction
def extract_data(conn):
    df = pd.read_sql("SELECT * FROM Orders", conn)
    print("Extracted rows:", len(df))
    return df

# To TRANSFORM
def transform_data(df):

    # Fixing data
    df['OrderDate'] = pd.to_datetime(df['OrderDate'], errors='coerce')
    df['TotalAmount'] = pd.to_numeric(df['TotalAmount'], errors='coerce')

    # Handling nulls
    df['Quantity'] = df['Quantity'].fillna(0)
    df['TotalAmount'] = df['TotalAmount'].fillna(0)

    # Remove bad rows
    df = df.dropna(subset=['OrderDate'])

    # Add columns
    df['Year'] = df['OrderDate'].dt.year
    df['Month'] = df['OrderDate'].dt.month

    df['Cost'] = df['TotalAmount'] * 0.7
    df['Profit'] = df['TotalAmount'] * 0.3

    print("Clean rows:", len(df))
    return df

# Now we LOAD.
def load_data(conn, df):
    cursor = conn.cursor()

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

# Insert new data
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
    conn = connect_db()
    df = extract_data(conn)
    df = transform_data(df)
    load_data(conn, df)

if __name__ == "__main__":
    run()

    