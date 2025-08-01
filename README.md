# 🧠 Customer Churn Analysis — Real-World SQL + Python Project

Welcome to a hands-on project that simulates real-world data challenges — from raw data ingestion to drawing meaningful insights that support **business decision-making**.

📍 **GitHub Repository:** [customer-churn-analysis](https://github.com/HeatTransfer/customer-churn-analysis/tree/main)

---

## 📌 Project Objectives

✅ Ingest messy, real-life-like data
✅ Clean and preprocess using **Python (Pandas)**
✅ Load structured data into **SQL Server**
✅ Transform and correct business logic in SQL
✅ Analyze customer behavior, churn patterns, and retention
✅ Summarize insights for decision-makers

---

## 🧰 Tools & Technologies

* **Python** (Pandas, NumPy)
* **SQL Server (T-SQL)**
* **SQLAlchemy** for DB connections
* **Jupyter Notebook** for analysis and documentation
* **Matplotlib / Seaborn** for visualization (optional)
* **GitHub** for version control

---

## 📂 Project Structure

```
customer-churn-analysis/
│
├── data/                    # Raw & messy input data (CSV, tsv, json)
├── project-env/             # python virtual environment
├── SQL Codes/               # SQL DDL, DML, transformations & analysis
├── SQL_Output_Tables/       # Files to analyze/visualize in Python after SQL analysis
├── py_cleaning_eda.ipynb    # python notebook for initial dat cleaning and EDA
├── py_analysis.ipynb        # python notebook to visualize reports from SQL analysis
├── requirements.txt         # required python libraries for analysis
└── README.md
```

---

## 🔄 Workflow Overview

### 1. **Data Ingestion & Cleaning (Python)**

* Loaded messy datasets from CSV, tsv & json formats
* Fixed data types, nulls, duplicate entries
* Aligned columns for SQL import

### 2. **Data Modeling & Loading (SQL Server)**

* Created normalized tables: `customers`, `subscription`, `product_usage`, `support_tickets`
* Loaded cleaned data using SQLAlchemy

### 3. **SQL-Based Transformation & Fixes**

* Fixed logical issues like:

  * `end_date` earlier than `start_date`
  * Feature usage before signup
* Added validation logic

### 4. **Data Analysis (SQL)**

* Identified churned customers
* Conducted **cohort analysis** to track retention over months
* Measured the impact of:

  * Product feature usage
  * Support ticket resolution
* Created a churn flag and compared against engagement metrics

---

## 📊 Key Business Insights

* 📉 **Feature usage in the last 30 days** moderately correlates with reduced churn
* ⏱️ **Unresolved tickets** have weak/no significant impact on churn
* 🔁 **April 2023 cohort** had the **highest long-term retention**
* 📆 Many customers churn within the **first 3–4 months** post-signup

---

## 🚀 How to Run

1. Clone the repo:

   ```bash
   git clone https://github.com/HeatTransfer/customer-churn-analysis.git
   ```
2. Set up Python environment and install dependencies
3. Run notebooks to ingest and clean data
4. Execute SQL scripts under `/sql_scripts` in SQL Server
5. Explore analysis and observations

---

## 📌 Author

**Shreyajyoti Dutta**
🔗 [LinkedIn Profile](https://www.linkedin.com/in/shreyajyoti-dutta)
📫 Open to opportunities in Data Analytics, Data Engineering, and BI

---

## 🏷️ Tags

`SQL` `Python` `Data Engineering` `Churn Prediction` `Cohort Analysis` `ETL` `Business Insights` `Data Analytics`
