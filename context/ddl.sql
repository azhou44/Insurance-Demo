-- Rebuilt from Metabase column metadata (database: Commercial Insurance, engine: snowflake)
-- Warehouse location: SE_DEMO_LIBRARY.COMMERCIAL_INSURANCE

-- The underwriting business unit that owns the premium and losses. Hierarchy: Global Commercial > LOB Group (Property & Casualty, Financial Lines, Specialty) > Line of Business (8 lines).
CREATE TABLE "SE_DEMO_LIBRARY"."COMMERCIAL_INSURANCE"."TDIM_BUSINESS_UNIT" (
  DIM_BUSINESS_UNIT_ID NUMBER,  -- Business unit key.
  GDW_RDM_BUSINESS_UNIT_CD VARCHAR,  -- Business unit code from the reference-data master (e.g. PROP, CAS).
  DIM_BUSINESS_UNIT_KEY VARCHAR,  -- Business key, 'BU-' plus the unit code.
  BUSINESS_UNIT_LEVEL_1_NODE_CD VARCHAR,  -- Top node code; always 'GC'.
  BUSINESS_UNIT_LEVEL_1_NODE_DS VARCHAR,  -- Top of the business unit hierarchy; always 'Global Commercial'.
  BUSINESS_UNIT_LEVEL_2_NODE_CD VARCHAR,  -- LOB group code.
  BUSINESS_UNIT_LEVEL_2_NODE_DS VARCHAR,  -- Line-of-business group: Property & Casualty, Financial Lines or Specialty. Middle level of the business unit hierarchy.
  BUSINESS_UNIT_LEVEL_3_NODE_CD VARCHAR,  -- Line of business code.
  BUSINESS_UNIT_LEVEL_3_NODE_DS VARCHAR,  -- Line of business: Commercial Property, General Liability, Commercial Auto, Workers Compensation, Financial Lines, Marine, Energy, Aviation. Lowest level of the business unit hierarchy. General Liability is the long-tail line under watch.
  BUSINESS_UNIT_DS VARCHAR,  -- Business unit name; same as Line of Business.
  PRIMARY KEY (DIM_BUSINESS_UNIT_ID) NOT ENFORCED
);

-- One row per claim: 9,110 claims with loss, notice and report dates, type of loss, accident year and catastrophe event where applicable. Hierarchy: Catastrophe > Claim.
CREATE TABLE "SE_DEMO_LIBRARY"."COMMERCIAL_INSURANCE"."TDIM_CLAIM" (
  DIM_CLAIM_ID NUMBER,  -- Claim key.
  CLAIM_ID VARCHAR,  -- Claim identifier from the claims system.
  DIM_CLAIM_KEY VARCHAR,  -- Claim business key (same as CLAIM_NO).
  CATASTROPHE_CD NUMBER,  -- Catastrophe event code; empty for non-catastrophe claims.
  CATASTROPHE_NM VARCHAR,  -- Catastrophe event name: Hurricane Delphine 2024 (September 2024, Houston and Miami) or European Floods 2025 (June 2025, Frankfurt and Paris). Empty for non-catastrophe claims.
  CLAIM_NO VARCHAR,  -- Claim number (e.g. CLM00000001). The label for a claim.
  LOSS_DT DATE,  -- Date the loss occurred.
  LOSS_RECEIVED_DT DATE,  -- Date notice of loss was received.
  LOSS_REPORT_DT DATE,  -- Date the claim was reported in the claims system.
  TYPE_OF_LOSS VARCHAR,  -- Peril or cause of loss (e.g. Windstorm, Fire, Data Breach, Securities Claim).
  ACCIDENT_YEAR_NO VARCHAR,  -- Accident year of the claim (year of the loss date). For accident-year analysis of metrics, use the Accident date role of the calendar, which also aligns earned premium.
  ISSUING_BRANCH_CD VARCHAR,  -- Claims branch code (PRO, GLP, AUT, ...).
  SYSTEM_ID VARCHAR,  -- Claims source system; always 'GDW'.
  CLAIMANT_NM VARCHAR,  -- Claimant name (anonymised).
  CLAIM_DS VARCHAR,  -- Short claim description.
  PRIMARY KEY (DIM_CLAIM_ID) NOT ENFORCED
);

-- The corporate client (insured organisation group): 800 clients. Hierarchy: Market Segment > Market Sub Segment > Client. Also carries the client's headquarters region and domicile country.
CREATE TABLE "SE_DEMO_LIBRARY"."COMMERCIAL_INSURANCE"."TDIM_CLIENT" (
  DIM_CLIENT_ID NUMBER,  -- Client key.
  DIM_CLIENT_KEY VARCHAR,  -- Client business key (e.g. CLN000001).
  DOMICILE_COUNTRY_NM VARCHAR,  -- Country where the client is domiciled.
  COMPANY_NM VARCHAR,  -- Client organisation name. Lowest level of the client hierarchy.
  DOMICILE_COUNTRY_CD VARCHAR,  -- ISO code of the domicile country.
  MULTINATIONAL_IN VARCHAR,  -- 'Y' if the client operates in multiple countries.
  MARKET_SEGMENT_CD VARCHAR,  -- Market segment code.
  MARKET_SEGMENT_NM VARCHAR,  -- Client industry segment (e.g. Technology, Healthcare, Manufacturing). Top level of the client hierarchy.
  MARKET_SUB_SEGMENT_CD VARCHAR,  -- Market sub-segment code.
  MARKET_SUB_SEGMENT_NM VARCHAR,  -- Client industry sub-segment (e.g. Semiconductors, Hospitals).
  COUNTRY_CD VARCHAR,  -- ISO code of the client's headquarters country.
  COUNTRY_NM VARCHAR,  -- Client headquarters country.
  REGION_CD VARCHAR,  -- Client headquarters region code.
  REGION_NM VARCHAR,  -- Client headquarters region: Americas, EMEA or APAC. Different from the risk location region.
  SUB_REGION_CD VARCHAR,  -- Client headquarters sub-region code.
  SUB_REGION_NM VARCHAR,  -- Client headquarters sub-region.
  PRIMARY KEY (DIM_CLIENT_ID) NOT ENFORCED
);

-- The Harborline legal entity that issued the policy: six entities. Hierarchy: Harborline Insurance Group > General Insurance > Region Entity (Harborline North America, Harborline International) > Legal Entity.
CREATE TABLE "SE_DEMO_LIBRARY"."COMMERCIAL_INSURANCE"."TDIM_COMPANY" (
  DIM_COMPANY_ID NUMBER,  -- Legal entity key.
  COMPANY VARCHAR,  -- Legal entity code (e.g. HLNF).
  DIM_COMPANY_KEY VARCHAR,  -- Legal entity business key (same as COMPANY).
  COMPANY_NM VARCHAR,  -- Legal entity name; same as Legal Entity.
  COMPANY_LEVEL_1_NODE_CD VARCHAR,  -- Group code; always 'HLG'.
  COMPANY_LEVEL_1_NODE_DS VARCHAR,  -- Top of the company hierarchy; always 'Harborline Insurance Group'.
  COMPANY_LEVEL_2_NODE_CD VARCHAR,  -- Division code; always 'GI'.
  COMPANY_LEVEL_2_NODE_DS VARCHAR,  -- Division; always 'General Insurance'.
  COMPANY_LEVEL_3_NODE_CD VARCHAR,  -- Region entity code (HLNA, HLINTL).
  COMPANY_LEVEL_3_NODE_DS VARCHAR,  -- Region entity: Harborline North America or Harborline International.
  COMPANY_LEVEL_4_NODE_CD VARCHAR,  -- Legal entity code (same as COMPANY).
  COMPANY_LEVEL_4_NODE_DS VARCHAR,  -- Issuing legal entity (e.g. Harborline National Fire Insurance Co, Harborline Europe SA). Lowest level of the company hierarchy.
  PRIMARY KEY (DIM_COMPANY_ID) NOT ENFORCED
);

-- Conformed calendar, one row per day from 2020-01-01 to 2026-12-31. TFACT_KPI joins to it three times, in three roles: Snapshot date (the month-end valuation the row belongs to), Fiscal date (the fiscal month-end the premium or expense is booked in) and Accident date (the month-end of the accident, for losses; premium rows carry their fiscal month-end here so earned premium lines up by accident period). Hierarchy for every role: Year > Quarter > Month > Day. Fiscal year = calendar year.
CREATE TABLE "SE_DEMO_LIBRARY"."COMMERCIAL_INSURANCE"."TDIM_DATE" (
  DIM_DATE_ID NUMBER,  -- Integer date key, YYYYMMDD (e.g. 20260630). Fact tables join on this key.
  FULL_DT DATE,  -- Calendar day. Lowest level of the calendar hierarchy.
  DOMESTIC_INTERNATIONAL_CD VARCHAR,  -- Calendar scope code; always 'ALL'. Not used for analysis.
  DAY_NM VARCHAR,  -- Day of week name (Monday..Sunday).
  DAY_OF_WEEK_NO VARCHAR,  -- Day of week number (1-7).
  DAY_OF_MONTH_NO VARCHAR,  -- Day of month (1-31).
  DAY_OF_QUARTER_NO VARCHAR,  -- Day number within the quarter.
  DAY_OF_YEAR_NO VARCHAR,  -- Day number within the year (1-366).
  MONTH_NO VARCHAR,  -- Month number within the year, two digits ('01'..'12').
  MONTH_NM VARCHAR,  -- Month name (January..December). Not unique across years; use Month (YEAR_MONTH_NM) as the month level.
  MONTH_OF_QUARTER_NO VARCHAR,  -- Month number within the quarter (1-3).
  QUARTER_NO VARCHAR,  -- Quarter number within the year (1-4). Not unique across years; use Quarter (YEAR_QUARTER_NM) as the quarter level.
  YEAR_NO VARCHAR,  -- Calendar (= fiscal) year. Top level of the calendar hierarchy. Complete years in the fact data: 2024 and 2025.
  MONTH_YEAR_NO VARCHAR,  -- Year and month as YYYYMM (e.g. '202606'). Sortable month key.
  WEEKDAY_IN VARCHAR,  -- 'Y' Monday to Friday, otherwise 'N'.
  WEEKEND_IN VARCHAR,  -- 'Y' on Saturday and Sunday, otherwise 'N'.
  HOLIDAY_IN VARCHAR,  -- 'Y' on public holidays, otherwise 'N'.
  HOLIDAY_NM VARCHAR,  -- Holiday name when HOLIDAY_IN = 'Y'.
  YEAR_QUARTER_NM VARCHAR,  -- Year-qualified quarter label, format 'Qn YYYY' (e.g. 'Q2 2026'). Quarter level of the calendar hierarchy. Sort chronologically by year then quarter, not alphabetically.
  YEAR_MONTH_NM VARCHAR,  -- Year-qualified month label, format YYYY-MM (e.g. '2026-06'). Month level of the calendar hierarchy; unique across years and sorts chronologically.
  PRIMARY KEY (DIM_DATE_ID) NOT ENFORCED
);

-- Where the insured risk is located: 16 cities. Hierarchy: Global > Region (Americas, EMEA, APAC) > Sub Region > Country > City.
CREATE TABLE "SE_DEMO_LIBRARY"."COMMERCIAL_INSURANCE"."TDIM_LOCATION" (
  DIM_LOCATION_ID NUMBER,  -- Location key.
  LOCATION_CD VARCHAR,  -- Location code, country plus city (e.g. US-TX).
  DIM_LOCATION_KEY VARCHAR,  -- Location business key (same as LOCATION_CD).
  LOCATION_DS VARCHAR,  -- City and country label (e.g. 'Houston, United States').
  LOCATION_LEVEL_1_NODE_CD VARCHAR,  -- Top node code; always 'GLOBAL'.
  LOCATION_LEVEL_1_NODE_DS VARCHAR,  -- Top of the location hierarchy; always 'Global'.
  LOCATION_LEVEL_2_NODE_CD VARCHAR,  -- Region code (AMER, EMEA, APAC).
  LOCATION_LEVEL_2_NODE_DS VARCHAR,  -- Region: Americas, EMEA or APAC.
  LOCATION_LEVEL_3_NODE_CD VARCHAR,  -- Sub-region code.
  LOCATION_LEVEL_3_NODE_DS VARCHAR,  -- Sub-region (North America, Latin America, Europe, Middle East, Asia, Pacific).
  LOCATION_LEVEL_4_NODE_CD VARCHAR,  -- ISO country code.
  LOCATION_LEVEL_4_NODE_DS VARCHAR,  -- Country of the risk location.
  LOCATION_LEVEL_5_NODE_CD VARCHAR,  -- City code (same as LOCATION_CD).
  LOCATION_LEVEL_5_NODE_DS VARCHAR,  -- City of the risk location. Lowest level of the location hierarchy. Catastrophe losses concentrate in Houston and Miami (Hurricane Delphine 2024) and Frankfurt and Paris (European Floods 2025).
  PRIMARY KEY (DIM_LOCATION_ID) NOT ENFORCED
);

-- One row per commercial policy: 5,000 policies with term dates, limit, deductible, commission rate and insured name.
CREATE TABLE "SE_DEMO_LIBRARY"."COMMERCIAL_INSURANCE"."TDIM_POLICY" (
  DIM_POLICY_ID NUMBER,  -- Policy key.
  AGREEMENT_ID VARCHAR,  -- Underlying agreement identifier.
  DIM_POLICY_KEY VARCHAR,  -- Policy business key (e.g. POL00000001).
  ORIGINAL_POLICY_NO VARCHAR,  -- Policy number as issued: entity code, inception year and sequence (e.g. HLNF-2025-000001). The label for a policy.
  POLICY_EFFECTIVE_DT DATE,  -- Policy inception date.
  POLICY_EXPIRATION_DT DATE,  -- Policy expiration date.
  COMPANY_CD VARCHAR,  -- Issuing legal entity code. Use the Legal Entity table for company analysis.
  COMPANY_NM VARCHAR,  -- Issuing legal entity name. Use the Legal Entity table for company analysis.
  COUNTRY_CD VARCHAR,  -- ISO code of the country where the policy is issued.
  COUNTRY_NM VARCHAR,  -- Country where the policy is issued.
  SOURCE_SYSTEM_CD VARCHAR,  -- Source system; always 'GDW'.
  SYSTEM_ID VARCHAR,  -- Originating policy administration system (SYS1..SYS5).
  MARKET_SEGMENT_CD VARCHAR,  -- Market segment code recorded on the policy.
  COMMISION_RATIO NUMBER,  -- Contracted broker commission rate for the policy (0.10 = 10%). A policy attribute; for reporting use the Commission Ratio metric.
  POLICY_TYPE_CD VARCHAR,  -- 'N' new business, 'R' renewal.
  INSURED_NM VARCHAR,  -- Named insured organisation on the policy.
  POLICY_LIMIT NUMBER,  -- Policy limit of liability, USD. A policy attribute; do not add across rows of the fact table.
  POLICY_DEDUCTIBLE NUMBER,  -- Policy deductible, USD.
  PRIMARY KEY (DIM_POLICY_ID) NOT ENFORCED
);

-- The coverage (product) a premium or loss amount belongs to: 11 coverages. Hierarchy: Coverage Group > Coverage Line of Business > Product > Coverage. LONG_TAIL_IN flags coverages whose claims take years to settle.
CREATE TABLE "SE_DEMO_LIBRARY"."COMMERCIAL_INSURANCE"."TDIM_POLICY_COVERAGE" (
  DIM_POLICY_COVERAGE_ID NUMBER,  -- Coverage key.
  DIM_POLICY_COVERAGE_KEY VARCHAR,  -- Coverage business key (same as COVERAGE_CD).
  COVERAGE_CD VARCHAR,  -- Coverage code (e.g. PROPCOM, GLPREM, CYBER).
  COVERAGE_NM VARCHAR,  -- Coverage name (e.g. Commercial Property, Directors & Officers, Cyber). Lowest level of the coverage hierarchy.
  LINE_OF_BUSINESS_CD VARCHAR,  -- Coverage line of business code.
  LINE_OF_BUSINESS_NM VARCHAR,  -- Line of business the coverage rolls up to (Property, Casualty, Commercial Auto, Workers Comp, Financial Lines, Marine, Energy, Aviation).
  COVERAGE_GROUP_CD VARCHAR,  -- Coverage group code.
  COVERAGE_GROUP_NM VARCHAR,  -- Coverage group: Property & Casualty, Financial Lines or Specialty. Top level of the coverage hierarchy.
  PRODUCT_CD VARCHAR,  -- Product code.
  PRODUCT_NM VARCHAR,  -- Product name (e.g. All-Risk Property, Premises Liability, Network Security).
  LONG_TAIL_IN VARCHAR,  -- 'Y' for long-tail coverages whose claims develop over several years (General Liability, Product Liability, Directors & Officers, Workers Compensation, Commercial Auto Liability, Aviation Hull & Liability); 'N' for short-tail coverages that settle within about a year (Commercial Property, Business Interruption, Energy Property, Marine Cargo, Cyber).
  PRIMARY KEY (DIM_POLICY_COVERAGE_ID) NOT ENFORCED
);

-- Global Commercial KPI fact, at a monthly grain. Two kinds of rows share the table. Premium rows (DIM_CLAIM_ID empty, 67,037 rows): one per policy coverage per fiscal month, carrying written and earned premium, commission, underwriting expense, investment income, other financial revenue and tax; these are monthly flows that add up over time. Loss rows (DIM_CLAIM_ID set, 152,483 rows): one per claim per monthly valuation snapshot, carrying incurred loss, paid loss, outstanding reserve and claim expense as cumulative balances to date; every snapshot restates the full balance, so loss amounts must never be added across snapshots. CURRENT_VALUATION_IN = 'Y' marks rows from the latest snapshot (2026-06-30), which hold every claim's current balance. Date roles: snapshot date (valuation month), fiscal month-end (booking month), accident month-end (accident month for loss rows; the fiscal month for premium rows, so earned premium lines up by accident period).
CREATE TABLE "SE_DEMO_LIBRARY"."COMMERCIAL_INSURANCE"."TFACT_KPI" (
  FACT_KPI_ID NUMBER,  -- Row key.
  DIM_SNAPSHOT_DATE_ID NUMBER,  -- Valuation snapshot month-end the row belongs to. Loss balances are as of this date. Join to the calendar as the Snapshot date role.
  DIM_FISCAL_MONTH_END_DATE_ID NUMBER,  -- Fiscal month-end the premium, commission, expense or financial amount is booked in. Join to the calendar as the Fiscal date role; use it for premium growth and calendar-year premium.
  DIM_ACCIDENT_MONTH_END_DATE_ID NUMBER,  -- Accident month-end. Loss rows: month the loss occurred. Premium rows: the fiscal month-end (there is no accident on a premium row), so earned premium and losses line up by accident period. Join to the calendar as the Accident date role; use it for accident-year loss ratios.
  DIM_POLICY_ID NUMBER,  -- Policy.
  DIM_POLICY_KEY VARCHAR,  -- Denormalized policy business key. Join on DIM_POLICY_ID.
  DIM_CLAIM_ID NUMBER,  -- Claim. Set on loss rows only; empty on premium rows.
  DIM_CLAIM_KEY VARCHAR,  -- Denormalized claim business key. Join on DIM_CLAIM_ID.
  DIM_LOCATION_ID NUMBER,  -- Risk location.
  DIM_COMPANY_ID NUMBER,  -- Issuing legal entity.
  DIM_BUSINESS_UNIT_ID NUMBER,  -- Business unit (line of business).
  DIM_CLIENT_ID NUMBER,  -- Client.
  DIM_CLIENT_KEY VARCHAR,  -- Denormalized client business key. Join on DIM_CLIENT_ID.
  DIM_POLICY_COVERAGE_ID NUMBER,  -- Coverage.
  DIM_POLICY_COVERAGE_KEY VARCHAR,  -- Denormalized coverage business key. Join on DIM_POLICY_COVERAGE_ID.
  GROSS_WRITTEN_PREMIUM_AMT NUMBER,  -- Gross written premium, booked in full in the inception month. Monthly flow; adds up over time. Premium rows only.
  NET_WRITTEN_PREMIUM_AMT NUMBER,  -- Written premium net of reinsurance cessions, booked in the inception month. Monthly flow.
  NET_EARNED_PREMIUM_AMT NUMBER,  -- Net premium earned in the month, accrued evenly over the policy term. Monthly flow.
  INCURRED_LOSS_AMT NUMBER,  -- Cumulative incurred loss (paid plus outstanding reserve) for the claim as of the snapshot date. A balance: never add across snapshots. Loss rows only.
  PAID_LOSS_AMT NUMBER,  -- Cumulative paid loss for the claim as of the snapshot date. A balance: never add across snapshots.
  OUTSTANDING_RESERVE_AMT NUMBER,  -- Case reserve still outstanding on the claim as of the snapshot date. A balance: never add across snapshots.
  CLAIM_EXPENSE_AMT NUMBER,  -- Cumulative claim handling (loss adjustment) expense as of the snapshot date. A balance: never add across snapshots.
  NET_COMMISSION_AMT NUMBER,  -- Broker commission expense, net, booked monthly as premium is earned. Monthly flow.
  UNDERWRITING_EXPENSE_AMT NUMBER,  -- Underwriting and acquisition expense other than commission. Monthly flow.
  INVESTMENT_INCOME_AMT NUMBER,  -- Investment income allocated to the business. Monthly flow.
  OTHER_FINANCIAL_REVENUE_AMT NUMBER,  -- Other financial revenue (fees, interest). Monthly flow.
  TAX_AND_OTHER_EXPENSE_AMT NUMBER,  -- Premium taxes and other expense. Monthly flow.
  POLICY_COUNT NUMBER,  -- 1 on every premium row, so it counts policy-coverage-months, not policies. Do not use it to count policies; use Policies in Force or Policies Written.
  CLAIM_COUNT NUMBER,  -- 1 on the row from the snapshot in which the claim was first reported, 0 otherwise. Adds up across snapshots: the sum is the number of claims reported.
  CURRENT_VALUATION_IN VARCHAR,  -- 'Y' on rows from the latest valuation snapshot (2026-06-30), otherwise 'N'. Filter loss balances to 'Y' to read every claim's current balance without double counting.
  PRIMARY KEY (FACT_KPI_ID) NOT ENFORCED
  -- FK: DIM_SNAPSHOT_DATE_ID -> TDIM_DATE(DIM_DATE_ID)
  -- FK: DIM_FISCAL_MONTH_END_DATE_ID -> TDIM_DATE(DIM_DATE_ID)
  -- FK: DIM_ACCIDENT_MONTH_END_DATE_ID -> TDIM_DATE(DIM_DATE_ID)
  -- FK: DIM_POLICY_ID -> TDIM_POLICY(DIM_POLICY_ID)
  -- FK: DIM_CLAIM_ID -> TDIM_CLAIM(DIM_CLAIM_ID)
  -- FK: DIM_LOCATION_ID -> TDIM_LOCATION(DIM_LOCATION_ID)
  -- FK: DIM_COMPANY_ID -> TDIM_COMPANY(DIM_COMPANY_ID)
  -- FK: DIM_BUSINESS_UNIT_ID -> TDIM_BUSINESS_UNIT(DIM_BUSINESS_UNIT_ID)
  -- FK: DIM_CLIENT_ID -> TDIM_CLIENT(DIM_CLIENT_ID)
  -- FK: DIM_POLICY_COVERAGE_ID -> TDIM_POLICY_COVERAGE(DIM_POLICY_COVERAGE_ID)
);
