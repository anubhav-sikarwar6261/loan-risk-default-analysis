# Credit Risk & Loan Default Analysis

## Project Overview

This project analyzes historical loan application data using **PostgreSQL and Power BI** to understand default patterns across borrower and loan characteristics.

The project also introduces a **transparent, rule-based risk scoring framework** to prioritize applications for manual review.

> This project is an analytical and decision-support exercise. The risk score is rule-based and is not a machine-learning default prediction model.

---

## Business Problem

Financial institutions need to understand which borrower and loan characteristics are associated with higher historical default rates.

This project focuses on the following questions:

- Which borrower characteristics are associated with higher historical default rates?
- How do DTI, FICO score, income, employment length and loan characteristics relate to default?
- Which applications meet the project-defined criteria for additional manual review?
- Can SQL and Power BI be used to turn these findings into an interactive risk analysis dashboard?

---

## Tools & Technologies

- **PostgreSQL** – Data preparation, transformation and analysis
- **SQL** – Aggregation, segmentation, risk scoring and analytical queries
- **Power BI** – Interactive dashboard and visualization
- **GitHub** – Project documentation and portfolio management

---

## Dataset

The cleaned dataset contains **272,650 loan applications** and includes borrower, loan and application-level attributes.

### Main Columns

- Application ID
- Loan Amount
- Interest Rate
- Loan Term
- Grade
- Employment Length
- Home Ownership
- Annual Income
- Verification Status
- Loan Status
- Loan Purpose
- State
- DTI
- Delinquencies
- Revolving Utilization
- Application Type
- FICO Score

---

## Data Preparation & Feature Engineering

SQL was used to prepare the analytical dataset and create additional fields.

### Default Flag

A binary `default_flag` was created from the historical loan status:

- `1` = Default
- `0` = Non-default

### Income Band

Annual income was grouped into project-defined analytical bands:

- Low income
- Middle income
- Upper middle income
- High income

### DTI Band

DTI was grouped into:

- Low DTI
- Moderate DTI
- High DTI
- Very High DTI

### FICO Band

FICO scores were grouped into analytical bands to compare historical default rates across credit-score ranges.

---

## Risk Scoring Methodology

A transparent rule-based `risk_score` was created using four borrower characteristics:

### DTI

- High DTI / Very High DTI → +2
- Moderate DTI → +1
- Low DTI → +0

### FICO

- Low FICO → +2
- Good FICO → +1
- Very Good / Excellent → +0

### Income

- Low income → +1
- Other income bands → +0

### Employment Length

- Employment length ≤ 1 year → +1
- Otherwise → +0

### Risk Level

The total score was converted into three categories:

- **0–1 → Low Risk**
- **2–3 → Medium Risk**
- **4–6 → High Risk**

### Manual Review

Applications classified as **High Risk** were marked as:

`Manual Review`

Other applications were marked as:

`Standard Review`

The manual-review flag is intended to **prioritize applications for additional human attention**, not to automatically approve, reject or predict a loan outcome.

---

## Key Findings

### Overall Performance

- **Total applications:** 272,650
- **Defaulted applications:** 55,929
- **Historical default rate:** 20.51%
- **Total loan amount:** approximately 4.08 billion

### Income

Historical default rates varied across income bands:

- Low income → approximately 23%
- Middle income → approximately 22%
- Upper middle income → approximately 18%
- High income → approximately 15%

### DTI

Higher DTI categories generally showed higher historical default rates.

- High DTI → 31.81%
- Moderate DTI → 24.40%
- Low DTI → 16.93%

The Very High DTI category had a 26.32% observed default rate, but it contained only **19 applications**, so this percentage should not be interpreted as a stable estimate.

### FICO

Lower FICO bands showed higher historical default rates than stronger FICO bands.

- Low → approximately 26%
- Good → approximately 20%
- Very Good → approximately 9%
- Excellent → approximately 5%

### Loan Purpose

Default rates varied across loan purposes. Small-business loans were among the higher-rate categories in the dataset, while credit-card loans had a lower observed default rate.

Small categories were interpreted cautiously because very small sample sizes can produce unstable percentages.

### Employment Length

Employment length showed relatively limited variation in historical default rates compared with factors such as DTI and FICO.

---

## Power BI Dashboard

The Power BI report contains three analytical pages.

### 1. Executive Overview

Provides a high-level view of:

- Total Applications
- Total Loan Amount
- Defaulted Applications
- Default Rate
- Default Rate by Risk Level
- Default Rate by Income Band
- Default Rate by FICO Band
- Default Rate by DTI Band

### 2. Risk & Default Analysis

Explores historical default patterns across:

- Loan Purpose
- Employment Length
- Loan Grade
- Home Ownership
- Verification Status

### 3. Manual Review & Application Analysis

Focuses on rule-based risk prioritization:

- Manual Review Status
- Risk Score Distribution
- Manual Review Applications by Income Band
- Manual Review Applications by Loan Purpose
- Application-level review table

---

## Dashboard Preview

### Executive Overview

![Executive Overview](Screenshots/Executive_Overview.png)

### Risk & Default Analysis

![Risk & Default Analysis](Screenshots/Risk_Analysis.png)

### Manual Review & Application Analysis

![Manual Review & Application Analysis](Screenshots/Manual_Review.png)

---

## Live Power BI Report

[View Live Power BI Report](https://app.powerbi.com/links/cj3pC45Usc?ctid=56c1d497-700b-49cf-8f8d-3dd6b20d522f&pbi_source=linkShare)

> Note: Access to the live Power BI report may depend on Power BI Service permissions and licensing.

---

## Project Files

```text
loan-risk-default-analysis/
│
├── README.md
│
├── SQL/
│   └── loan_risk_analysis.sql
│
├── PowerBI/
│   └── Loan_Risk_Default_Analysis.pbix
│
├── Dataset/
│   └── loan_risk_clean.csv
│
└── Screenshots/
    ├── Executive_Overview.png
    ├── Risk_Analysis.png
    └── Manual_Review.png
