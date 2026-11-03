# Commercial Insurance: business catalog (exported from Metabase)

**Source:** Metabase http://localhost:3030, database `Commercial Insurance` (snowflake)  
**Warehouse:** `SE_DEMO_LIBRARY.COMMERCIAL_INSURANCE` (snowflake)

Harborline Insurance Group, Global Commercial reporting. A commercial property & casualty book written through six legal entities in North America and internationally: about 5,000 policies, 800 multinational clients, 11 coverages in 8 lines of business, and 9,110 claims. One KPI fact table (TFACT_KPI) holds premium, expense, financial-income and loss amounts, surrounded by eight conformed dimensions. Currency is USD. Data covers July 2023 to June 2026 as 36 monthly valuation snapshots (month-end dates); complete years are 2024 and 2025 (2023 is July-December only, 2026 is January-June only). Fiscal year = calendar year. Premium, commission, expense and financial amounts are monthly flows that add up over time. Loss amounts (incurred, paid, outstanding reserve, claim expense) are cumulative balances restated at every snapshot: they must never be added across snapshots.

## Collection: Commercial Insurance - Business Catalog

Governed business definitions for Harborline's commercial insurance KPIs. Each metric states its calculation in SQL-like terms and its business rules in plain English. Rules such as 'never add loss balances across snapshots' and 'ratios are computed from totals' are part of the definition and must be honored by any tool that reports the metric.

## Tables

### Commercial KPI (monthly) (`TFACT_KPI`, 219,520 rows)

Global Commercial KPI fact, at a monthly grain. Two kinds of rows share the table. Premium rows (DIM_CLAIM_ID empty, 67,037 rows): one per policy coverage per fiscal month, carrying written and earned premium, commission, underwriting expense, investment income, other financial revenue and tax; these are monthly flows that add up over time. Loss rows (DIM_CLAIM_ID set, 152,483 rows): one per claim per monthly valuation snapshot, carrying incurred loss, paid loss, outstanding reserve and claim expense as cumulative balances to date; every snapshot restates the full balance, so loss amounts must never be added across snapshots. CURRENT_VALUATION_IN = 'Y' marks rows from the latest snapshot (2026-06-30), which hold every claim's current balance. Date roles: snapshot date (valuation month), fiscal month-end (booking month), accident month-end (accident month for loss rows; the fiscal month for premium rows, so earned premium lines up by accident period).

| Column | Display name | Type | Role | Description |
|---|---|---|---|---|
| FACT_KPI_ID | Fact Kpi ID | NUMBER | type/PK | Row key. |
| DIM_SNAPSHOT_DATE_ID | Snapshot Date | NUMBER | FK → TDIM_DATE.DIM_DATE_ID | Valuation snapshot month-end the row belongs to. Loss balances are as of this date. Join to the calendar as the Snapshot date role. |
| DIM_FISCAL_MONTH_END_DATE_ID | Fiscal Month End | NUMBER | FK → TDIM_DATE.DIM_DATE_ID | Fiscal month-end the premium, commission, expense or financial amount is booked in. Join to the calendar as the Fiscal date role; use it for premium growth and calendar-year premium. |
| DIM_ACCIDENT_MONTH_END_DATE_ID | Accident Month End | NUMBER | FK → TDIM_DATE.DIM_DATE_ID | Accident month-end. Loss rows: month the loss occurred. Premium rows: the fiscal month-end (there is no accident on a premium row), so earned premium and losses line up by accident period. Join to the calendar as the Accident date role; use it for accident-year loss ratios. |
| DIM_POLICY_ID | Dim Policy ID | NUMBER | FK → TDIM_POLICY.DIM_POLICY_ID | Policy. |
| DIM_POLICY_KEY | Dim Policy Key | VARCHAR |  | Denormalized policy business key. Join on DIM_POLICY_ID. |
| DIM_CLAIM_ID | Dim Claim ID | NUMBER | FK → TDIM_CLAIM.DIM_CLAIM_ID | Claim. Set on loss rows only; empty on premium rows. |
| DIM_CLAIM_KEY | Dim Claim Key | VARCHAR |  | Denormalized claim business key. Join on DIM_CLAIM_ID. |
| DIM_LOCATION_ID | Dim Location ID | NUMBER | FK → TDIM_LOCATION.DIM_LOCATION_ID | Risk location. |
| DIM_COMPANY_ID | Dim Company ID | NUMBER | FK → TDIM_COMPANY.DIM_COMPANY_ID | Issuing legal entity. |
| DIM_BUSINESS_UNIT_ID | Dim Business Unit ID | NUMBER | FK → TDIM_BUSINESS_UNIT.DIM_BUSINESS_UNIT_ID | Business unit (line of business). |
| DIM_CLIENT_ID | Dim Client ID | NUMBER | FK → TDIM_CLIENT.DIM_CLIENT_ID | Client. |
| DIM_CLIENT_KEY | Dim Client Key | VARCHAR |  | Denormalized client business key. Join on DIM_CLIENT_ID. |
| DIM_POLICY_COVERAGE_ID | Dim Policy Coverage ID | NUMBER | FK → TDIM_POLICY_COVERAGE.DIM_POLICY_COVERAGE_ID | Coverage. |
| DIM_POLICY_COVERAGE_KEY | Dim Policy Coverage Key | VARCHAR | type/Category | Denormalized coverage business key. Join on DIM_POLICY_COVERAGE_ID. |
| GROSS_WRITTEN_PREMIUM_AMT | Gross Written Premium | NUMBER | type/Currency | Gross written premium, booked in full in the inception month. Monthly flow; adds up over time. Premium rows only. |
| NET_WRITTEN_PREMIUM_AMT | Net Written Premium | NUMBER | type/Currency | Written premium net of reinsurance cessions, booked in the inception month. Monthly flow. |
| NET_EARNED_PREMIUM_AMT | Net Earned Premium | NUMBER | type/Currency | Net premium earned in the month, accrued evenly over the policy term. Monthly flow. |
| INCURRED_LOSS_AMT | Incurred Loss | NUMBER | type/Currency | Cumulative incurred loss (paid plus outstanding reserve) for the claim as of the snapshot date. A balance: never add across snapshots. Loss rows only. |
| PAID_LOSS_AMT | Paid Loss | NUMBER | type/Currency | Cumulative paid loss for the claim as of the snapshot date. A balance: never add across snapshots. |
| OUTSTANDING_RESERVE_AMT | Outstanding Reserve | NUMBER | type/Currency | Case reserve still outstanding on the claim as of the snapshot date. A balance: never add across snapshots. |
| CLAIM_EXPENSE_AMT | Claim Expense | NUMBER | type/Currency | Cumulative claim handling (loss adjustment) expense as of the snapshot date. A balance: never add across snapshots. |
| NET_COMMISSION_AMT | Net Commission | NUMBER | type/Currency | Broker commission expense, net, booked monthly as premium is earned. Monthly flow. |
| UNDERWRITING_EXPENSE_AMT | Underwriting Expense | NUMBER | type/Currency | Underwriting and acquisition expense other than commission. Monthly flow. |
| INVESTMENT_INCOME_AMT | Investment Income | NUMBER | type/Currency | Investment income allocated to the business. Monthly flow. |
| OTHER_FINANCIAL_REVENUE_AMT | Other Financial Revenue | NUMBER | type/Currency | Other financial revenue (fees, interest). Monthly flow. |
| TAX_AND_OTHER_EXPENSE_AMT | Tax and Other Expense | NUMBER | type/Currency | Premium taxes and other expense. Monthly flow. |
| POLICY_COUNT | Policy Month Count | NUMBER | type/Quantity | 1 on every premium row, so it counts policy-coverage-months, not policies. Do not use it to count policies; use Policies in Force or Policies Written. |
| CLAIM_COUNT | Claim Count | NUMBER | type/Quantity | 1 on the row from the snapshot in which the claim was first reported, 0 otherwise. Adds up across snapshots: the sum is the number of claims reported. |
| CURRENT_VALUATION_IN | Current Valuation | VARCHAR | type/Category | 'Y' on rows from the latest valuation snapshot (2026-06-30), otherwise 'N'. Filter loss balances to 'Y' to read every claim's current balance without double counting. |

### Business Unit (`TDIM_BUSINESS_UNIT`, 8 rows)

The underwriting business unit that owns the premium and losses. Hierarchy: Global Commercial > LOB Group (Property & Casualty, Financial Lines, Specialty) > Line of Business (8 lines).

| Column | Display name | Type | Role | Description |
|---|---|---|---|---|
| DIM_BUSINESS_UNIT_ID | Dim Business Unit ID | NUMBER | type/PK | Business unit key. |
| GDW_RDM_BUSINESS_UNIT_CD | Gdw Rdm Business Unit Cd | VARCHAR | type/Category | Business unit code from the reference-data master (e.g. PROP, CAS). |
| DIM_BUSINESS_UNIT_KEY | Dim Business Unit Key | VARCHAR | type/Category | Business key, 'BU-' plus the unit code. |
| BUSINESS_UNIT_LEVEL_1_NODE_CD | Business Unit Level 1 Node Cd | VARCHAR | type/Category | Top node code; always 'GC'. |
| BUSINESS_UNIT_LEVEL_1_NODE_DS | Global Commercial | VARCHAR | type/Category | Top of the business unit hierarchy; always 'Global Commercial'. |
| BUSINESS_UNIT_LEVEL_2_NODE_CD | Business Unit Level 2 Node Cd | VARCHAR | type/Category | LOB group code. |
| BUSINESS_UNIT_LEVEL_2_NODE_DS | LOB Group | VARCHAR | type/Category | Line-of-business group: Property & Casualty, Financial Lines or Specialty. Middle level of the business unit hierarchy. |
| BUSINESS_UNIT_LEVEL_3_NODE_CD | Business Unit Level 3 Node Cd | VARCHAR | type/Category | Line of business code. |
| BUSINESS_UNIT_LEVEL_3_NODE_DS | Line of Business | VARCHAR | type/Category | Line of business: Commercial Property, General Liability, Commercial Auto, Workers Compensation, Financial Lines, Marine, Energy, Aviation. Lowest level of the business unit hierarchy. General Liability is the long-tail line under watch. |
| BUSINESS_UNIT_DS | Business Unit Ds | VARCHAR | type/Category | Business unit name; same as Line of Business. |

### Claim (`TDIM_CLAIM`, 9,110 rows)

One row per claim: 9,110 claims with loss, notice and report dates, type of loss, accident year and catastrophe event where applicable. Hierarchy: Catastrophe > Claim.

| Column | Display name | Type | Role | Description |
|---|---|---|---|---|
| DIM_CLAIM_ID | Dim Claim ID | NUMBER | type/PK | Claim key. |
| CLAIM_ID | Claim ID | VARCHAR |  | Claim identifier from the claims system. |
| DIM_CLAIM_KEY | Dim Claim Key | VARCHAR |  | Claim business key (same as CLAIM_NO). |
| CATASTROPHE_CD | Catastrophe Cd | NUMBER |  | Catastrophe event code; empty for non-catastrophe claims. |
| CATASTROPHE_NM | Catastrophe | VARCHAR | type/Category | Catastrophe event name: Hurricane Delphine 2024 (September 2024, Houston and Miami) or European Floods 2025 (June 2025, Frankfurt and Paris). Empty for non-catastrophe claims. |
| CLAIM_NO | Claim Number | VARCHAR | type/Name | Claim number (e.g. CLM00000001). The label for a claim. |
| LOSS_DT | Loss Date | DATE |  | Date the loss occurred. |
| LOSS_RECEIVED_DT | Loss Received Date | DATE |  | Date notice of loss was received. |
| LOSS_REPORT_DT | Loss Report Date | DATE |  | Date the claim was reported in the claims system. |
| TYPE_OF_LOSS | Type of Loss | VARCHAR | type/Category | Peril or cause of loss (e.g. Windstorm, Fire, Data Breach, Securities Claim). |
| ACCIDENT_YEAR_NO | Claim Accident Year | VARCHAR | type/Category | Accident year of the claim (year of the loss date). For accident-year analysis of metrics, use the Accident date role of the calendar, which also aligns earned premium. |
| ISSUING_BRANCH_CD | Issuing Branch Cd | VARCHAR | type/Category | Claims branch code (PRO, GLP, AUT, ...). |
| SYSTEM_ID | System ID | VARCHAR | type/Category | Claims source system; always 'GDW'. |
| CLAIMANT_NM | Claimant | VARCHAR | type/Name | Claimant name (anonymised). |
| CLAIM_DS | Claim Description | VARCHAR | type/Description | Short claim description. |

### Client (`TDIM_CLIENT`, 800 rows)

The corporate client (insured organisation group): 800 clients. Hierarchy: Market Segment > Market Sub Segment > Client. Also carries the client's headquarters region and domicile country.

| Column | Display name | Type | Role | Description |
|---|---|---|---|---|
| DIM_CLIENT_ID | Dim Client ID | NUMBER | type/PK | Client key. |
| DIM_CLIENT_KEY | Dim Client Key | VARCHAR |  | Client business key (e.g. CLN000001). |
| DOMICILE_COUNTRY_NM | Domicile Country | VARCHAR | type/Country | Country where the client is domiciled. |
| COMPANY_NM | Client | VARCHAR | type/Name | Client organisation name. Lowest level of the client hierarchy. |
| DOMICILE_COUNTRY_CD | Domicile Country Cd | VARCHAR | type/Category | ISO code of the domicile country. |
| MULTINATIONAL_IN | Multinational | VARCHAR | type/Category | 'Y' if the client operates in multiple countries. |
| MARKET_SEGMENT_CD | Market Segment Cd | VARCHAR | type/Category | Market segment code. |
| MARKET_SEGMENT_NM | Market Segment | VARCHAR | type/Category | Client industry segment (e.g. Technology, Healthcare, Manufacturing). Top level of the client hierarchy. |
| MARKET_SUB_SEGMENT_CD | Market Sub Segment Cd | VARCHAR | type/Category | Market sub-segment code. |
| MARKET_SUB_SEGMENT_NM | Market Sub Segment | VARCHAR | type/Category | Client industry sub-segment (e.g. Semiconductors, Hospitals). |
| COUNTRY_CD | Country Cd | VARCHAR | type/Country | ISO code of the client's headquarters country. |
| COUNTRY_NM | Client HQ Country | VARCHAR | type/Country | Client headquarters country. |
| REGION_CD | Region Cd | VARCHAR | type/Category | Client headquarters region code. |
| REGION_NM | Client HQ Region | VARCHAR | type/Category | Client headquarters region: Americas, EMEA or APAC. Different from the risk location region. |
| SUB_REGION_CD | Sub Region Cd | VARCHAR | type/Category | Client headquarters sub-region code. |
| SUB_REGION_NM | Client HQ Sub Region | VARCHAR | type/Category | Client headquarters sub-region. |

### Legal Entity (`TDIM_COMPANY`, 6 rows)

The Harborline legal entity that issued the policy: six entities. Hierarchy: Harborline Insurance Group > General Insurance > Region Entity (Harborline North America, Harborline International) > Legal Entity.

| Column | Display name | Type | Role | Description |
|---|---|---|---|---|
| DIM_COMPANY_ID | Dim Company ID | NUMBER | type/PK | Legal entity key. |
| COMPANY | Company | VARCHAR | type/Company | Legal entity code (e.g. HLNF). |
| DIM_COMPANY_KEY | Dim Company Key | VARCHAR | type/Company | Legal entity business key (same as COMPANY). |
| COMPANY_NM | Company Nm | VARCHAR | type/Company | Legal entity name; same as Legal Entity. |
| COMPANY_LEVEL_1_NODE_CD | Company Level 1 Node Cd | VARCHAR | type/Company | Group code; always 'HLG'. |
| COMPANY_LEVEL_1_NODE_DS | Company Group | VARCHAR | type/Category | Top of the company hierarchy; always 'Harborline Insurance Group'. |
| COMPANY_LEVEL_2_NODE_CD | Company Level 2 Node Cd | VARCHAR | type/Company | Division code; always 'GI'. |
| COMPANY_LEVEL_2_NODE_DS | Company Division | VARCHAR | type/Category | Division; always 'General Insurance'. |
| COMPANY_LEVEL_3_NODE_CD | Company Level 3 Node Cd | VARCHAR | type/Company | Region entity code (HLNA, HLINTL). |
| COMPANY_LEVEL_3_NODE_DS | Region Entity | VARCHAR | type/Category | Region entity: Harborline North America or Harborline International. |
| COMPANY_LEVEL_4_NODE_CD | Company Level 4 Node Cd | VARCHAR | type/Company | Legal entity code (same as COMPANY). |
| COMPANY_LEVEL_4_NODE_DS | Legal Entity | VARCHAR | type/Category | Issuing legal entity (e.g. Harborline National Fire Insurance Co, Harborline Europe SA). Lowest level of the company hierarchy. |

### Calendar (`TDIM_DATE`, 2,557 rows)

Conformed calendar, one row per day from 2020-01-01 to 2026-12-31. TFACT_KPI joins to it three times, in three roles: Snapshot date (the month-end valuation the row belongs to), Fiscal date (the fiscal month-end the premium or expense is booked in) and Accident date (the month-end of the accident, for losses; premium rows carry their fiscal month-end here so earned premium lines up by accident period). Hierarchy for every role: Year > Quarter > Month > Day. Fiscal year = calendar year.

| Column | Display name | Type | Role | Description |
|---|---|---|---|---|
| DIM_DATE_ID | Date Key | NUMBER | type/PK | Integer date key, YYYYMMDD (e.g. 20260630). Fact tables join on this key. |
| FULL_DT | Date | DATE |  | Calendar day. Lowest level of the calendar hierarchy. |
| DOMESTIC_INTERNATIONAL_CD | Domestic International Cd | VARCHAR |  | Calendar scope code; always 'ALL'. Not used for analysis. |
| DAY_NM | Day Nm | VARCHAR |  | Day of week name (Monday..Sunday). |
| DAY_OF_WEEK_NO | Day Of Week No | VARCHAR |  | Day of week number (1-7). |
| DAY_OF_MONTH_NO | Day Of Month No | VARCHAR |  | Day of month (1-31). |
| DAY_OF_QUARTER_NO | Day Of Quarter No | VARCHAR |  | Day number within the quarter. |
| DAY_OF_YEAR_NO | Day Of Year No | VARCHAR |  | Day number within the year (1-366). |
| MONTH_NO | Month No | VARCHAR |  | Month number within the year, two digits ('01'..'12'). |
| MONTH_NM | Month Nm | VARCHAR |  | Month name (January..December). Not unique across years; use Month (YEAR_MONTH_NM) as the month level. |
| MONTH_OF_QUARTER_NO | Month Of Quarter No | VARCHAR |  | Month number within the quarter (1-3). |
| QUARTER_NO | Quarter No | VARCHAR |  | Quarter number within the year (1-4). Not unique across years; use Quarter (YEAR_QUARTER_NM) as the quarter level. |
| YEAR_NO | Year | VARCHAR | type/Category | Calendar (= fiscal) year. Top level of the calendar hierarchy. Complete years in the fact data: 2024 and 2025. |
| MONTH_YEAR_NO | Month Year No | VARCHAR |  | Year and month as YYYYMM (e.g. '202606'). Sortable month key. |
| WEEKDAY_IN | Weekday In | VARCHAR |  | 'Y' Monday to Friday, otherwise 'N'. |
| WEEKEND_IN | Weekend In | VARCHAR |  | 'Y' on Saturday and Sunday, otherwise 'N'. |
| HOLIDAY_IN | Holiday In | VARCHAR |  | 'Y' on public holidays, otherwise 'N'. |
| HOLIDAY_NM | Holiday Nm | VARCHAR |  | Holiday name when HOLIDAY_IN = 'Y'. |
| YEAR_QUARTER_NM | Quarter | VARCHAR | type/Category | Year-qualified quarter label, format 'Qn YYYY' (e.g. 'Q2 2026'). Quarter level of the calendar hierarchy. Sort chronologically by year then quarter, not alphabetically. |
| YEAR_MONTH_NM | Month | VARCHAR | type/Category | Year-qualified month label, format YYYY-MM (e.g. '2026-06'). Month level of the calendar hierarchy; unique across years and sorts chronologically. |

### Risk Location (`TDIM_LOCATION`, 16 rows)

Where the insured risk is located: 16 cities. Hierarchy: Global > Region (Americas, EMEA, APAC) > Sub Region > Country > City.

| Column | Display name | Type | Role | Description |
|---|---|---|---|---|
| DIM_LOCATION_ID | Dim Location ID | NUMBER | type/PK | Location key. |
| LOCATION_CD | Location Cd | VARCHAR | type/Category | Location code, country plus city (e.g. US-TX). |
| DIM_LOCATION_KEY | Dim Location Key | VARCHAR | type/Category | Location business key (same as LOCATION_CD). |
| LOCATION_DS | Location Ds | VARCHAR | type/Category | City and country label (e.g. 'Houston, United States'). |
| LOCATION_LEVEL_1_NODE_CD | Location Level 1 Node Cd | VARCHAR | type/Category | Top node code; always 'GLOBAL'. |
| LOCATION_LEVEL_1_NODE_DS | Location Level 1 Node Ds | VARCHAR | type/Category | Top of the location hierarchy; always 'Global'. |
| LOCATION_LEVEL_2_NODE_CD | Location Level 2 Node Cd | VARCHAR | type/Category | Region code (AMER, EMEA, APAC). |
| LOCATION_LEVEL_2_NODE_DS | Region | VARCHAR | type/Category | Region: Americas, EMEA or APAC. |
| LOCATION_LEVEL_3_NODE_CD | Location Level 3 Node Cd | VARCHAR | type/Category | Sub-region code. |
| LOCATION_LEVEL_3_NODE_DS | Sub Region | VARCHAR | type/Category | Sub-region (North America, Latin America, Europe, Middle East, Asia, Pacific). |
| LOCATION_LEVEL_4_NODE_CD | Location Level 4 Node Cd | VARCHAR | type/Category | ISO country code. |
| LOCATION_LEVEL_4_NODE_DS | Country | VARCHAR | type/Country | Country of the risk location. |
| LOCATION_LEVEL_5_NODE_CD | Location Level 5 Node Cd | VARCHAR | type/Category | City code (same as LOCATION_CD). |
| LOCATION_LEVEL_5_NODE_DS | City | VARCHAR | type/City | City of the risk location. Lowest level of the location hierarchy. Catastrophe losses concentrate in Houston and Miami (Hurricane Delphine 2024) and Frankfurt and Paris (European Floods 2025). |

### Policy (`TDIM_POLICY`, 5,000 rows)

One row per commercial policy: 5,000 policies with term dates, limit, deductible, commission rate and insured name.

| Column | Display name | Type | Role | Description |
|---|---|---|---|---|
| DIM_POLICY_ID | Dim Policy ID | NUMBER | type/PK | Policy key. |
| AGREEMENT_ID | Agreement ID | VARCHAR |  | Underlying agreement identifier. |
| DIM_POLICY_KEY | Dim Policy Key | VARCHAR |  | Policy business key (e.g. POL00000001). |
| ORIGINAL_POLICY_NO | Policy Number | VARCHAR | type/Name | Policy number as issued: entity code, inception year and sequence (e.g. HLNF-2025-000001). The label for a policy. |
| POLICY_EFFECTIVE_DT | Policy Effective Date | DATE |  | Policy inception date. |
| POLICY_EXPIRATION_DT | Policy Expiration Date | DATE |  | Policy expiration date. |
| COMPANY_CD | Company Cd | VARCHAR | type/Company | Issuing legal entity code. Use the Legal Entity table for company analysis. |
| COMPANY_NM | Company Nm | VARCHAR | type/Company | Issuing legal entity name. Use the Legal Entity table for company analysis. |
| COUNTRY_CD | Country Cd | VARCHAR | type/Country | ISO code of the country where the policy is issued. |
| COUNTRY_NM | Policy Country | VARCHAR | type/Country | Country where the policy is issued. |
| SOURCE_SYSTEM_CD | Source System Cd | VARCHAR | type/Source | Source system; always 'GDW'. |
| SYSTEM_ID | System ID | VARCHAR | type/Category | Originating policy administration system (SYS1..SYS5). |
| MARKET_SEGMENT_CD | Policy Market Segment | VARCHAR | type/Category | Market segment code recorded on the policy. |
| COMMISION_RATIO | Policy Commission Rate | NUMBER | type/Percentage | Contracted broker commission rate for the policy (0.10 = 10%). A policy attribute; for reporting use the Commission Ratio metric. |
| POLICY_TYPE_CD | Policy Type | VARCHAR | type/Category | 'N' new business, 'R' renewal. |
| INSURED_NM | Insured Name | VARCHAR | type/Name | Named insured organisation on the policy. |
| POLICY_LIMIT | Policy Limit | NUMBER | type/Currency | Policy limit of liability, USD. A policy attribute; do not add across rows of the fact table. |
| POLICY_DEDUCTIBLE | Policy Deductible | NUMBER | type/Currency | Policy deductible, USD. |

### Coverage (`TDIM_POLICY_COVERAGE`, 11 rows)

The coverage (product) a premium or loss amount belongs to: 11 coverages. Hierarchy: Coverage Group > Coverage Line of Business > Product > Coverage. LONG_TAIL_IN flags coverages whose claims take years to settle.

| Column | Display name | Type | Role | Description |
|---|---|---|---|---|
| DIM_POLICY_COVERAGE_ID | Dim Policy Coverage ID | NUMBER | type/PK | Coverage key. |
| DIM_POLICY_COVERAGE_KEY | Dim Policy Coverage Key | VARCHAR | type/Category | Coverage business key (same as COVERAGE_CD). |
| COVERAGE_CD | Coverage Cd | VARCHAR | type/Category | Coverage code (e.g. PROPCOM, GLPREM, CYBER). |
| COVERAGE_NM | Coverage | VARCHAR | type/Category | Coverage name (e.g. Commercial Property, Directors & Officers, Cyber). Lowest level of the coverage hierarchy. |
| LINE_OF_BUSINESS_CD | Line Of Business Cd | VARCHAR | type/Category | Coverage line of business code. |
| LINE_OF_BUSINESS_NM | Coverage Line of Business | VARCHAR | type/Category | Line of business the coverage rolls up to (Property, Casualty, Commercial Auto, Workers Comp, Financial Lines, Marine, Energy, Aviation). |
| COVERAGE_GROUP_CD | Coverage Group Cd | VARCHAR | type/Category | Coverage group code. |
| COVERAGE_GROUP_NM | Coverage Group | VARCHAR | type/Category | Coverage group: Property & Casualty, Financial Lines or Specialty. Top level of the coverage hierarchy. |
| PRODUCT_CD | Product Cd | VARCHAR | type/Category | Product code. |
| PRODUCT_NM | Product | VARCHAR | type/Category | Product name (e.g. All-Risk Property, Premises Liability, Network Security). |
| LONG_TAIL_IN | Long Tail | VARCHAR | type/Category | 'Y' for long-tail coverages whose claims develop over several years (General Liability, Product Liability, Directors & Officers, Workers Compensation, Commercial Auto Liability, Aviation Hull & Liability); 'N' for short-tail coverages that settle within about a year (Commercial Property, Business Interruption, Energy Property, Marine Cargo, Cyber). |

## Metrics

Each metric is a Metabase Metric; the definition column is its query-builder formula rendered as SQL. The description carries the business rules.

### Investment Income

- **Area:** Financial Results
- **Source table:** `TFACT_KPI`
- **Definition:** `SUM(TFACT_KPI.INVESTMENT_INCOME_AMT)`
- **Business rules:** Investment income allocated to the business. Definition: SUM(INVESTMENT_INCOME_AMT). Adds up over time.

### Net Commission

- **Area:** Financial Results
- **Source table:** `TFACT_KPI`
- **Definition:** `SUM(TFACT_KPI.NET_COMMISSION_AMT)`
- **Business rules:** Broker commission expense. Definition: SUM(NET_COMMISSION_AMT). Adds up over time.

### Net Result

- **Area:** Financial Results
- **Source table:** `TFACT_KPI`
- **Definition:** `((((((SUM(TFACT_KPI.NET_EARNED_PREMIUM_AMT)) - (SUM(TFACT_KPI.INCURRED_LOSS_AMT) WHERE TFACT_KPI.CURRENT_VALUATION_IN = 'Y')) - (SUM(TFACT_KPI.UNDERWRITING_EXPENSE_AMT))) - (SUM(TFACT_KPI.NET_COMMISSION_AMT))) + (SUM(TFACT_KPI.INVESTMENT_INCOME_AMT))) + (SUM(TFACT_KPI.OTHER_FINANCIAL_REVENUE_AMT))) - (SUM(TFACT_KPI.TAX_AND_OTHER_EXPENSE_AMT))`
- **Business rules:** Bottom-line result. Definition: Underwriting Result + Investment Income + Other Financial Revenue - Tax and Other Expense. Accident-year basis like the Loss Ratio: report by the accident date.

### Other Financial Revenue

- **Area:** Financial Results
- **Source table:** `TFACT_KPI`
- **Definition:** `SUM(TFACT_KPI.OTHER_FINANCIAL_REVENUE_AMT)`
- **Business rules:** Other financial revenue. Definition: SUM(OTHER_FINANCIAL_REVENUE_AMT). Adds up over time.

### Tax and Other Expense

- **Area:** Financial Results
- **Source table:** `TFACT_KPI`
- **Definition:** `SUM(TFACT_KPI.TAX_AND_OTHER_EXPENSE_AMT)`
- **Business rules:** Premium taxes and other expense. Definition: SUM(TAX_AND_OTHER_EXPENSE_AMT). Adds up over time.

### Underwriting Expense

- **Area:** Financial Results
- **Source table:** `TFACT_KPI`
- **Definition:** `SUM(TFACT_KPI.UNDERWRITING_EXPENSE_AMT)`
- **Business rules:** Underwriting and acquisition expense other than commission. Definition: SUM(UNDERWRITING_EXPENSE_AMT). Adds up over time.

### Underwriting Result

- **Area:** Financial Results
- **Source table:** `TFACT_KPI`
- **Definition:** `(((SUM(TFACT_KPI.NET_EARNED_PREMIUM_AMT)) - (SUM(TFACT_KPI.INCURRED_LOSS_AMT) WHERE TFACT_KPI.CURRENT_VALUATION_IN = 'Y')) - (SUM(TFACT_KPI.UNDERWRITING_EXPENSE_AMT))) - (SUM(TFACT_KPI.NET_COMMISSION_AMT))`
- **Business rules:** Underwriting profit or loss. Definition: Net Earned Premium - Incurred Loss (current valuation) - Underwriting Expense - Net Commission. Accident-year basis like the Loss Ratio: report by the accident date.

### Average Incurred per Claim

- **Area:** Losses & Reserves
- **Source table:** `TFACT_KPI`
- **Definition:** `(SUM(TFACT_KPI.INCURRED_LOSS_AMT) WHERE TFACT_KPI.CURRENT_VALUATION_IN = 'Y') / (SUM(TFACT_KPI.CLAIM_COUNT))`
- **Business rules:** Claim severity. Definition: Incurred Loss / Claim Count. Ratio: compute from the totals.

### Claim Count

- **Area:** Losses & Reserves
- **Source table:** `TFACT_KPI`
- **Definition:** `SUM(TFACT_KPI.CLAIM_COUNT)`
- **Business rules:** Claims reported. Definition: SUM(CLAIM_COUNT). Each claim is counted once, in the snapshot it was first reported, so it adds up over time and across all dimensions.

### Claim Expense

- **Area:** Losses & Reserves
- **Source table:** `TFACT_KPI`
- **Definition:** `SUM(TFACT_KPI.CLAIM_EXPENSE_AMT) WHERE TFACT_KPI.CURRENT_VALUATION_IN = 'Y'`
- **Business rules:** Claim handling (loss adjustment) expense at the current valuation. Definition: SUM(CLAIM_EXPENSE_AMT) WHERE CURRENT_VALUATION_IN = 'Y'. Reads only the latest snapshot.

### Incurred Loss

- **Area:** Losses & Reserves
- **Source table:** `TFACT_KPI`
- **Definition:** `SUM(TFACT_KPI.INCURRED_LOSS_AMT) WHERE TFACT_KPI.CURRENT_VALUATION_IN = 'Y'`
- **Business rules:** Incurred loss at the current valuation. Definition: SUM(INCURRED_LOSS_AMT) WHERE CURRENT_VALUATION_IN = 'Y'. Reads only the latest snapshot, so it adds across claims, coverages, lines, locations and clients and can never double count. Slice it by the accident date to see losses by accident year. This is the incurred loss in the loss ratio.

### Incurred Loss Balance

- **Area:** Losses & Reserves
- **Source table:** `TFACT_KPI`
- **Definition:** `SUM(TFACT_KPI.INCURRED_LOSS_AMT)`
- **Business rules:** Incurred loss as of a valuation snapshot, for reserve-development and year-end views. Definition: SUM(INCURRED_LOSS_AMT). Rule: point-in-time balance on the snapshot date. For any period (month, quarter, year), take the balance from the latest snapshot in that period; add across claims, lines and locations, never across snapshots. Example: the 2025 value is the December 2025 snapshot.

### Outstanding Reserve

- **Area:** Losses & Reserves
- **Source table:** `TFACT_KPI`
- **Definition:** `SUM(TFACT_KPI.OUTSTANDING_RESERVE_AMT) WHERE TFACT_KPI.CURRENT_VALUATION_IN = 'Y'`
- **Business rules:** Case reserves outstanding at the current valuation. Definition: SUM(OUTSTANDING_RESERVE_AMT) WHERE CURRENT_VALUATION_IN = 'Y'. Reads only the latest snapshot.

### Outstanding Reserve Balance

- **Area:** Losses & Reserves
- **Source table:** `TFACT_KPI`
- **Definition:** `SUM(TFACT_KPI.OUTSTANDING_RESERVE_AMT)`
- **Business rules:** Case reserves as of a valuation snapshot. Definition: SUM(OUTSTANDING_RESERVE_AMT). Rule: point-in-time balance on the snapshot date; take the latest snapshot in the period, never add across snapshots.

### Paid Loss

- **Area:** Losses & Reserves
- **Source table:** `TFACT_KPI`
- **Definition:** `SUM(TFACT_KPI.PAID_LOSS_AMT) WHERE TFACT_KPI.CURRENT_VALUATION_IN = 'Y'`
- **Business rules:** Paid loss at the current valuation. Definition: SUM(PAID_LOSS_AMT) WHERE CURRENT_VALUATION_IN = 'Y'. Reads only the latest snapshot.

### Paid Loss Balance

- **Area:** Losses & Reserves
- **Source table:** `TFACT_KPI`
- **Definition:** `SUM(TFACT_KPI.PAID_LOSS_AMT)`
- **Business rules:** Paid loss as of a valuation snapshot. Definition: SUM(PAID_LOSS_AMT). Rule: point-in-time balance on the snapshot date; take the latest snapshot in the period, never add across snapshots.

### Average Written Premium

- **Area:** Premium
- **Source table:** `TFACT_KPI`
- **Definition:** `(SUM(TFACT_KPI.GROSS_WRITTEN_PREMIUM_AMT)) / (COUNT(*) WHERE TFACT_KPI.GROSS_WRITTEN_PREMIUM_AMT > 0)`
- **Business rules:** Average gross premium per policy coverage written. Definition: Gross Written Premium / Policies Written. Ratio: compute from the totals.

### Gross Written Premium

- **Area:** Premium
- **Source table:** `TFACT_KPI`
- **Definition:** `SUM(TFACT_KPI.GROSS_WRITTEN_PREMIUM_AMT)`
- **Business rules:** Gross premium written. Definition: SUM(GROSS_WRITTEN_PREMIUM_AMT). Adds up over time; report it by the fiscal month-end date. Also report it year-over-year and year-to-date on the fiscal calendar: prior-year value, YoY growth % = (this period - same period last year) / same period last year, and year-to-date total.

### Net Earned Premium

- **Area:** Premium
- **Source table:** `TFACT_KPI`
- **Definition:** `SUM(TFACT_KPI.NET_EARNED_PREMIUM_AMT)`
- **Business rules:** Net premium earned. Definition: SUM(NET_EARNED_PREMIUM_AMT). Adds up over time. The denominator of the loss, commission and combined ratios. Also report it year-over-year on the fiscal calendar.

### Net Written Premium

- **Area:** Premium
- **Source table:** `TFACT_KPI`
- **Definition:** `SUM(TFACT_KPI.NET_WRITTEN_PREMIUM_AMT)`
- **Business rules:** Written premium net of reinsurance. Definition: SUM(NET_WRITTEN_PREMIUM_AMT). Adds up over time; report it by the fiscal month-end date. Also report it year-over-year on the fiscal calendar.

### Policies Written

- **Area:** Premium
- **Source table:** `TFACT_KPI`
- **Definition:** `COUNT(*) WHERE TFACT_KPI.GROSS_WRITTEN_PREMIUM_AMT > 0`
- **Business rules:** Policy coverages written (incepted) in the period. Definition: COUNT of rows WHERE GROSS_WRITTEN_PREMIUM_AMT > 0. Adds up over time; report it by the fiscal month-end date.

### Policies in Force

- **Area:** Premium
- **Source table:** `TFACT_KPI`
- **Definition:** `COUNT(DISTINCT TFACT_KPI.DIM_POLICY_ID)`
- **Business rules:** Number of distinct policies with activity in the period. Definition: COUNT(DISTINCT DIM_POLICY_ID). Not additive: count distinct policies over the whole period, never add monthly counts.

### Retention Ratio

- **Area:** Premium
- **Source table:** `TFACT_KPI`
- **Definition:** `(SUM(TFACT_KPI.NET_WRITTEN_PREMIUM_AMT)) / (SUM(TFACT_KPI.GROSS_WRITTEN_PREMIUM_AMT))`
- **Business rules:** Share of gross premium kept after reinsurance. Definition: Net Written Premium / Gross Written Premium. Ratio: compute from the totals, never average the ratios.

### Combined Ratio

- **Area:** Underwriting Ratios
- **Source table:** `TFACT_KPI`
- **Definition:** `((SUM(TFACT_KPI.INCURRED_LOSS_AMT) WHERE TFACT_KPI.CURRENT_VALUATION_IN = 'Y') / (SUM(TFACT_KPI.NET_EARNED_PREMIUM_AMT))) + ((SUM(TFACT_KPI.UNDERWRITING_EXPENSE_AMT)) / (SUM(TFACT_KPI.NET_WRITTEN_PREMIUM_AMT)))`
- **Business rules:** The headline underwriting KPI. Definition: Loss Ratio + Expense Ratio. Below 100% is an underwriting profit; above 100% is a loss. Accident-year basis like the Loss Ratio. Compute each ratio from totals, then add them.

### Commission Ratio

- **Area:** Underwriting Ratios
- **Source table:** `TFACT_KPI`
- **Definition:** `(SUM(TFACT_KPI.NET_COMMISSION_AMT)) / (SUM(TFACT_KPI.NET_EARNED_PREMIUM_AMT))`
- **Business rules:** Commission as a share of earned premium. Definition: Net Commission / Net Earned Premium. Ratio: compute from the totals.

### Expense Ratio

- **Area:** Underwriting Ratios
- **Source table:** `TFACT_KPI`
- **Definition:** `(SUM(TFACT_KPI.UNDERWRITING_EXPENSE_AMT)) / (SUM(TFACT_KPI.NET_WRITTEN_PREMIUM_AMT))`
- **Business rules:** Underwriting expense as a share of written premium. Definition: Underwriting Expense / Net Written Premium. Ratio: compute from the totals.

### Investment Income Ratio

- **Area:** Underwriting Ratios
- **Source table:** `TFACT_KPI`
- **Definition:** `(SUM(TFACT_KPI.INVESTMENT_INCOME_AMT)) / (SUM(TFACT_KPI.NET_EARNED_PREMIUM_AMT))`
- **Business rules:** Investment income as a share of earned premium. Definition: Investment Income / Net Earned Premium. Ratio: compute from the totals.

### Loss Ratio

- **Area:** Underwriting Ratios
- **Source table:** `TFACT_KPI`
- **Definition:** `(SUM(TFACT_KPI.INCURRED_LOSS_AMT) WHERE TFACT_KPI.CURRENT_VALUATION_IN = 'Y') / (SUM(TFACT_KPI.NET_EARNED_PREMIUM_AMT))`
- **Business rules:** Incurred loss as a share of earned premium, on an accident-year basis. Definition: Incurred Loss (current valuation) / Net Earned Premium. Report by the accident date: premium rows carry their earning month as the accident date, so each accident period's losses are divided by that period's earned premium. Ratio: compute from the totals, never average the ratios. Recent accident years are still developing and read lower.

### Operating Ratio

- **Area:** Underwriting Ratios
- **Source table:** `TFACT_KPI`
- **Definition:** `(((SUM(TFACT_KPI.INCURRED_LOSS_AMT) WHERE TFACT_KPI.CURRENT_VALUATION_IN = 'Y') / (SUM(TFACT_KPI.NET_EARNED_PREMIUM_AMT))) + ((SUM(TFACT_KPI.UNDERWRITING_EXPENSE_AMT)) / (SUM(TFACT_KPI.NET_WRITTEN_PREMIUM_AMT)))) - ((SUM(TFACT_KPI.INVESTMENT_INCOME_AMT)) / (SUM(TFACT_KPI.NET_EARNED_PREMIUM_AMT)))`
- **Business rules:** Combined ratio after investment income. Definition: Combined Ratio - Investment Income Ratio. Below 100% means the business is profitable once investment income is counted.

### Paid to Incurred Ratio

- **Area:** Underwriting Ratios
- **Source table:** `TFACT_KPI`
- **Definition:** `(SUM(TFACT_KPI.PAID_LOSS_AMT) WHERE TFACT_KPI.CURRENT_VALUATION_IN = 'Y') / (SUM(TFACT_KPI.INCURRED_LOSS_AMT) WHERE TFACT_KPI.CURRENT_VALUATION_IN = 'Y')`
- **Business rules:** Reserve-adequacy signal: how much of incurred loss has been paid. Definition: Paid Loss / Incurred Loss, both at the current valuation. Low values on long-tail coverages are expected; a low value that stays low as the accident year matures can signal adverse development. Ratio: compute from the totals.
