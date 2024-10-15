# Layoff Dataset Analysis

## Table of Contents
- [Dataset Definition](#dataset-definition)
- [Analysis Process](#analysis-process)
- [Key Findings](#key-findings)
- [Technologies Used](#technologies-used)
- [How to Use](#how-to-use)
- [Conclusions](#conclusions)
- [Future Work](#future-work)

---

### Dataset Definition
This dataset contains information on company layoffs, which includes details such as:
- **company**: Name of the company where layoffs occurred.
- **location**: The location of the company.
- **industry**: The industry to which the company belongs.
- **total_laid_off**: The total number of employees laid off.
- **percentage_laid_off**: The percentage of the workforce that was laid off.
- **date**: The date when layoffs were announced.
- **Stage**: The company's stage in its growth lifecycle.
- **country**: The country where the layoffs occurred.
- **funds_raised_millions**: Funds raised by the company, in millions.

The dataset was cleaned to ensure consistency and accuracy. This included removing duplicates from the date column, standardizing formats, handling null and missing values, and removing irrelevant columns.

---

### Analysis Process
The analysis process involved several steps:
1. **Data Cleaning**: Duplicate dates were removed, formats were standardized, and null/missing values were handled. Unnecessary columns were also removed to streamline the analysis.
2. **Exploratory Data Analysis (EDA)**: Business questions were formulated, and SQL queries were run to gain insights into layoff trends. Key areas of focus included:
   - Trends over time in layoffs across industries.
   - The ranking of companies with top laid off  employees.
   - The relationship between company stage and layoff percentages.
 
3. **SQL Querying**: SQL was used to answer the business questions and extract insights from the dataset efficiently.

---

### Key Findings
- **Trends**: Layoff trends showed an increase in certain industries and stages, indicating possible economic downturns or shifts.
- **Industry Impact**: The Transportation, Education, Fitness and Media industry was notably affected, with significant layoffs in seed-stage companies.
- **Geographical Insights**: Layoff rates varied significantly by country, reflecting different economic conditions.

---

### Technologies Used
- **SQL**: For querying the dataset and performing data analysis.

---

### How to Use
To run this analysis on your machine:
1. Clone the repository.
2. Load the dataset into your preferred SQL or data analysis tool.
3. Run the provided SQL scripts to replicate the analysis.

---

### Conclusions
This analysis highlights how layoffs are influenced by industry trends, economic conditions, and funding stages. The data indicates that early-stage companies in tech are more vulnerable to layoffs during economic downturns.

---

### Future Work
Further analysis could include:
- Adding data from more recent years to observe post-pandemic trends.
- Expanding the dataset to include more global regions for a comprehensive view.
